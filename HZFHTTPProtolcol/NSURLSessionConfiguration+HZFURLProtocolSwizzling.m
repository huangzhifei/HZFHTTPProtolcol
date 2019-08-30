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

@implementation NSURLSessionConfiguration (HZFURLProtocolSwizzling)

+ (void)load {
    Method originalMethod = class_getClassMethod([self class], @selector(defaultSessionConfiguration));
    Method swizzledMethod = class_getClassMethod([self class], @selector(hook_defaultSessionConfiguration));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    [NSURLProtocol registerClass:[HZFHTTPProtocol class]];
}

+ (NSURLSessionConfiguration *)hook_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [self hook_defaultSessionConfiguration];
    NSArray *protocolClasses = @[[HZFHTTPProtocol class]];
    configuration.protocolClasses = protocolClasses;
    return configuration;
}

@end
