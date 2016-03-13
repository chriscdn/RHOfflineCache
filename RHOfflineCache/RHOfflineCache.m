//
//  RHOfflineCache.m
//
//  Copyright (C) 2016 by Christopher Meyer
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
        
        const static NSInteger schemaVersion = 3;
        
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