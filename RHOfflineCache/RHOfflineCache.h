//
//  RHImageCache.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 2012-10-10.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.

#define kRHOfflineCacheInsert @"RHOfflineCacheInsert"
#define kRHOfflineCacheDelete @"RHOfflineCacheDelete"

#import "RHOfflineCacheEntity.h"

@interface RHOfflineCache : RHOfflineCacheEntity

+(NSString *)UUID;

-(NSString *)fullPath;
-(NSURL *)localURL;
-(UIImage *)image;
-(BOOL)cachedFileExists;

-(void)buzz;

@end