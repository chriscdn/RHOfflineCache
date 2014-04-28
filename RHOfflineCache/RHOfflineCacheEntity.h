//
//  RHImageCacheEntity.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 2012-10-11.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.

#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@interface RHOfflineCacheEntity : RHManagedObject

@property (nonatomic, strong) NSString * filename;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSDate * lastAccessDate;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSString * namespace;


@end