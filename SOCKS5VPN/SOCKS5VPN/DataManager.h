//
//  DataManager.h
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import <Foundation/Foundation.h>
#import "IPModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

// 单例方法
+ (instancetype)sharedInstance;

@property (nonatomic, assign) NSInteger currentIndex;

- (NSArray<IPModel *> *)getLocalData;

// 更新数据（从接口获取并存储到本地）
- (void)updateDataWithCompletion:(void (^)(NSArray<IPModel *> *models, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
