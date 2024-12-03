//
//  NSArray+XR_Array.h
//  SeatchCar
//
//  Created by Niko on 2023/9/2.
//  Copyright © 2023 SeatchCar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (XRArray)

typedef id _Nullable(^SCMapBlock)(ObjectType obj);
typedef BOOL(^SCFilterBlock)(ObjectType obj);

- (NSArray *)map:(SCMapBlock)block;

- (NSArray <ObjectType> *)filter:(SCFilterBlock)block;

- (nullable ObjectType)first:(SCFilterBlock)block;

- (NSArray *)flatMap:(SCMapBlock)block;

/// 防止数组越界
- (id)safeObjectAtIndex:(NSUInteger)index;

@end


NS_ASSUME_NONNULL_END
