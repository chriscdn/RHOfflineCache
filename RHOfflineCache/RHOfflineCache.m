//
//  RHImageCache.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 2012-10-10.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.

#import "RHOfflineCache.h"
#import "RHManagedObjectContextManager.h"
#import "AFHTTPRequestOperation.h"

@interface RHOfflineCache()
+(NSString *)cachePath;
@end

@implementation RHOfflineCache

+(void)initialize {
    // http://www.mikeash.com/pyblog/friday-qa-2009-05-22-objective-c-class-loading-and-initialization.html
    if (self == [RHOfflineCache class] ) {
        
        const static NSInteger schemaVersion = 2;
        
        NSString *key = [NSString stringWithFormat:@"RHOfflineManagerSchemaVersion-%@", [self modelName]];
        NSInteger version = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        
        if (version != schemaVersion) {
            [self deleteStore];
            [[NSUserDefaults standardUserDefaults] setInteger:schemaVersion forKey:key];
            
            NSError *error = nil;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:&error];
            if (!success || error) {
                // something went wrong
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commit) name:UIApplicationWillResignActiveNotification object:nil];
        
        // TODO: error handling
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cachePath] withIntermediateDirectories:YES attributes:nil error:nil];
	}
}

+(NSString *)modelName {
    return @"rhofflinecache";
}

+(NSString *)UUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(__bridge NSString *)string lowercaseString];
}

+(NSString *)cachePath {
	return [[[self managedObjectContextManager] applicationDocumentsDirectory] stringByAppendingPathComponent:@"rhofflinecache"];
}

-(NSString *)fullPath {
    return [[RHOfflineCache cachePath] stringByAppendingPathComponent:self.filename];
}

-(NSURL *)localURL {
	return [NSURL fileURLWithPath:[self fullPath]];
}

-(UIImage *)image {
	return [UIImage imageWithContentsOfFile:[self fullPath]];
}

-(BOOL)cachedFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:self.fullPath];
}

-(void)awakeFromFetch {
    [super awakeFromFetch];
    [self setLastAccessDate:[NSDate date]];
}

-(void)awakeFromInsert {
    [super awakeFromInsert];
	[self setCreateDate:[NSDate date]];
	[self setLastAccessDate:[NSDate date]];
}

-(void)buzz {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRHOfflineCacheInsert object:self];
}

-(void)prepareForDeletion {
    [super prepareForDeletion];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kRHOfflineCacheDelete object:self];
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self fullPath] error:&error];
    if (!success || error) {
        // something went wrong
    }
}

@end