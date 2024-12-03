//
//  IPModel.h
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPModel : NSObject

@property (nonatomic, copy) NSString *name; // JSON 的 key
@property (nonatomic, copy) NSString *ip;   // JSON 的 value
@property (nonatomic, copy) NSString *ping;


// 初始化方法
- (instancetype)initWithName:(NSString *)name ip:(NSString *)ip;

@end

NS_ASSUME_NONNULL_END
