//
//  ViewController.m
//  localStorage
//
//  Created by 许巍杰 on 2018/5/22.
//  Copyright © 2018年 xuweijie. All rights reserved.
//

#import "ViewController.h"
#import "WebBridgeHandler.h"

#import <WKWebViewJavascriptBridge.h>
#import <WebKit/WebKit.h>



@interface ViewController ()

@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIActivityIndicatorView *activity;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupContentWebView];
    
    [self loadServerWebView];
//    初始化webBridge框架
    WebBridgeHandler *bridgeHandler = [[WebBridgeHandler alloc] initWithWebView:self.webView delegate:self];;
    
    
}

- (void)loadServerWebView {
    //  1.  创建webview
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView = webView;
    
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]]];
    [self createActivityIndicator:webView];
}

- (void)loadRequestWithWebView:(WKWebView *)webView{
    //  创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/#/"]];
    [webView loadRequest:request];
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





@end
