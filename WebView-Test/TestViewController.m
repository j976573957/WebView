//
//  TestViewController.m
//  WebView-Test
//
//  Created by Loovee on 2018/6/5.
//  Copyright © 2018年 AJ.com. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
    self.view.backgroundColor = [UIColor brownColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
