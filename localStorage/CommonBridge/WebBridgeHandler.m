//
//  WebBridgeHandler.m
//  localStorage
//
//  Created by 许巍杰 on 2018/8/7.
//  Copyright © 2018年 xuweijie. All rights reserved.
//

#import "WebBridgeHandler.h"
#import <WKWebViewJavascriptBridge.h>

@interface WebBridgeHandler()<WKNavigationDelegate, WKUIDelegate>


@property (nonatomic)WKWebViewJavascriptBridge                  *bridge;

@property (nonatomic, strong)WKWebView                          *webView;

@end

@implementation WebBridgeHandler

- (instancetype)initWithWebView:(WKWebView *)webView delegate:(id)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
        self.webView = webView;
//        初始化
        [self initJSBridge];
    }
    return self;
}

- (void)initJSBridge {
    //初始化  WebViewJavascriptBridge
    if (_bridge) { return; }
    NSLog(@"initial");
    [WKWebViewJavascriptBridge enableLogging];
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    //申明js调用oc方法的处理事件，这里写了后，h5那边只要请求了，oc内部就会响应
    [self JS2OC];
    
    //oc调用js的方法
    [self OC2JS];
}

-(void)JS2OC{
    /*
     含义：JS调用OC
     @param registerHandler 要注册的事件名称(比如这里我们为loginAction)
     @param handel 回调block函数 当后台触发这个事件的时候会执行block里面的代码
     */
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"loginAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        // data js页面传过来的参数  假设这里是用户名和姓名，字典格式
        NSLog(@"JS调用OC，并传值过来");
        
        // 利用data参数处理自己的逻辑
        NSDictionary *dict = (NSDictionary *)data;
        NSString *str = [NSString stringWithFormat:@"用户名：%@  姓名：%@",dict[@"userId"],dict[@"name"]];
        [weakSelf renderButtons:str];
        
        // responseCallback 给js的回复`
        responseCallback([NSString stringWithFormat:@"报告，oc已收到js的请求: %@", str]);
    }];
}

/**
 OC  调用  JS
 */
-(void)OC2JS{
    /*
     含义：OC调用JS
     @param callHandler 商定的事件名称,用来调用网页里面相应的事件实现
     @param data id类型,相当于我们函数中的参数,向网页传递函数执行需要的参数
     注意，这里callHandler分3种，根据需不需要传参数和需不需要后台返回执行结果来决定用哪个
     */
    
    //    [_bridge callHandler:@"registerAction" data:@"我是oc请求js的参数"];
    [_bridge callHandler:@"registerAction" data:@"uid:123 pwd:123" responseCallback:^(id responseData) {
        NSLog(@"oc请求js后接受的回调结果：%@",responseData);
    }];
    
}

- (void)renderButtons:(NSString *)str {
    NSLog(@"JS调用OC，取到参数为： %@",str);
    
}

#pragma mark: --delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webBridgeWebView:didStartProvisionalNavigation:)]) {
        [self.delegate webBridgeWebView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webBridgeWebView:didFinishNavigation:)]) {
        [self.delegate webBridgeWebView:webView didFinishNavigation:navigation];
    }
}

/// alert的处理
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    if ([self.delegate isKindOfClass:[UIViewController class]]) {
        [self.delegate presentViewController:alert animated:YES completion:nil];
    }else{
        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

@end
