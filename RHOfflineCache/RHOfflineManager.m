//
//  RHOfflineManager.m
//
//  Copyright (C) 2016 by Christopher Meyer
//  http://schwiiz.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

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
    NSDate *twoWeeksAgo = [NSDate dateWithTimeIntervalSinceNow:-1209600];
    NSDate *halfYear = [NSDate dateWithTimeIntervalSinceNow:-15724800];
    NSArray *items = [RHOfflineCache fetchWithPredicate:[NSPredicate predicateWithFormat:@"(lastAccessDate < %@ and keepLonger=%@) or (lastAccessDate < %@ and keepLonger=%@)", twoWeeksAgo, @NO,  halfYear, @YES]];
    [items makeObjectsPerformSelector:@selector(delete)];

    [RHOfflineCache commit];
}

-(void)flushCache {
    //    NSDate *weekAgo = [NSDate dateWithTimeIntervalSinceNow:0];
    //    NSArray *items = [RHOfflineCache fetchWithPredicate:[NSPredicate predicateWithFormat:@"lastAccessDate < %@ and keep=%@", weekAgo, @NO]];
    //
    //    [items makeObjectsPerformSelector:@selector(delete)];
    //
    //    [RHOfflineCache commit];
    
    [self.memoryCache removeAllObjects];
    // [RHOfflineCache deleteWithPredicate:[NSPredicate predicateWithFormat:@"keep=%@", @NO]];
    [RHOfflineCache deleteAll];
    [RHOfflineCache commit];
}

//-(BOOL)isDownloading:(NSString *)url {
//    return ([self.operations objectForKey:url] != nil);
//}

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
    [self.memoryCache removeObjectForKey:url];
}

//-(BOOL)isDownloaded:(NSString *)url {
//    return [self isCached:url];
//}

//-(BOOL)isCached:(NSString *)url {
//    if ([self.memoryCache objectForKey:url] != nil) {
//        return YES;
//    } else {
//        NSUInteger count = [RHOfflineCache countWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
//        return (count > 0);
//    }
//}

-(UIImage *)fetchImageFromCache:(NSString *)url {
    
    UIImage *image = [self.memoryCache objectForKey:url];
    
    if (image == nil) {
        
        RHOfflineCache *item = [RHOfflineCache getWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
        
        //      if ([item cachedFileExists]) {
        
        image = item.image;
        
        if (image) {
            item.lastAccessDate = [NSDate date];
            [self.memoryCache setObject:image forKey:url];
            [RHOfflineCache commit];
        } else {
            // something went wrong, delete it
            [self deleteWithURL:url];
        }
        // }
    }
    
    return image;
    
}

-(AnyPromise *)imagePromiseWithURL:(NSString *)url {
    return [self imagePromiseWithURL:url keepLonger:NO];
}

-(AnyPromise *)imagePromiseWithURL:(NSString *)url keepLonger:(BOOL)keepLonger {
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        
        UIImage *image = [self fetchImageFromCache:url];
        
        if (image) {
            resolve(image);
        } else {
            
            NSURLRequest *nsurlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:nsurlrequest];
            
            // disable caching
            [operation setCacheResponseBlock:nil];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
                
                UIImage *image = [UIImage imageWithData:responseObject];
                
                if (image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        RHOfflineCache *item = [RHOfflineCache newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"url=%@", url]];
                        
                        [item setFilename:[RHOfflineCache UUID]];
                        [item setUrl:url];
                        [item setSize:[NSNumber numberWithInteger:responseObject.length]];
                        [item setKeepLongerValue:keepLonger];
                        
                        NSError *error1;
                        [responseObject writeToFile:[item fullPath] options:NSDataWritingAtomic error:&error1];
                       
                        [self addSkipBackupAttributeToItemAtURL:[item localURL]];
                        
                        NSError *error2 = [RHOfflineCache commit];
                        
                        // if either operation failed then give up.
                        if (error1 || error2) {
                            [item delete];
                            // [RHOfflineCache commit];
                        }

                    });
                    
                    resolve(image);
                } else {
                    resolve([NSError errorWithDomain:@"com.trackmytour.error" code:0 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"An unknown error occurred.", nil)}]);
                }
                
                [self removeOperation:url];
                
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                resolve(error);
                
                [self removeOperation:url];
            }];
            
            // Cancel any existing operations with the same URL.  Be careful if you consider moving this to another location as it
            // might introduce a race condition with the removeOperation call in the failure block.
            [self cancelOperation:url];
            [self.operations setObject:operation forKey:url];
            [operation start];
        }
    }];
}


// https://developer.apple.com/library/ios/qa/qa1719/_index.html
// TODO: Move this to a category
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
