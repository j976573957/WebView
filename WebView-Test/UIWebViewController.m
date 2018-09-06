//
//  UIWebViewController.m
//  WebView-Test
//
//  Created by xxxx on 2018/6/7.
//  Copyright © 2018年 AJ.com. All rights reserved.
//

@import JavaScriptCore;
#import "UIWebViewController.h"

@interface UIWebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    JSContext *_content;
}

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIWebView];
    [self setupBackButton];
}

- (void)setupBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH -44, 20, 44, 44);
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"block" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else{
        NSString *jsonStr = [_webView stringByEvaluatingJavaScriptFromString:@"jsShare();"];
        NSLog(@"jsonStr = %@", jsonStr);
        if (jsonStr.length > 0) {
            [self jsCallclientAlert];
        }else{
        // block 方式
        JSContext *context = [[JSContext alloc] init];
        // 定义一个block
        context[@"jsShare"] = ^() {
            [self jsCallclientAlert];
        };
        // 调用js执行jsShare方法
        JSValue *value = [context evaluateScript:@"jsShare();"];
        NSLog(@"value = %@", value.context);
        }
    }
}

- (NSURLRequest *)urlRequest
{
    NSString *urlStr = @"http://ksmt.xxxx.com/share_test/index";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    
    [dict setObject:@"123" forKey:@"username"];
    [dict setObject:@"true" forKey:@"isapp"];
    [dict setObject:@"ios" forKey:@"os"];
    [dict setObject:[NSString stringWithFormat:@"%@",@"v1.4.2"] forKey:@"version"];
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    NSInteger rand10_num = arc4random()%9000000000 + 1000000000;
    NSString *signFirstStr = [NSString stringWithFormat:@"%@%@%@",timeString,@"123",@"DM23985xxxx"];
    NSString * md5First = [signFirstStr md5];
    NSString * singSecStr = [NSString stringWithFormat:@"%@%zd",md5First,rand10_num];
    NSString * md5SignStr = [singSecStr md5];
    [dict setObject:timeString forKey:@"timestamp"];
    [dict setObject:[NSString stringWithFormat:@"%zd",rand10_num] forKey:@"key"];
    [dict setObject:md5SignStr forKey:@"sign"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:dict];
    return request;
}

/** 客户端手动调用弹窗 */
- (void)clientDoAlertbyItself
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"客户端手动调用弹窗" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVC animated:YES completion:nil];
    UIAlertAction *okItem = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okItem];
}

/** js调用客户端弹窗 */
- (void)jsCallclientAlert
{
    [self jsCallClientAlertWithTitle:@"提示" message:@"js调用客户端弹窗"];
}

- (void)jsCallClientAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVC animated:YES completion:nil];
    UIAlertAction *okItem = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okItem];
}

#pragma mark - UIWebView
- (void)setupUIWebView
{
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //    [web loadRequest:[self urlRequest]];
    web.delegate = self;
    [self.view addSubview:web];
    _webView = web;
    //
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"java" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *url = [[NSURL alloc] initWithString:filePath];
    [_webView loadHTMLString:htmlString baseURL:url];
}

/** 代理 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"UIWebView: 协议拦截");
    NSString *urlStr = request.URL.absoluteString;
    NSLog(@"url = %@",urlStr);
    if ([urlStr containsString:@"app://showAlert"]) {
        [self clientDoAlertbyItself];
        return NO;
    } else if ([urlStr containsString:@"app://presentVC"]) {
        [self presentViewController:[TestViewController new] animated:YES completion:nil];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"UIWebView:   %s", __func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"UIWebView:   %s", __func__);
    // 注入模型使用代理  方式
    //注入js函数
    _content = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ShareJsObject *test = [ShareJsObject new];
    test.shareDelegate = self;
    _content[@"client"] = test;
    /*
     *  oc调用js 异常时
     *  例如 oc调用js 函数不存在
     */
    _content.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"toString === %@", exception.toString);
    };
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"UIWebView:   %s", __func__);
}

- (void)cleanAllCacheAndCookie{
    NSLog(@"%s", __func__);
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

- (void)dealloc
{
    [self cleanAllCacheAndCookie];
    NSLog(@"%s", __func__);
}

@end

@implementation ShareJsObject

- (void)share:(NSString *)message
{
    NSLog(@"ShareJsObject:   %s", __func__);
    NSLog(@"message = %@", message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *title = [dict objectForKey:@"title"];
    NSString *desc = [dict objectForKey:@"desc"];
    NSString *shareUrl = [dict objectForKey:@"shareUrl"];
    [_shareDelegate jsCallClientAlertWithTitle:title message:[NSString stringWithFormat:@"%@\n%@", desc,shareUrl]];
}

- (void)openCamera
{
    NSLog(@"%s", __func__);
    [_shareDelegate jsCallclientAlert];
}



@end
