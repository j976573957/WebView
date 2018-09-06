//
//  ViewController.m
//  WebView-Test
//
//  Created by xxxx on 2018/6/1.
//  Copyright © 2018年 AJ.com. All rights reserved.
//


@import JavaScriptCore;
#import "ViewController.h"
#import "UIWebViewController.h"
#import "WKWebViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (IBAction)pushToUIWebView:(id)sender {
    [self.navigationController pushViewController:[UIWebViewController new] animated:YES];
}

- (IBAction)pushToWKWebView:(id)sender {
    [self.navigationController pushViewController:[WKWebViewController new] animated:YES];
}



@end

