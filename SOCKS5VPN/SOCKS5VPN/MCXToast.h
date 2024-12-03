//
//  MCXToast.h
//  WZCCommon
//
//  Created by zhouhao17 on 2022/10/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCXToast : NSObject

+ (void)showHUD;

///加载一个带title的HUD
+ (void)showHUDWithText:(NSString *)text;

///加载一个带title的toast 1.5秒后自动消失
+ (void)showText:(NSString *)text;
+ (void)showText:(NSString *)text willDismiss:(dispatch_block_t _Nullable)dismiss;

///加载一个带文字的hud，delay持续时间
+ (void)showHUDWithText:(NSString *)text afterDelay:(NSTimeInterval)delay;

///类似于UIActivityIndicatorView, 不会展示custom loading image
+ (void)showActivityIndicator;


+ (void)showInView:(UIView *)view text:(NSString *)text afterDelay:(NSTimeInterval)delay;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;


#pragma mark - custom image

/// 设置自定义loading图片
+ (void)setCustomLoadingImage:(UIImage * _Nullable)image size:(CGSize)size;

/// 设置自定义success图片
+ (void)setCustomSuccessImage:(UIImage * _Nullable)image size:(CGSize)size;
/// 显示成功样式toast, 未设置success image时为show text
+ (void)showSuccessMessage:(NSString *)text willDismiss:(dispatch_block_t _Nullable)dismiss;


/// 设置自定义error图片
+ (void)setCustomErrorImage:(UIImage * _Nullable)image size:(CGSize)size;
/// 显示失败样式toast, 未设置error image时为show text
+ (void)showErrorMessage:(NSString *)text willDismiss:(dispatch_block_t _Nullable)dismiss;

@end
NS_ASSUME_NONNULL_END
