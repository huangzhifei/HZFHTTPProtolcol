//
//  NSURLRequest+HZFRequestIncludeBody.h
//  HZFHTTPProtolcol
//
//  Created by huangzhifei on 2019/9/3.
//  Copyright © 2019 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (HZFRequestIncludeBody)

- (NSURLRequest *)hzf_getPostRequestIncludeBody;

@end

NS_ASSUME_NONNULL_END
