//
//  ViewController.m
//  localStorage
//
//  Created by 许巍杰 on 2018/5/22.
//  Copyright © 2018年 xuweijie. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <SSZipArchive/SSZipArchive.h>

#define FILENAME @"dist"

@interface ViewController ()<WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIActivityIndicatorView *activity;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContentWebView];
}

- (void)setupContentWebView {
    //  1.  创建webview
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    //  2.  获取文件路径
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *resPath = [docPaths.firstObject stringByAppendingString:@"/www"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //  2.1 判断路径下是否有文件
    if (![fileMgr fileExistsAtPath:resPath]) {
        //  2.2 将工程目录中的文件复制到路径下
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:FILENAME ofType:@"zip"];
        NSError*error;
        
        BOOL success = [SSZipArchive unzipFileAtPath:bundlePath toDestination:resPath];
        
        if (!success) {
            NSLog(@"error: %@", error);
            return;
        }
        
    }
    
    // 3   载入文件
    NSString *filepath = [NSString stringWithFormat:@"file://%@/%@/index.html", resPath, FILENAME];
    NSLog(@"path----- %@", filepath);
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: filepath]]];
    [webView loadFileURL:[NSURL fileURLWithPath: filepath] allowingReadAccessToURL:[NSURL fileURLWithPath: resPath]];
    [self createActivityIndicator:webView];
    
}

- (void)createActivityIndicator:(WKWebView *)webView{
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [webView addSubview:self.activity];
    CGSize size = [UIScreen mainScreen].bounds.size;
    //设置小菊花的frame
    self.activity.frame= CGRectMake(0, 0, 60, 60);
    self.activity.center = CGPointMake(size.width*0.5, size.height*0.4);
    self.activity.backgroundColor = [UIColor grayColor];
    self.activity.alpha = 0.8;
    [self.activity.layer setCornerRadius:5];
}

#pragma mark: --delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"开始载入...");
    [self.activity startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"载入完成");
    [self.activity stopAnimating];
}



@end
