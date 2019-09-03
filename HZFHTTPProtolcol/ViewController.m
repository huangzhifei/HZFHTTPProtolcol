//
//  ViewController.m
//  HZFHTTPProtolcol
//
//  Created by huangzhifei on 2019/8/31.
//  Copyright © 2019 eric. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn1 setTitle:@"NSURLSessionTask" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(onClickBtn1:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setFrame:CGRectMake(50, 100, 150, 40)];
    [self.view addSubview:btn1];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setTitle:@"NSURLSessionDownTask" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(onClickBtn2:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setFrame:CGRectMake(50, 200, 200, 40)];
    [self.view addSubview:btn2];

    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn3 setTitle:@"NSURLConnection" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(onClickBtn3:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setFrame:CGRectMake(50, 300, 150, 40)];
    [self.view addSubview:btn3];
}

- (void)onClickBtn1:(UIButton *)sender {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *str = @"https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc";
    NSURL *url = [NSURL URLWithString:str];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                            if (!error) {
                                                NSLog(@"业务1请求完成: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                            } else {
                                                NSLog(@"业务1请求出错: %@", error);
                                            }
                                        }];
    [task resume];
}

- (void)onClickBtn2:(UIButton *)sender {
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建下载路径
    NSTimeInterval time_start = [[NSDate date] timeIntervalSince1970];
    NSURL *url = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1877784-b4777f945878a0b9.jpg"];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url
                                                completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                    NSTimeInterval time_end = [[NSDate date] timeIntervalSince1970];
                                                    NSLog(@"业务2请求完成: %lfs", time_end - time_start);
                                                }];
    [task resume];
}

- (void)onClickBtn3:(UIButton *)sender {
    // 创建下载路径
    NSURL *url = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1877784-b4777f945878a0b9.jpg"];
    // NSURLConnection发送异步Get请求，该方法iOS9.0之后就废除了，推荐NSURLSession
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError) {
                               NSLog(@"业务3请求完成: %@", [UIImage imageWithData:data]);
                           }];
}

@end
