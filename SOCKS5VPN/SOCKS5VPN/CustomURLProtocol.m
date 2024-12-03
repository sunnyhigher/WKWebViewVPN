//
//  CustomURLProtocol.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/29.
//

#import "CustomURLProtocol.h"
#import "DataManager.h"
#import "MCXMacro.h"

@interface CustomURLProtocol()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;


@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
//    NSLog(@"canInitWithRequest: %@", request.URL);
//    if ([NSURLProtocol propertyForKey:@"HandledByCustomURLProtocol" inRequest:request]) {
//        return NO;  // Avoid handling the same request multiple times
//    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSLog(@"startLoading called for URL: %@", self.request.URL);
    
    NSMutableURLRequest *modifiedRequest = [self.request mutableCopy];
    //[NSURLProtocol setProperty:@YES forKey:@"HandledByCustomURLProtocol" inRequest:modifiedRequest];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *ip = [DataManager sharedInstance].getLocalData[[DataManager sharedInstance].currentIndex].ip;
    
    if (!MCXStringIsNil(ip)) {
        config.connectionProxyDictionary = @{
            (NSString *)kCFStreamPropertySOCKSProxyHost: ip,
            (NSString *)kCFStreamPropertySOCKSProxyPort: @(7891)
        };
    } else {
        config.connectionProxyDictionary = @{};
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:modifiedRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self.client URLProtocol:self didFailWithError:error];
        } else {
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        }
    }];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
}

@end
