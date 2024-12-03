//
//  SCMacro.m
//  WZCCommon
//
//  Created by zhouhao17 on 2023/3/10.
//


#import <pthread.h>
#import "MCXMacro.h"


#pragma mark - 线程
void dispatch_async_on_main_queue(void (^ _Nullable block)(void)){
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void dispatch_async_on_new_queue(const char *_Nullable queueName, void (^ _Nullable block)(void)){
    dispatch_async(dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT), block);
}

void dispatch_async_on_running_queue(dispatch_queue_t _Nullable queue, void (^ _Nullable block)(void)){
    dispatch_async(queue, block);
}

void dispatch_async_on_global_queue(void (^ _Nullable block)(void)){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


#pragma mark - 字符串
BOOL MCXStringIsNil(NSString *text) {
    if (![text isKindOfClass:[NSString class]] || [text isEqual:[NSNull class]] || text == nil || text.length <= 0) {
        return YES;
    }
    return NO;
}

#pragma mark - 安全
NSString * _Nullable MCXSafeString(NSString * _Nullable text) {
    if (MCXStringIsNil(text)) {
        return @"";
    } else {
        return text;
    }
}

NSString * _Nullable MCXSafeStringWithDefault(NSString * _Nullable text, NSString * _Nullable defaultText) {
    if (MCXStringIsNil(text)) {
        return defaultText;
    } else {
        return text;
    }
}

NSArray * _Nullable MCXSafeArray(NSArray * _Nullable arr) {
    if ([arr isEqual:[NSNull class]] || arr == nil) {
        return @[];
    }
    if ([arr isKindOfClass:[NSArray class]] || [arr isKindOfClass:[NSMutableArray class]]) {
        return arr;
    } else {
        return @[];
    }
}

NSDictionary * _Nullable MCXSafeDictionary(NSDictionary * _Nullable dic) {
    if ([dic isEqual:[NSNull class]] || dic == nil) {
        return @{};
    }
    if ([dic isKindOfClass:[NSDictionary class]] || [dic isKindOfClass:[NSMutableDictionary class]]) {
        return dic;
    } else {
        return @{};
    }
}

BOOL BDNumberIsNil(NSNumber * num){
    if (!num ||
        [num isEqual:[NSNull null]] ||
        ![num isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}

NSNumber *MCXSafeNumberWithDefault(NSNumber *num, NSNumber *defaultNum){
    if (BDNumberIsNil(num)) {
        return defaultNum;
    } else {
        return num;
    }
}

NSNumber *MCXSafeNumber(NSNumber *num){
    return MCXSafeNumberWithDefault(num, @(0));
}


#pragma mark - UI宽高
/// 获取当前window
UIWindow * MCXKeyWindow(void) {
    if (@available(iOS 13.0, *)) {
        UIWindowScene * windowScene;
        for (UIWindowScene * scene in UIApplication.sharedApplication.connectedScenes) {
                windowScene = scene;
        }
        
        if (windowScene) {
            if (@available(iOS 15.0, *)) {
                return windowScene.keyWindow;;
            } else if(windowScene.windows.count > 0){
                for (UIWindow * window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
        return UIApplication.sharedApplication.keyWindow;
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
}

UIEdgeInsets MCXSafeAreaInset(void) {
    if (@available(iOS 11.0, *)) {
        return MCXKeyWindow().safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

/// 顶部安全区域
CGFloat MCXSafeAreaTop(void) {
    return MCXSafeAreaInset().top;
}

/// 底部安全区域
CGFloat MCXSafeAreaBottom(void) {
    return MCXSafeAreaInset().bottom;
}

/// 导航栏高度
CGFloat MCXNavigationBarHeight(void) {
    return 44.f;
}

/// 状态栏高度
CGFloat MCXStatusBarHeight(void) {
    if (@available(iOS 13.0, *)) {
//        NSSet *set = [UIApplication sharedApplication].connectedScenes;
//        UIWindowScene *windowScene = [set anyObject];
//        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
//        return statusBarManager.statusBarFrame.size.height;
        
        /// 灵动岛机型, statusBarFrame与实际状态栏高度有出入
        /// eg.iPhone 14 Pro statusBarFrame.height = 54, safeAreaInset.top = 59
        return MCXSafeAreaTop();
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

/// 导航栏 + 状态栏 高度
CGFloat MCXNavigationFullHeight(void) {
    return MCXNavigationBarHeight() + MCXStatusBarHeight();
}

/// 底部tabbar高度
CGFloat MCXTabbarHeight(void) {
    return 49.f;
}

/// 底部tabbar高度 + 安全区域高度
CGFloat MCXTabbarFullHeight(void) {
    return MCXTabbarHeight() + MCXSafeAreaBottom();
}

/// 手机屏幕高度
CGFloat MCXScreenHeight(void) {
    return [UIScreen mainScreen].bounds.size.height;
}

/// 手机屏幕宽度
CGFloat MCXScreenWidth(void) {
    return [UIScreen mainScreen].bounds.size.width;
}


#pragma mark - Colors
UIColor * _Nullable BDColorWithRGBA(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [UIColor colorWithRed:(red)/255.0f green:(green)/255.0f blue:(blue)/255.0f alpha:(alpha)];
}

UIColor * _Nullable MCXUIColorWithAlpha(unsigned int colorHex, CGFloat alpha) {
    return BDColorWithRGBA((float)((colorHex & 0xFF0000) >> 16), (float)((colorHex & 0xFF00) >> 8), (float)((colorHex & 0xFF)), alpha);
}

UIColor * _Nullable MCXUIColor(unsigned int colorHex) {
    return MCXUIColorWithAlpha(colorHex, 1.f);
}


UIColor * _Nullable MCXUIColorString(NSString * _Nonnull colorString) {
    NSString *cString = [colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }

    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }

    if ([cString length] != 6) {
        return [UIColor clearColor];
    }

    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1.f];

}

UIColor * _Nullable MCXUIClearColor(void) {
    return [UIColor clearColor];
}

UIColor * _Nullable MCXUIRandomColor(void) {
    CGFloat red = arc4random() % 255;
    CGFloat green = arc4random() % 255;
    CGFloat blue = arc4random() % 255;
    return BDColorWithRGBA(red, green, blue, 1.f);
}

#pragma mark - Font
UIFont * _Nullable MCXUIFontStandard(CGFloat fontName, BOOL bold, BOOL weight) {
    if (bold) {
        return [UIFont boldSystemFontOfSize:fontName];
    }
    if (weight) {
        return [UIFont systemFontOfSize:fontName weight:UIFontWeightMedium];
    }
    return [UIFont systemFontOfSize:fontName];
}

UIFont * _Nullable MCXUIFont(NSInteger size) {
    return MCXUIFontStandard(size, NO, NO);
}

UIFont * _Nullable MCXUIBoldFont(NSInteger size) {
    return MCXUIFontStandard(size, YES, NO);
}

UIFont * _Nullable MCXUIWeightFont(NSInteger size) {
    return MCXUIFontStandard(size, NO, YES);
}

UIFont * _Nullable MCXUIFontWithName(NSString * _Nonnull name, CGFloat size) {
    return [UIFont fontWithName:name size:size];
}

/**
 根据屏幕宽度动态调整字体大小
 以375尺寸为准，iPhone 6(s)、7、8、X、Xs、11、12、13 mini
 */
UIFont * _Nullable MCXUIDynamicFont(NSInteger size) {
    CGFloat fSize = size;
    CGFloat screenWidth = MCXScreenWidth();
    if (screenWidth < 375.f) {
        fSize -= 2;
    } else if (screenWidth > 375.f) {
        fSize += 2;
    }
    return MCXUIFont(fSize);
}

#pragma mark - Images
UIImage * _Nullable MCXUIImage(NSString * _Nonnull imageName) {
    UIImage *img = [UIImage imageNamed:imageName];
    return img;
}

#pragma mark - 设备判断
/// 是否是iPhone机型
BOOL MCXisiPhone(void) {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return YES;
    }
    return NO;
}

/// 此iPhone是否是刘海屏
BOOL MCXisiPhoneX(void) {
    return MCXisiPhone() && MCXSafeAreaBottom() > 0;
}

#pragma mark - 扩展工具
NSComparisonResult MCXCompareVersion(NSString * _Nonnull versionOne, NSString * _Nonnull versionTwo) {
    NSMutableArray<NSString *> *oneComponents = [NSMutableArray arrayWithArray:[MCXSafeString(versionOne) componentsSeparatedByString:@"."]];
    NSMutableArray<NSString *> *twoComponents = [NSMutableArray arrayWithArray:[MCXSafeString(versionTwo) componentsSeparatedByString:@"."]];
    
    NSUInteger maxCount;
    NSMutableArray<NSString *> *lessComponents;
    if (oneComponents.count > twoComponents.count) {
        maxCount = oneComponents.count;
        lessComponents = twoComponents;
    } else {
        maxCount = twoComponents.count;
        lessComponents = oneComponents;
    }
    
    for (NSUInteger i = lessComponents.count; i < maxCount; i++) {
        [lessComponents addObject:@"0"];
    }
    
    return [[oneComponents componentsJoinedByString:@"."] compare:[twoComponents componentsJoinedByString:@"."] options:NSNumericSearch];
}


NSString *MCXConvertJSONObjectToJSONString(id object, NSError **error) {
    if (![object isKindOfClass:[NSDictionary class]] &&
        ![object isKindOfClass:[NSArray class]] &&
        ![object isKindOfClass:[NSString class]]) {
        return @"";
    }
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
    return MCXSafeString([[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}
