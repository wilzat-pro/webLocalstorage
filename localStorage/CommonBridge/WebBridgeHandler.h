//
//  WebBridgeHandler.h
//  localStorage
//
//  Created by 许巍杰 on 2018/8/7.
//  Copyright © 2018年 xuweijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <SSZipArchive/SSZipArchive.h>

#define FILENAME @"dist"

@protocol WebBridgeDelegate <NSObject>

@optional
- (void)webBridgeWebView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

- (void)webBridgeWebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end

@interface WebBridgeHandler : NSObject

@property (nonatomic, strong)id delegate;

- (instancetype)initWithWebView:(WKWebView *)webView delegate:(id)delegate;

@end
