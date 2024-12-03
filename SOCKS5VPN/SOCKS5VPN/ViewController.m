//
//  ViewController.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "ViewController.h"
#import "CustomURLProtocol.h"
#import "Masonry/Masonry.h"
#import "BasicTableViewCell.h"
#import "DataManager.h"
#import "MCXMacro.h"
#import "NenPingManager/NENPingManager.h"
#import "NSArray+XRArray.h"
#import "ShowWebViewController.h"
#import "NENSinglePinger.h"
#import "MCXToast.h"
#import "ShowOldWebViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NENPingManager* pingManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray <IPModel *> *ipList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ipList = [DataManager sharedInstance].getLocalData;
    
    [self initViews];
    
    [self setupNavigationBarAppearance];
    
}

- (IBAction)sureButtonClick:(id)sender {
    [self.navigationController pushViewController:[[ShowWebViewController alloc] init] animated:YES];
}


- (void)setupNavigationBarAppearance {
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
    
    

    
    {
        // 创建自定义图片按钮
        UIImage *leftImage = [UIImage imageNamed:@"img_factset"];
        UIImageView *leftBarButtonImageView = [[UIImageView alloc] initWithImage:leftImage];
        
        // 设置导航栏左按钮
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButtonImageView];
        self.navigationItem.leftBarButtonItem = leftBarButton;
    }
    
    
    {
        // 创建自定义图片按钮
        UIImage *rightImage = [UIImage imageNamed:@"img_cn"];
        UIImageView *rightBarButtonImageView = [[UIImageView alloc] initWithImage:rightImage];
        rightBarButtonImageView.frame = CGRectMake(0, 0, 24, 24);
        
        UIButton *rightButton = [[UIButton alloc] init];
        [rightButton setImage:rightImage forState:UIControlStateNormal];
        [rightButton setTitle:@"简体中文" forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIBarButtonItem *rightBarButton1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButton1;
    }
}

- (void)initViews {
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderTopPadding = CGFLOAT_MIN;
    self.tableView.rowHeight = 53;
    self.tableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30 + 45 + MCXSafeAreaBottom() + 10, 0);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BasicTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"BasicTableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ipList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicTableViewCell"];
    cell.ipModel = self.ipList[indexPath.row];
    cell.isSelect = indexPath.row == [DataManager sharedInstance].currentIndex;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [DataManager sharedInstance].currentIndex = indexPath.row;
    [tableView reloadData];
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MCXScreenWidth(), MCXScreenWidth() * 174.0/341.0 + 13 + 61)];
    
    UIImageView *bannerImageView = [[UIImageView alloc] initWithImage:MCXUIImage(@"img_banner")];
    [headerView addSubview:bannerImageView];
    [bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@13);
        make.left.equalTo(@17);
        make.right.equalTo(@-17);
        make.bottom.equalTo(@-61);
    }];
    
    UILabel *label = [UILabel new];
    label.text = @"请选择线路";
    label.textColor = MCXUIColor(0x393734);
    label.font = MCXUIBoldFont(18);
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(28);
        make.top.equalTo(bannerImageView.mas_bottom).offset(25);
    }];
    
    UIButton *testButton = [UIButton new];
    [testButton setImage:MCXUIImage(@"img_ping_test") forState:UIControlStateNormal];
    [testButton setTitle:@"测速" forState:UIControlStateNormal];
    [testButton setTitleColor:MCXUIColor(0x000000) forState:UIControlStateNormal];
    testButton.titleLabel.font = MCXUIFont(14);
    [testButton addTarget:self action:@selector(pingTestButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *refreshButton = [UIButton new];
    [refreshButton setImage:MCXUIImage(@"img_refresh") forState:UIControlStateNormal];
    [refreshButton setTitle:@"更新线路" forState:UIControlStateNormal];
    [refreshButton setTitleColor:MCXUIColor(0x000000) forState:UIControlStateNormal];
    refreshButton.titleLabel.font = MCXUIFont(14);
    [refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:refreshButton];
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-17);
        make.centerY.equalTo(label);
    }];
    
    [headerView addSubview:testButton];
    [testButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(refreshButton.mas_left).offset(-18);
        make.centerY.equalTo(label);
    }];
    
    return headerView;
}

- (void)pingTestButtonClick {
    NSArray *hostNameArray = [self.ipList map:^id _Nullable(IPModel * _Nonnull obj) {
        return obj.ip;
    }];
    
    self.pingManager = [[NENPingManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self.pingManager getFatestAddress:hostNameArray completionHandler:^(NSString *hostName, NSString *fast,NSArray *sumArray) {
        
        NSLog(@"fastest IP: %@  fastest: %@ms",hostName,fast);
        NSLog(@"%@",sumArray);
        
        for (NENAddressItem *pingModel in sumArray) {
            IPModel *ipModel = [self.ipList first:^BOOL(IPModel * _Nonnull obj) {
                return [obj.ip isEqualToString:pingModel.hostName];
            }];
            
            ipModel.ping = [NSString stringWithFormat:@"%.0f", round(pingModel.delayMillSeconds)];
        }
        
        [weakSelf.tableView reloadData];
    }];
}

- (void)refreshButtonClick {
    __weak typeof(self) weakSelf = self;
    [[DataManager sharedInstance] updateDataWithCompletion:^(NSArray<IPModel *> * _Nonnull models, NSError * _Nonnull error) {
        weakSelf.ipList = models;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MCXToast showText:@"更新成功"];
            [weakSelf.tableView reloadData];
        });
    }];
}

@end
