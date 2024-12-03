//
//  ProxyServer.h
//  SOCKS5VPN
//
//  Created by Niko on 2024/12/1.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
#import "ProxyConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProxyServer : NSObject

@property (nonatomic, strong) HTTPServer *httpServer;
- (void)startServer;

@end

NS_ASSUME_NONNULL_END
