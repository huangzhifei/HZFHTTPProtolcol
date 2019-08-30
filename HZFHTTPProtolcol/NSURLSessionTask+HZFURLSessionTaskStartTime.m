//
//  NSURLSessionTask+HZFURLSessionTaskStartTime.m
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/31.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import "NSURLSessionTask+HZFURLSessionTaskStartTime.h"
#import <objc/runtime.h>

@implementation NSURLSessionTask (HZFURLSessionTaskStartTime)

- (NSTimeInterval)hzf_startTime {
    NSNumber *d = objc_getAssociatedObject(self, _cmd);
    return [d doubleValue];
}

- (void)setHzf_startTime:(NSTimeInterval)hzf_startTime {
    objc_setAssociatedObject(self, @selector(hzf_startTime), @(hzf_startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
