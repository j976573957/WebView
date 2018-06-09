//
//  WKWebViewController.m
//  WebView-Test
//
//  Created by Loovee on 2018/6/7.
//  Copyright © 2018年 AJ.com. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController ()<WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
{
    WKWebView *_wkWebView;
}

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWKWebView];
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
   if ([_wkWebView canGoBack]) {
        [_wkWebView goBack];
    }else{
            [_wkWebView evaluateJavaScript:@"WKOpenCamera();" completionHandler:^(id _Nullable response,  NSError * _Nullable error) {
                NSLog(@"==%@",response);
            }];
    }
}

- (NSURLRequest *)urlRequest
{
    NSString *urlStr = @"http://ksmt.loovee.com/share_test/index";
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
    NSString *signFirstStr = [NSString stringWithFormat:@"%@%@%@",timeString,@"123",@"DM23985loovee"];
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

#pragma mark - WKWebView
- (void)setupWKWebView
{
    
    WKUserContentController *contentCtrl = [[WKUserContentController alloc] init];
    [contentCtrl addScriptMessageHandler:[[WeakScriptDelegate alloc] initWithDelegate:self] name:@"jsWkShare"];
    [contentCtrl addScriptMessageHandler:[[WeakScriptDelegate alloc] initWithDelegate:self] name:@"WKOpenCamera"];
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.userContentController = contentCtrl;
    //适应
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [contentCtrl addUserScript:wkUScript];
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:conf];
    NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"java.html" ofType:nil];
    NSString *htmlStr = [NSString stringWithContentsOfFile:urlPath encoding:NSUTF8StringEncoding error:nil];
    if (!htmlStr) {
        [web loadRequest:[self urlRequest]];
    } else{
        NSURL *url = [NSURL fileURLWithPath:urlPath];//[[NSURL alloc] initWithString:urlPath];
        [web loadHTMLString:htmlStr baseURL:url];
    }
    [self.view addSubview:web];
    web.navigationDelegate = self;
    web.UIDelegate = self;
    _wkWebView = web;
}

/** 是否允许加载网页 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"WKWebView: 协议拦截");
    NSLog(@"%s", __func__);
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"url = %@",urlStr);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([urlStr containsString:@"app://showAlert"]) {
            [self clientDoAlertbyItself];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else if ([urlStr containsString:@"app://presentVC"]) {
            [self presentViewController:[TestViewController new] animated:YES completion:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

///** 在收到服务器的响应头，根据response相关信息，决定是否跳转。 */
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//    NSLog(@"WKWebView: 协议拦截");
//    NSLog(@"%s", __func__);
//}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"document.title"] completionHandler:^(id _Nullable response,  NSError * _Nullable error) {
        NSLog(@"==%@",response);
    }];
    [webView evaluateJavaScript:@"app.share();" completionHandler:^(id _Nullable response,  NSError * _Nullable error) {
        NSLog(@"==%@",response);
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"body == %@",message.body);
    NSLog(@"name == %@",message.name);
    if (message.body) {
        __weak typeof(self) weakSelf = self;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *title = [dict objectForKey:@"title"];
        NSString *desc = [dict objectForKey:@"desc"];
        NSString *shareUrl = [dict objectForKey:@"shareUrl"];
        if (!title) title = message.name;
        if (!desc) desc = message.body;
        [weakSelf jsCallClientAlertWithTitle:title message:[NSString stringWithFormat:@"%@\n%@", desc,shareUrl]];
    }
}

- (void)cleanCache
{
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    } else {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        NSURLCache * cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
        [cache setDiskCapacity:0];
        [cache setMemoryCapacity:0];
    }
}

- (void)dealloc
{
    [self cleanCache];
    NSLog(@"%s", __func__);
}

@end

@implementation WeakScriptDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

