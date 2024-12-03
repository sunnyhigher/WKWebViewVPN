//
//  SCMacro.h
//  WZCCommon
//
//  Created by zhouhao17 on 2023/3/10.
//
#import <UIKit/UIKit.h>


//  基础宏定义
#pragma mark - 线程

///在主线程运行代码
extern inline void dispatch_async_on_main_queue(void (^ _Nullable block)(void));


///创建一个子线程
extern inline void dispatch_async_on_new_queue(const char *_Nullable queueName, void (^ _Nullable block)(void));

///使用一个固有线程Queue
extern inline void dispatch_async_on_running_queue(dispatch_queue_t _Nullable queue, void (^ _Nullable block)(void));

///在全局线程中执行代码
extern inline void dispatch_async_on_global_queue(void (^ _Nullable block)(void));

#pragma mark - 字符串处理
extern inline BOOL MCXStringIsNil(NSString * _Nullable text);


extern inline NSString * _Nullable MCXUIString(NSString * _Nonnull stringName);

#pragma mark - 安全类型
extern inline NSString * _Nullable MCXSafeString(NSString * _Nullable text);

extern inline NSString * _Nullable MCXSafeStringWithDefault(NSString * _Nullable text, NSString * _Nullable defaultText);

extern inline NSArray * _Nullable MCXSafeArray(NSArray * _Nullable arr);

extern inline NSDictionary * _Nullable MCXSafeDictionary(NSDictionary * _Nullable dic);

extern inline NSNumber * _Nullable MCXSafeNumber(NSNumber * _Nullable num);

#pragma mark - UI宽高
/// 获取当前window
extern inline UIWindow * _Nullable MCXKeyWindow(void);
/// 安全区域
extern inline UIEdgeInsets MCXSafeAreaInset(void);

/// 顶部安全区域
extern inline CGFloat MCXSafeAreaTop(void);

/// 底部安全区域
extern inline CGFloat MCXSafeAreaBottom(void);

/// 导航栏高度
extern inline CGFloat MCXNavigationBarHeight(void);

/// 状态栏高度
extern inline CGFloat MCXStatusBarHeight(void);

/// 导航栏 + 状态栏 高度
extern inline CGFloat MCXNavigationFullHeight(void);

/// 底部tabbar高度
extern inline CGFloat MCXTabbarHeight(void);

/// 底部tabbar高度 + 安全区域高度
extern inline CGFloat MCXTabbarFullHeight(void);

/// 手机屏幕高度
extern inline CGFloat MCXScreenHeight(void);

/// 手机屏幕宽度
extern inline CGFloat MCXScreenWidth(void);


#pragma mark - Colors
extern inline UIColor * _Nullable MCXUIColorWithAlpha(unsigned int colorHex, CGFloat alpha);

extern inline UIColor * _Nullable MCXUIColor(unsigned int colorHex);

extern inline UIColor * _Nullable MCXUIColorString(NSString * _Nonnull colorString);

extern inline UIColor * _Nullable MCXUIClearColor(void);

extern inline UIColor * _Nullable MCXUIRandomColor(void);

#pragma mark - Fonts
extern inline UIFont * _Nullable MCXUIFont(NSInteger size);

extern inline UIFont * _Nullable MCXUIBoldFont(NSInteger size);

extern inline UIFont * _Nullable MCXUIWeightFont(NSInteger size);

extern inline UIFont * _Nullable MCXUIFontWithName(NSString * _Nonnull name, CGFloat size);

/**
 根据屏幕宽度动态调整字体大小
 以375尺寸为准，iPhone 6(s)、7、8、X、Xs、11、12、13 mini
 */
extern inline UIFont * _Nullable MCXUIDynamicFont(NSInteger size);

#pragma mark - Images
extern inline UIImage * _Nullable MCXUIImage(NSString * _Nonnull imageName);

#pragma mark - 设备判断
/// 是否是iPhone机型
extern inline BOOL MCXisiPhone(void);

/// 此iPhone是否是刘海屏
extern inline BOOL MCXisiPhoneX(void);

#pragma mark - Blocks
typedef void (^MCXEXTVoidCallback) (void);

typedef void (^MCXEXTObjectCallback) (id _Nullable object);

typedef void (^MCXEXTErrorCallback) (NSError * _Nullable error);

typedef void (^MCXEXTDataResultCallback) (id _Nullable object, NSError * _Nullable error);

