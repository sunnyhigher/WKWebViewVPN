//
//  NSArray+XR_Array.m
//  SeatchCar
//
//  Created by Niko on 2023/9/2.
//  Copyright © 2023 SeatchCar. All rights reserved.
//

#import "NSArray+XRArray.h"

@implementation NSArray (XRArray)


- (NSArray *)map:(SCMapBlock)block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
        id mappedObj = block(obj);
        if (mappedObj) {
            [result addObject:mappedObj];
        }
    }
    
    return [result copy];
}

- (NSArray *)filter:(SCFilterBlock)block {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id obj in self) {
        if (block(obj)) {
            [result addObject:obj];
        }
    }
    
    return [result copy];
}


- (id)first:(SCFilterBlock)block {
    for (id obj in self) {
        if (block(obj)) {
            return obj;
        }
    }
    return nil;
}

- (NSArray *)flatMap:(SCMapBlock)block {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (id obj in self) {
        id mappedObject = block(obj);
        
        if ([mappedObject isKindOfClass:[NSArray class]]) {
            [resultArray addObjectsFromArray:mappedObject];
        } else if (mappedObject) {
            [resultArray addObject:mappedObject];
        }
    }
    
    return [resultArray copy];
}

/// 防止数组越界
- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end
