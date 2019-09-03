//
//  NSURLSessionConfiguration+HZFURLProtocolSwizzling.m
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/31.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import "NSURLSessionConfiguration+HZFURLProtocolSwizzling.h"
#import "HZFHTTPProtocol.h"
#import <objc/runtime.h>

/**
 因为AFNetworking网络请求的NSURLSession实例方法都是通过
 sessionWithConfiguration:delegate:delegateQueue:方法获得的，我们是不能监听到的，
 然而我们通过[NSURLSession sharedSession]生成session就可以拦截到请求，原因就出在NSURLSessionConfiguration上。
 他有一个属性 protocolClasses
 */
@implementation NSURLSessionConfiguration (HZFURLProtocolSwizzling)

+ (void)load {
    Method originalMethod = class_getClassMethod([self class], @selector(defaultSessionConfiguration));
    Method swizzledMethod = class_getClassMethod([self class], @selector(hook_defaultSessionConfiguration));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    [NSURLProtocol registerClass:[HZFHTTPProtocol class]];
}

+ (NSURLSessionConfiguration *)hook_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [self hook_defaultSessionConfiguration];
    NSArray *protocolClasses = @[ [HZFHTTPProtocol class] ];
    configuration.protocolClasses = protocolClasses;
    return configuration;
}

@end
