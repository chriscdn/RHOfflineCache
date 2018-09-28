// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RHOfflineCache.m instead.

#import "_RHOfflineCache.h"

@implementation RHOfflineCacheID
@end

@implementation _RHOfflineCache

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RHOfflineCache" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RHOfflineCache";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RHOfflineCache" inManagedObjectContext:moc_];
}

- (RHOfflineCacheID*)objectID {
	return (RHOfflineCacheID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"keepLongerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keepLonger"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic createDate;

@dynamic filename;

@dynamic keepLonger;

- (BOOL)keepLongerValue {
	NSNumber *result = [self keepLonger];
	return [result boolValue];
}

- (void)setKeepLongerValue:(BOOL)value_ {
	[self setKeepLonger:@(value_)];
}

- (BOOL)primitiveKeepLongerValue {
	NSNumber *result = [self primitiveKeepLonger];
	return [result boolValue];
}

- (void)setPrimitiveKeepLongerValue:(BOOL)value_ {
	[self setPrimitiveKeepLonger:@(value_)];
}

@dynamic lastAccessDate;

@dynamic size;

- (int32_t)sizeValue {
	NSNumber *result = [self size];
	return [result intValue];
}

- (void)setSizeValue:(int32_t)value_ {
	[self setSize:@(value_)];
}

- (int32_t)primitiveSizeValue {
	NSNumber *result = [self primitiveSize];
	return [result intValue];
}

- (void)setPrimitiveSizeValue:(int32_t)value_ {
	[self setPrimitiveSize:@(value_)];
}

@dynamic url;

@end

@implementation RHOfflineCacheAttributes 
+ (NSString *)createDate {
	return @"createDate";
}
+ (NSString *)filename {
	return @"filename";
}
+ (NSString *)keepLonger {
	return @"keepLonger";
}
+ (NSString *)lastAccessDate {
	return @"lastAccessDate";
}
+ (NSString *)size {
	return @"size";
}
+ (NSString *)url {
	return @"url";
}
@end

