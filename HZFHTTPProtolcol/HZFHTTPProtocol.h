//
//  HZFHTTPProtocol.h
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/30.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 用来拦截所有的 URL 请求，自动在头里面增加了 request_id 和计算网络接口的耗时
 */
@interface HZFHTTPProtocol : NSURLProtocol

+ (void)start;

+ (void)end;

/**
 不设置或传空，则默认拦截所有的 url load system
 
 @param domainList 白名单
 */
+ (void)interceptDomainWhiteList:(NSArray<NSString *> *)domainList;

@end

NS_ASSUME_NONNULL_END
