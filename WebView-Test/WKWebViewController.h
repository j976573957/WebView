//
//  WKWebViewController.h
//  WebView-Test
//
//  Created by Loovee on 2018/6/7.
//  Copyright © 2018年 AJ.com. All rights reserved.
//

@import WebKit;
#import <UIKit/UIKit.h>

@interface WKWebViewController : UIViewController

@end

@interface WeakScriptDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

