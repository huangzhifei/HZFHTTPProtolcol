//
//  NSURLRequest+HZFRequestIncludeBody.m
//  HZFHTTPProtolcol
//
//  Created by huangzhifei on 2019/9/3.
//  Copyright © 2019 eric. All rights reserved.
//

#import "NSURLRequest+HZFRequestIncludeBody.h"

@implementation NSURLRequest (HZFRequestIncludeBody)

- (NSURLRequest *)hzf_getPostRequestIncludeBody {
    return [[self getMutablePostRequestIncludeBody] copy];
}

- (NSMutableURLRequest *)getMutablePostRequestIncludeBody {
    NSMutableURLRequest *request = [self mutableCopy];
    if ([self.HTTPMethod isEqualToString:@"POST"]) {
        if (!self.HTTPBody) {
            NSInteger maxLength = 1024;
            uint8_t d[maxLength];
            NSInputStream *stream = self.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            BOOL endOfStreamReached = NO;
            while (!endOfStreamReached) {
                NSInteger bytesRead = [stream read:d maxLength:maxLength];
                if (bytesRead == 0) { //文件读取到最后
                    endOfStreamReached = YES;
                } else if (bytesRead == -1) { //文件读取错误
                    endOfStreamReached = YES;
                } else if (stream.streamError == nil) {
                    [data appendBytes:(void *) d length:bytesRead];
                }
            }
            request.HTTPBody = [data copy];
            [stream close];
        }
    }
    return request;
}

@end
