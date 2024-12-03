//
//  ProxyServer.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/12/1.
//

#import "ProxyServer.h"

@implementation ProxyServer

- (void)startServer {
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setConnectionClass:[ProxyConnection class]];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort:8080]; // 设置 HTTP 代理端口
    [self.httpServer setDocumentRoot:NSTemporaryDirectory()];

    NSError *error;
    if (![self.httpServer start:&error]) {
        NSLog(@"Error starting HTTP Server: %@", error);
    } else {
        NSLog(@"HTTP Server started on port %hu", [self.httpServer listeningPort]);
    }
}


@end
