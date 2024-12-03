//
//  ShowWebViewController.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "ShowOldWebViewController.h"
#import "CustomURLProtocol.h"
#import "MCXMacro.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <WebKit/WKProcessPool.h>


@interface ShowOldWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;

//@property (nonatomic, strong) UIProgressView *progressView;
//@property (nonatomic, assign) BOOL isWebViewLoading;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ShowOldWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置缓存机制
    [self setupURLCache];
    
    // 移除导航栏透明状态
    // 创建导航栏外观配置对象
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground]; // 设置为不透明背景
    
    // 设置背景颜色
    appearance.backgroundColor = [UIColor whiteColor]; // 替换为你需要的颜色
    
    appearance.shadowColor = [UIColor clearColor];
    
    // 设置标题样式
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor], // 标题文字颜色
        NSFontAttributeName: [UIFont boldSystemFontOfSize:18] // 标题文字字体
    };
    
    // 将外观应用到导航栏
    self.navigationController.navigationBar.standardAppearance = appearance; // 常规状态
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance; // 滚动状态
    self.navigationController.navigationBar.compactAppearance = appearance; // 紧凑状态（可选，iPhone横屏时）
    
    // 启用大标题（如果需要）
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    // 隐藏系统返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 创建自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.hidden = YES;
    self.backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"icon_navi_back"] forState:UIControlStateNormal]; // 自定义图标
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // 设置文字颜色
    backButton.titleLabel.font = [UIFont systemFontOfSize:16]; // 设置文字字体
    [backButton sizeToFit];
    
    // 设置返回按钮点击事件
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加到导航栏左侧
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customBackButton;
    
    
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    
    /// 创建并初始化 UIWebView
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, MCXNavigationFullHeight(), MCXScreenWidth(), MCXScreenHeight() - MCXNavigationFullHeight())];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    // 加载 URL
    [self loadRequest];
}

// 加载 URL 请求
- (void)loadRequest {
    NSURL *url = [NSURL URLWithString:@"http://117.50.201.121:11111/jks89sdfsf.php?id=udjf89df98"]; // 替换为实际网址
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    // 检查缓存是否命中
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedResponse) {
        NSLog(@"缓存命中，加载缓存内容...");
    } else {
        NSLog(@"无缓存，加载网络内容...");
    }
    
    [self.webView loadRequest:request];
}

// UIWebViewDelegate 方法 - 网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"网页加载完成");
    
    // 输出当前缓存使用情况
    NSUInteger currentDiskUsage = [[NSURLCache sharedURLCache] currentDiskUsage];
    NSUInteger currentMemoryUsage = [[NSURLCache sharedURLCache] currentMemoryUsage];
    NSLog(@"当前缓存使用情况 - 磁盘: %lu KB，内存: %lu KB", currentDiskUsage / 1024, currentMemoryUsage / 1024);
}

// UIWebViewDelegate 方法 - 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"网页加载失败: %@", error.localizedDescription);
}

// 返回按钮点击事件
- (void)backAction {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)dealloc {
    // 停止代理服务
    // 注销 CustomURLProtocol
    [NSURLProtocol unregisterClass:[CustomURLProtocol class]];
}

// 配置缓存机制
- (void)setupURLCache {
    NSUInteger memoryCapacity = 10 * 1024 * 1024; // 10MB 内存缓存
    NSUInteger diskCapacity = 50 * 1024 * 1024;  // 50MB 磁盘缓存
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity
                                                         diskCapacity:diskCapacity
                                                             diskPath:@"URLCache"];
    [NSURLCache setSharedURLCache:urlCache];
    NSLog(@"URLCache 设置成功，内存容量: %lu KB，磁盘容量: %lu KB", memoryCapacity / 1024, diskCapacity / 1024);
}
@end
