// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RHOfflineCache.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "RHManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface RHOfflineCacheID : NSManagedObjectID {}
@end

@interface _RHOfflineCache : RHManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) RHOfflineCacheID *objectID;

@property (nonatomic, strong) NSDate* createDate;

@property (nonatomic, strong) NSString* filename;

@property (nonatomic, strong) NSNumber* keepLonger;

@property (atomic) BOOL keepLongerValue;
- (BOOL)keepLongerValue;
- (void)setKeepLongerValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSDate* lastAccessDate;

@property (nonatomic, strong, nullable) NSNumber* size;

@property (atomic) int32_t sizeValue;
- (int32_t)sizeValue;
- (void)setSizeValue:(int32_t)value_;

@property (nonatomic, strong) NSString* url;

@end

@interface _RHOfflineCache (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreateDate;
- (void)setPrimitiveCreateDate:(NSDate*)value;

- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;

- (NSNumber*)primitiveKeepLonger;
- (void)setPrimitiveKeepLonger:(NSNumber*)value;

- (BOOL)primitiveKeepLongerValue;
- (void)setPrimitiveKeepLongerValue:(BOOL)value_;

- (nullable NSDate*)primitiveLastAccessDate;
- (void)setPrimitiveLastAccessDate:(nullable NSDate*)value;

- (nullable NSNumber*)primitiveSize;
- (void)setPrimitiveSize:(nullable NSNumber*)value;

- (int32_t)primitiveSizeValue;
- (void)setPrimitiveSizeValue:(int32_t)value_;

- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;

@end

@interface RHOfflineCacheAttributes: NSObject 
+ (NSString *)createDate;
+ (NSString *)filename;
+ (NSString *)keepLonger;
+ (NSString *)lastAccessDate;
+ (NSString *)size;
+ (NSString *)url;
@end

NS_ASSUME_NONNULL_END
