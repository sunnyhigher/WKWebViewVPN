//
//  IPModel.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "IPModel.h"

@implementation IPModel

- (instancetype)initWithName:(NSString *)name ip:(NSString *)ip {
    self = [super init];
    if (self) {
        _name = name;
        _ip = ip;
    }
    return self;
}

@end
