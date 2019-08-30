//
//  NSURLSessionTask+HZFURLSessionTaskStartTime.h
//  HZFHTTPProtocol
//
//  Created by huangzhifei on 2019/8/31.
//  Copyright © 2019 huangzhifei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (HZFURLSessionTaskStartTime)

@property (nonatomic, assign) NSTimeInterval hzf_startTime;

@end

NS_ASSUME_NONNULL_END
