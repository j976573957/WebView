//
//  UIWebViewController.h
//  WebView-Test
//
//  Created by xxxx on 2018/6/7.
//  Copyright © 2018年 AJ.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController

@end

@protocol ShareJsobjcetDelegate <JSExport>
- (void)share:(NSString *)message;
- (void)openCamera;
@end

@interface ShareJsObject : NSObject <ShareJsobjcetDelegate>
@property (nonatomic, weak) id shareDelegate;
@end
