//
//  RHImageManager.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 2012-10-11.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.


typedef void (^RHOfflineManagerProgressBlock)(float progress);
typedef void (^RHOfflineManagerSuccessBlock)(NSURL *localURL);
typedef void (^RHOfflineImageManagerSuccessBlock)(UIImage *image);
typedef void (^RHOfflineManagerErrorBlock)(NSError *error);

@interface RHOfflineManager : NSObject

+(RHOfflineManager *)sharedInstance;

-(NSNumber *)cacheSize;
-(NSString *)cacheSizeMB;
-(BOOL)isCacheable:(NSString *)url;
-(void)flushCache;

-(NSString *)sizeWithURL:(NSString *)url;
-(void)deleteWithURL:(NSString *)url;
-(BOOL)isDownloading:(NSString *)url;
-(BOOL)isDownloaded:(NSString *)url;
-(BOOL)isCached:(NSString *)url;

-(NSArray *)cachedURLs;

-(NSURL *)localURLWithURL:(NSString *)url;
-(NSURL *)localURLWithURL:(NSString *)url progress:(RHOfflineManagerProgressBlock)progress success:(RHOfflineManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure;
-(NSURL *)localURLWithURL:(NSString *)url namespace:(NSString *)namespace progress:(RHOfflineManagerProgressBlock)progress success:(RHOfflineManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure;
-(UIImage *)imageWithURL:(NSString *)url success:(RHOfflineImageManagerSuccessBlock)success failure:(RHOfflineManagerErrorBlock)failure;

@end