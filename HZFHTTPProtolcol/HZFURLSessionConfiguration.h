//
//  HZFURLSessionConfiguration.h
//  HZFHTTPProtolcol
//
//  Created by huangzhifei on 2019/9/6.
//  Copyright © 2019 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZFURLSessionConfiguration : NSObject

@property (nonatomic, assign) BOOL isSwizzle;

+ (HZFURLSessionConfiguration *)defaultConfiguration;

/**
 *  swizzle NSURLSessionConfiguration's protocolClasses method
 */
- (void)loadMethod;

/**
 *  make NSURLSessionConfiguration's protocolClasses method is normal
 */
- (void)unloadMethod;

@end

NS_ASSUME_NONNULL_END
