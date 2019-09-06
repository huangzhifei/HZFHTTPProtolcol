//
//  HZFURLSessionConfiguration.m
//  HZFHTTPProtolcol
//
//  Created by huangzhifei on 2019/9/6.
//  Copyright © 2019 eric. All rights reserved.
//

#import "HZFURLSessionConfiguration.h"
#import <objc/runtime.h>
#import "HZFHTTPProtocol.h"

@implementation HZFURLSessionConfiguration

+ (HZFURLSessionConfiguration *)defaultConfiguration {
    static HZFURLSessionConfiguration *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HZFURLSessionConfiguration alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSwizzle = NO;
    }
    return self;
}

- (void)loadMethod {
    self.isSwizzle = YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

- (void)unloadMethod {
    self.isSwizzle = NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    return @[ [HZFHTTPProtocol class] ];
}

@end
