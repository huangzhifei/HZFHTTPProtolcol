//
//  HZFHTTPProtocol.m
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/30.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import "HZFHTTPProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSURLRequest+HZFRequestIncludeBody.h"

static NSString *const HZFHTTPHandledIdentifier = @"HZFHTTPHandledIdentifier";

/**
 NSURLProtocol：就是一个苹果允许的中间人攻击。
 NSURLProtocol可以劫持系统所有基于 C socket 的网络请求。
 WKWebView基于Webkit，并不走底层的 C socket，所以NSURLProtocol拦截不了WKWebView中的请求
 */
@interface HZFHTTPProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *hzf_dataTask;
@property (nonatomic, strong) NSURLRequest *hzf_request;
@property (nonatomic, strong) NSURLResponse *hzf_response;
@property (nonatomic, strong) NSMutableData *hzf_data;
@property (nonatomic, assign) NSTimeInterval start_time;
@property (nonatomic, copy) NSString *hzf_identifier;

@end

@implementation HZFHTTPProtocol

+ (void)start {
    [NSURLProtocol registerClass:[self class]];
}

+ (void)end {
    [NSURLProtocol unregisterClass:[self class]];
}

/**
 这个方法用来返回是否需要处理这个请求，如果需要处理，返回YES，否则返回NO。在该方法中可以对不需要处理的请求进行过滤。

 @param request 请求地址
 @return 是否能处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }

    //看看是否已经处理过了，防止无限循环根据业务来截取
    if ([NSURLProtocol propertyForKey:HZFHTTPHandledIdentifier inRequest:request]) {
        return NO;
    }

    return YES;
}

/**
 重写该方法，可以对请求进行修改，例如添加新的头部信息，修改，修改url等。

 @param request 请求地址
 @return 修改后的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:HZFHTTPHandledIdentifier inRequest:mutableRequest];
    return [mutableRequest getPostRequestIncludeBody];
}

/**
 主要判断两个request是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
 一般这个方法可以不用实现
 */
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

/**
 转发：
 重写该方法，需要在该方法中发起一个请求
 */
- (void)startLoading {
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [mutableRequest addValue:self.hzf_identifier forHTTPHeaderField:@"hzf_request_id"];
    self.hzf_request = [mutableRequest copy];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.hzf_request];
    self.hzf_dataTask = task;
    self.start_time = [[NSDate date] timeIntervalSince1970];
    NSLog(@"protocol 请求接口开始->url: %@ identifier: %@", self.hzf_request.URL, self.hzf_identifier);
    [self.hzf_dataTask resume];
}

/**
 重写该方法，网络请求最后会回到这里。
 在一个网络请求完全结束以后，NSURLProtocol回调用到。在该方法里，我们完成在结束网络请求的操作。
 */
- (void)stopLoading {
    NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - self.start_time;
    //获取请求方法
    NSString *requestMethod = self.hzf_request.HTTPMethod;
    NSLog(@"protocol 请求接口结束->url:%@ method:%@ identifier:%@ cost:%lfms", self.hzf_request.URL, requestMethod, self.hzf_identifier, cost * 1000);
    [self.hzf_dataTask cancel];
    self.hzf_dataTask = nil;
}

#pragma mark - NSURLSessionTaskDelegate

/**
 UIWebview 中发送一个request，在这里拦截后使用NSURLSession重新发request。
 那UIWebview是收不到response的。这里就要做一个处理，每一个NSURLProtocol的子类都有一个client对象来处理response。
*/

/**
 请求结束或者是失败的时候调用
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
}

#pragma mark - NSURLSessionDataDelegate

/**
 接收到服务器返回的数据 调用多次
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

/**
 接收到返回信息时(还未开始下载), 执行的代理方法
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
    self.hzf_response = response;
}

- (void)URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler {
    if (response != nil) {
        self.hzf_response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

#pragma mark - Getter & Setter

- (NSString *)hzf_identifier {
    if (!_hzf_identifier) {
        _hzf_identifier = [[self hzf_MD5:[self generateIdentifier]] lowercaseString];
    }
    return _hzf_identifier;
}

- (NSString *)generateIdentifier {
    NSString *result = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        result = (__bridge_transfer NSString *) CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    if (result == nil) {
        NSString *dateFormatterString = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFormatterString];
        result = [formatter stringFromDate:[NSDate date]];
    }
    return result;
}

- (NSString *)hzf_MD5:(NSString *)originalString {
    const char *cStr = [originalString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG) strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}

@end

