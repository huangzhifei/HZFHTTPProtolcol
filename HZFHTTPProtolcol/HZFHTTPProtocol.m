//
//  HZFHTTPProtocol.m
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/30.
//  Copyright © 2019 huangzhifei. All rights reserved.
//


#import "HZFHTTPProtocol.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const HZFHTTPHandledIdentifier = @"HZFHTTPHandledIdentifier";

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

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:HZFHTTPHandledIdentifier inRequest:request]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:HZFHTTPHandledIdentifier inRequest:mutableRequest];
    return [mutableRequest copy];
}

- (void)startLoading {
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [mutableRequest addValue:self.hzf_identifier forHTTPHeaderField:@"hzf_request_id"];
    self.hzf_request = [mutableRequest copy];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request];
    self.hzf_dataTask = task;
    self.start_time = [[NSDate date] timeIntervalSince1970];
    NSLog(@"protocol 请求接口开始->url: %@ identifier: %@", self.hzf_request.URL, self.hzf_identifier);
    [self.hzf_dataTask resume];
}

- (void)stopLoading {
    [self.hzf_dataTask cancel];
    NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - self.start_time;
    //获取请求方法
    NSString *requestMethod = self.hzf_request.HTTPMethod;
    NSLog(@"protocol 请求接口结束->url: %@ method: %@ identifier: %@ cost: %lfms", self.hzf_request.URL, requestMethod, self.hzf_identifier, cost * 1000);
    
    //获取请求头
    NSDictionary *headers = self.hzf_request.allHTTPHeaderFields;
    NSLog(@"请求头：\n");
    for (NSString *key in headers.allKeys) {
        NSLog(@"%@ : %@", key, headers[key]);
    }

    self.hzf_dataTask = nil;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        NSLog(@"protocol 请求接口错误->url: %@ identifier: %@", self.hzf_request, self.hzf_identifier);
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.hzf_dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
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

