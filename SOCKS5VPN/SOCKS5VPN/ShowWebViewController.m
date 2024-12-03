//
//  ShowWebViewController.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "ShowWebViewController.h"
#import "CustomURLProtocol.h"
#import "MCXMacro.h"
#import <WebKit/WebKit.h>
#import <NetworkExtension/NetworkExtension.h>
#import "DataManager.h"
#import "Masonry/Masonry.h"
#import "MCXToast.h"

@interface ShowWebViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) WKWebsiteDataStore *websiteDataStore;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIProgressView *baseProgressBar;

@end

@implementation ShowWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self initNaviView];
    [self initWebView];
}

- (void)initNaviView {
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
}

- (void)initWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    
    NSString *ip = [DataManager sharedInstance].getLocalData[[DataManager sharedInstance].currentIndex].ip;
    if (!MCXStringIsNil(ip)) {
        // 创建代理主机和端口
        
        // 创建 SOCKS5 代理配置
        nw_endpoint_t proxyEndpoint = nw_endpoint_create_host([ip UTF8String], "7891");
        nw_proxy_config_t proxyConfig = nw_proxy_config_create_socksv5(proxyEndpoint);
        
        // 创建一个 WKWebsiteDataStore 并设置代理配置
        WKWebsiteDataStore *websiteDataStore = [WKWebsiteDataStore defaultDataStore];
        websiteDataStore.proxyConfigurations = @[proxyConfig];
        
        // Fallback on earlier versions
    }
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.minimumFontSize = 10; // 默认为 0
    preferences.javaScriptCanOpenWindowsAutomatically = YES; // 在 iOS 上默认为 NO
    configuration.preferences = preferences;
    
    // 设置其他配置
    configuration.allowsInlineMediaPlayback = YES; // 非全屏播放
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll; // 自动播放
    
    // 设置 web 内容处理池
    configuration.processPool = [[WKProcessPool alloc] init];
    
    // 设置通过 JS 与 WebView 内容交互
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    
    // 创建 WKWebView 实例
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    
    // 添加观察者
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置背景颜色
    self.wkWebView.backgroundColor = [UIColor whiteColor];
    self.wkWebView.scrollView.backgroundColor = [UIColor whiteColor];
    
    // 启用后退和前进手势
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    
    // iOS 9.0 及以上版本支持链接预览
    if (@available(iOS 9.0, *)) {
        self.wkWebView.allowsLinkPreview = YES;
    }
    
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(MCXNavigationFullHeight());
        make.bottom.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.baseProgressBar];
    [self.baseProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.equalTo(self.wkWebView);
        make.height.mas_equalTo(2);
    }];
    
    
    // 创建 NSURL 对象
    NSURL *baseUrl = [NSURL URLWithString:@"http://117.50.201.121:11111/jks89sdfsf.php?id=udjf89df98"];
    if (!baseUrl) {
        return;
    }
    
    // 创建 NSURLRequest 对象
    NSURLRequest *request = [NSURLRequest requestWithURL:baseUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    
    // 加载请求到 webView
    [self.wkWebView loadRequest:request];
    
}

// 更新进度条的状态
- (void)updateProgress {
    BOOL completed = (self.wkWebView.estimatedProgress == 1.0);
    
    // 设置进度条的进度值
    [self.baseProgressBar setProgress:(completed ? 0.0 : self.wkWebView.estimatedProgress) animated:!completed];
    
    // 更新网络活动指示器的显示状态
    [UIApplication sharedApplication].networkActivityIndicatorVisible = !completed;
}

// 重写 KVO 观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    // 判断是否是我们需要的 keyPath 和 WKWebView 对象
    if (![keyPath isEqualToString:@"title"] && object != self.wkWebView) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    BOOL displaysWebViewTitle = YES;
    
    // 如果需要更新标题
    if (displaysWebViewTitle && [keyPath isEqualToString:@"title"]) {
        self.title = self.wkWebView.title;
    }
    
    // 如果是估计进度的 keyPath，则更新进度
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self updateProgress];
    }
}


// 判断是否允许导航
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 判断是否允许响应导航
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 导航加载失败的处理方法
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView网页加载失败");
}

// 预加载阶段失败的处理方法
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"网页加载失败: %@", error);
    self.backButton.hidden = NO;
    [MCXToast showText:@"网页加载失败"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"网页加载完成");
    self.backButton.hidden = !webView.canGoBack;
}

// 创建 UIProgressView 属性
- (UIProgressView *)baseProgressBar {
    if (!_baseProgressBar) {
        _baseProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _baseProgressBar.backgroundColor = [UIColor clearColor];
        _baseProgressBar.trackTintColor = [UIColor clearColor];
        _baseProgressBar.progressTintColor = [UIColor colorWithRed:8.0/255.0 green:216.0/255.0 blue:138.0/255.0 alpha:1.0];
    }
    return _baseProgressBar;
}

- (void)backAction {
    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
