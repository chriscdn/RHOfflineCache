// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RHOfflineCache.h instead.

#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

extern const struct RHOfflineCacheAttributes {
	__unsafe_unretained NSString *createDate;
	__unsafe_unretained NSString *filename;
	__unsafe_unretained NSString *lastAccessDate;
	__unsafe_unretained NSString *namespace;
	__unsafe_unretained NSString *size;
	__unsafe_unretained NSString *url;
} RHOfflineCacheAttributes;

@interface RHOfflineCacheID : NSManagedObjectID {}
@end

@interface _RHOfflineCache : RHManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) RHOfflineCacheID* objectID;

@property (nonatomic, strong) NSDate* createDate;

//- (BOOL)validateCreateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* filename;

//- (BOOL)validateFilename:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastAccessDate;

//- (BOOL)validateLastAccessDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* namespace;

//- (BOOL)validateNamespace:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* size;

@property (atomic) int32_t sizeValue;
- (int32_t)sizeValue;
- (void)setSizeValue:(int32_t)value_;

//- (BOOL)validateSize:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;

@end

@interface _RHOfflineCache (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreateDate;
- (void)setPrimitiveCreateDate:(NSDate*)value;

- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;

- (NSDate*)primitiveLastAccessDate;
- (void)setPrimitiveLastAccessDate:(NSDate*)value;

- (NSString*)primitiveNamespace;
- (void)setPrimitiveNamespace:(NSString*)value;

- (NSNumber*)primitiveSize;
- (void)setPrimitiveSize:(NSNumber*)value;

- (int32_t)primitiveSizeValue;
- (void)setPrimitiveSizeValue:(int32_t)value_;

- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;

@end
