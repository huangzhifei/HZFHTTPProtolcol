//
//  HZFHTTPProtocol.m
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/30.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import "HZFHTTPProtocol.h"
#import "NSURLSessionTask+HZFURLSessionTaskStartTime.h"

static NSString *const HZFHTTPHandledIdentifier = @"HZFHTTPHandledIdentifier";

@interface HZFHTTPProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation HZFHTTPProtocol

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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request];
    self.dataTask = task;
    self.dataTask.hzf_startTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"请求网络开始");
    [self.dataTask resume];
}

- (void)stopLoading {
    NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - self.dataTask.hzf_startTime;
    NSLog(@"请求网络耗时: %lfs, url: %@", cost , self.dataTask.currentRequest);
    [self.dataTask cancel];
    self.dataTask = nil;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {

    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
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
}

- (void)URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler {
}

@end
