//
//  RHImageManager.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 2012-10-11.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.

#define kOfflineImage [UIImage imageNamed:@"offline_image"]

#import "RHManagedObject+legacy.h"
#import "RHOfflineManager.h"
#import "RHOfflineCache.h"
#import "AFHTTPRequestOperation.h"

@interface RHOfflineManager()

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) NSMutableDictionary *operations;

-(void)purgeOldStuff;
-(void)removeOperation:(NSString *)url;
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end

@implementation RHOfflineManager
@synthesize memoryCache;
@synthesize operations;

+(RHOfflineManager *)sharedInstance {
    static dispatch_once_t once;
    static RHOfflineManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [RHOfflineManager new];
    });
    return sharedInstance;
}

-(id)init {
    if (self=[super init]) {
		self.memoryCache = [NSCache new];
		self.operations = [NSMutableDictionary new];
        [self purgeOldStuff];
    }

    return self;
}

-(NSNumber *)cacheSize {
	return [RHOfflineCache aggregateWithType:RHAggregateSum key:@"size" predicate:nil defaultValue:nil];
}

-(NSString *)cacheSizeMB {
	NSNumber *bytes = [self cacheSize];
	float mb = [bytes floatValue]/(1024*1024);
	return [NSString stringWithFormat:@"%.1f MB", mb];
}

-(void)purgeOldStuff {
    NSDate *fourWeeksAgo = [NSDate dateWithTimeIntervalSinceNow:-2419200];
    NSArray *items = [RHOfflineCache fetchWithPredicate:[NSPredicate predicateWithFormat:@"lastAccessDate < %@", fourWeeksAgo]];

    for (RHOfflineCache *item in items) {
        [item delete];
    }

    [RHOfflineCache commit];
}

-(BOOL)isCacheable:(NSString *)url {

	NSURL *myurl = [NSURL URLWithString:url];
	NSString *ext = [myurl pathExtension];

	NSArray *allowableTypes = @[@"png",@"jpg",@"jpeg",@"gif,",@"mov",@"mkv",@"mp4",@"mpg",@"doc",@"docx",@"xls",@"xlsx",@"ppt",@"pptx",@"pdf",@"txt"];

	return [allowableTypes containsObject:ext];

}

-(void)flushCache {
	[self.memoryCache removeAllObjects];
	[RHOfflineCache deleteAll];
	[RHOfflineCache commit];
}

-(BOOL)isDownloading:(NSString *)url {
	return ([self.operations objectForKey:url] != nil);
}

-(NSArray *)cachedURLs {
    return [RHOfflineCache distinctValuesWithAttribute:@"url" predicate:nil];
}

-(void)removeOperation:(NSString *)url {
	[self.operations removeObjectForKey:url];
}

-(void)cancelOperation:(NSString *)url {
	AFHTTPRequestOperation *operation = [self.operations objectForKey:url];
	if (operation) {
		[operation cancel];
	}
}

-(NSString *)sizeWithURL:(NSString *)url {
	RHOfflineCache *item = [RHOfflineCache getWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
	if (item) {
		float mb = [item.size floatValue]/(1024*1024);
		return [NSString stringWithFormat:@"%.1f MB", mb];
	}
	return nil;
}

-(void)deleteWithURL:(NSString *)url {
	[[RHOfflineCache getWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]] delete];
	// [RHOfflineCache commit];
}

-(BOOL)isDownloaded:(NSString *)url {
	return [self isCached:url];
}

-(BOOL)isCached:(NSString *)url {
	if ([self.memoryCache objectForKey:url] != nil) {
		return YES;
	}

	NSUInteger count = [RHOfflineCache countWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
    return ( count > 0 );
}

-(NSURL *)localURLWithURL:(NSString *)url {
	if ([self isCached:url]) {
		return [self localURLWithURL:url namespace:nil progress:nil success:nil failure:nil];
	}
	return nil;
}

-(NSURL *)localURLWithURL:(NSString *)url progress:(RHOfflineManagerProgressBlock)progress success:(RHOfflineManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure {
    return [self localURLWithURL:url namespace:nil progress:progress success:success failure:failure];
}

-(NSURL *)localURLWithURL:(NSString *)url namespace:(NSString *)namespace progress:(RHOfflineManagerProgressBlock)progress success:(RHOfflineManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure {

	RHOfflineCache *item = [RHOfflineCache getWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
	item.lastAccessDate = [NSDate date];

	if (item && [item cachedFileExists]) {
		if (success) {
			success([item localURL]);
		}

		return [item localURL];

	} else if ([self isDownloading:url]) {

        return nil;

    } else {

		NSURLRequest *nsurlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:nsurlrequest];

		[operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			float progressValue = (float)totalBytesRead / (float)totalBytesExpectedToRead;

			if (progress) {
				progress(progressValue);
			}
		}];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
			RHOfflineCache *item = [RHOfflineCache newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];

			NSString *ext = [url pathExtension];
			[item setFilename:[NSString stringWithFormat:@"%@.%@", [RHOfflineCache UUID], ext]];
			[item setUrl:url];
			[item setSize:[NSNumber numberWithInteger:responseObject.length]];
            [item setNamespace:namespace];

            [item buzz];

			NSError *error;

			[responseObject writeToFile:[item fullPath] options:NSDataWritingAtomic error:&error];

			[self addSkipBackupAttributeToItemAtURL:[item localURL]];

			// Only commit once the file is safe on the filesystem.
			[RHOfflineCache commit];

            if (success) {
				success([item localURL]);
            }

			[self removeOperation:url];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (failure) {
					failure(error);
				}
			});

			[self removeOperation:url];
		}];

		[self cancelOperation:url];
		[self.operations setObject:operation forKey:url];
		[operation start];

		return nil;
	}
}

-(UIImage *)imageWithURL:(NSString *)url success:(RHOfflineImageManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure {

	UIImage *image = [self.memoryCache objectForKey:url];

	if (image) {
		return image;
	}

	RHOfflineCache *item = [RHOfflineCache getWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
	item.lastAccessDate = [NSDate date];

    if (item && [item cachedFileExists]) {

		image = [item image];

		if (image) {
			[self.memoryCache setObject:image forKey:url];
			return image;
        } else {
			return kOfflineImage;
		}

	} else {

        NSURLRequest *nsurlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:nsurlrequest];

		// disable caching
		[operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
			return nil;
		}];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
            // It might be more efficient to put the core data and file write into a separate thread, and just call success()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

				UIImage *image = [UIImage imageWithData:responseObject];

				// The existence of image isn't guaranteed
				if ( image ) {
					RHOfflineCache *item = [RHOfflineCache newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];

					NSString *ext = [url pathExtension];
					[item setFilename:[NSString stringWithFormat:@"%@.%@", [RHOfflineCache UUID], ext]];
					[item setUrl:url];
					[item setSize:[NSNumber numberWithInteger:responseObject.length]];

					NSError *error;
					[responseObject writeToFile:[item fullPath] options:NSDataWritingAtomic error:&error];
					[self addSkipBackupAttributeToItemAtURL:[item localURL]];

					// Only commit once the file is safe on the filesystem.
					[RHOfflineCache commit];
				}
            });

            if (success) {
                UIImage *image = [UIImage imageWithData:responseObject];
				if (image) {
					[self.memoryCache setObject:image forKey:url];
					success(image);
				}
            }

			[self removeOperation:url];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }

			[self removeOperation:url];
        }];

		[self cancelOperation:url];
		[self.operations setObject:operation forKey:url];
        [operation start];

        return kOfflineImage;
    }
}

// https://developer.apple.com/library/ios/qa/qa1719/_index.html
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end