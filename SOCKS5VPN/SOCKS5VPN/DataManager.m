//
//  DataManager.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "DataManager.h"

@implementation DataManager

+ (instancetype)sharedInstance {
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

// 获取本地数据或默认数据
- (NSArray<IPModel *> *)getLocalData {
    NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedData"];
    if (!localData) {
        // 默认数据
        localData = @{
            @"1": @"120.26.103.84",
            @"2": @"118.178.194.115",
            @"3": @"47.122.52.242",
            @"4": @"47.122.49.115",
            @"5": @"8.134.178.58",
            @"6": @""
        };
    }
    return [self parseDataToModels:localData];
}

// 更新数据（从接口获取并存储到本地）
- (void)updateDataWithCompletion:(void (^)(NSArray<IPModel *> *models, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:@"http://154.198.213.37:11121/api.php"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求失败: %@", error.localizedDescription);
            completion(nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![responseData isKindOfClass:[NSDictionary class]]) {
            NSLog(@"JSON解析失败: %@", jsonError.localizedDescription);
            completion(nil, jsonError);
            return;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:responseData];
        
        NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        NSString *key = [NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%@", sortedKeys.lastObject] intValue] + 1 ];
        
        [dict addEntriesFromDictionary:@{
            key : @""
        }];
        
        // 保存到本地
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"SavedData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 转换为模型数组
        NSArray<IPModel *> *models = [self parseDataToModels:dict];
        self.currentIndex = 0;
        completion(models, nil);
    }];
    
    [task resume];
}

// 将数据解析为模型数组
- (NSArray<IPModel *> *)parseDataToModels:(NSDictionary *)data {
    NSMutableArray<IPModel *> *models = [NSMutableArray array];
    
    // 按 key 的顺序排序
    NSArray *sortedKeys = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // 根据排序后的 key 顺序解析模型
    for (NSString *key in sortedKeys) {
        NSString *ip = data[key];
        IPModel *model = [[IPModel alloc] initWithName:key ip:ip];
        [models addObject:model];
    }
    
    return [models copy];
}
@end
