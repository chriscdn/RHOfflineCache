//
//  RHOfflineManager.h
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

#define kOfflineImage [UIImage imageNamed:@"offline_image"]

typedef void (^RHOfflineManagerProgressBlock)(float progress);
typedef void (^RHOfflineManagerSuccessBlock)(NSURL *localURL);
typedef void (^RHOfflineImageManagerSuccessBlock)(UIImage *image);
typedef void (^RHOfflineManagerErrorBlock)(NSError *error);

#import <PromiseKit/PromiseKit.h>

@interface RHOfflineManager : NSObject

+(RHOfflineManager *)sharedInstance;

-(NSNumber *)cacheSize;
-(NSString *)cacheSizeMB;
//-(BOOL)isCacheable:(NSString *)url;
-(void)flushCache;

-(NSString *)sizeWithURL:(NSString *)url;

-(void)deleteWithURL:(NSString *)url;
-(BOOL)isDownloading:(NSString *)url;
-(BOOL)isDownloaded:(NSString *)url;
-(BOOL)isCached:(NSString *)url;

-(NSArray *)cachedURLs;

-(UIImage *)fetchImageFromCache:(NSString *)url;
-(AnyPromise *)imagePromiseWithURL:(NSString *)url;

@end
