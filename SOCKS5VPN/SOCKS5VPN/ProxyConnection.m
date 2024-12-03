//
//  ProxyConnection.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/12/1.
//

#import "ProxyConnection.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"

@implementation ProxyConnection


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    return YES; // 支持所有 HTTP 方法
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSLog(@"Received request: %@ %@", method, path);

    // 转发请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self->request.url];
    [request setHTTPMethod:method];

    NSURLSession *session = [NSURLSession sharedSession];
    __block NSData *responseData = nil;
    __block NSHTTPURLResponse *httpResponse = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        httpResponse = (NSHTTPURLResponse *)response;
        responseData = data;
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    // 返回响应
    if (httpResponse) {
        return [[HTTPDataResponse alloc] initWithData:responseData];
    } else {
        return [[HTTPDataResponse alloc] initWithData:[@"Proxy error" dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


@end
