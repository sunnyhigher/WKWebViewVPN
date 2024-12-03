//
//  MCXToast.m
//  WZCCommon
//
//  Created by zhouhao17 on 2022/10/14.
//

#import "MCXToast.h"
#import "MBProgressHUD.h"
#import "MCXMacro.h"

/// 根据主工程是否导入YYImage选择imageView, 优先使用YYAnimatedImageView
#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
static NSString * _customImageViewClassName = @"YYAnimatedImageView";
#elif __has_include("YYImage.h")
#import "YYImage.h"
static NSString * _customImageViewClassName = @"YYAnimatedImageView";
#else
static NSString * _customImageViewClassName = @"UIImageView";
#endif

static CGFloat FONT_SIZE = 14.0f;
@implementation MCXToast

+ (MBProgressHUD *)getHud{
    return [self getHudForView:MCXKeyWindow()];
}

+ (MBProgressHUD *)getHudForView:(UIView *)superview {
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:superview];
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:superview animated:YES];
    }
    HUD.mode = MBProgressHUDModeText;
    HUD.animationType = MBProgressHUDAnimationFade;
    HUD.userInteractionEnabled = YES;
    [superview bringSubviewToFront:HUD];
    return HUD;
}

+ (void)showHUD{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        [self configCustomLoadingImageForHud:HUD];
    });
}

+ (void)showHUDWithText:(NSString *)text{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        [self configCustomLoadingImageForHud:HUD];
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:FONT_SIZE];
    });
}

+ (void)showText:(NSString *)text{
    [self showText:text willDismiss:nil];
}

+ (void)showText:(NSString *)text willDismiss:(dispatch_block_t)dismiss {
    NSTimeInterval duration = [self toastDuration:text];
    if (dismiss) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dismiss();
        });
    }
    
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:FONT_SIZE];
        HUD.customView = nil;
        HUD.color = [UIColor colorWithWhite:0 alpha:0.9f];
        [HUD hide:YES afterDelay:duration];
    });
}

+ (void)showHUDWithText:(NSString *)text afterDelay:(NSTimeInterval)delay{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        [self configCustomLoadingImageForHud:HUD];
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:FONT_SIZE];
        [HUD hide:YES afterDelay:delay];
    });
}

+ (void)showActivityIndicator{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.customView = nil;
    });
}

+ (void)showInView:(UIView *)view text:(NSString *)text afterDelay:(NSTimeInterval)delay{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHudForView:view];
        [self configCustomLoadingImageForHud:HUD];
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:FONT_SIZE];
        [HUD hide:YES afterDelay:delay];
    });
}

+ (void)hideHUD{
    [self hideHUDForView:MCXKeyWindow()];
}

+ (void)hideHUDForView:(UIView *)view {
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [MBProgressHUD HUDForView:view];
        [HUD hide:YES];
    });
}

/// 获取当前hud显示时间
+ (NSTimeInterval)toastDuration:(NSString *)text {
    NSTimeInterval duration = 1.f;
    NSTimeInterval offset = text.length * 1.0 / 10;
    return duration + offset;
}

#pragma mark - custom loading
static UIImage * _customLoadingImage;
static CGSize _customLoadingSize;
+ (void)setCustomLoadingImage:(UIImage *)image size:(CGSize)size {
    _customLoadingImage = image;
    _customLoadingSize = size;
}


+ (void)configCustomLoadingImageForHud:(MBProgressHUD *)hud {
    if (_customLoadingImage != nil && _customLoadingSize.width > 0 && _customLoadingSize.height > 0) {
        hud.mode = MBProgressHUDModeCustomView;
        
        Class class = NSClassFromString(_customImageViewClassName);
        __kindof UIImageView * imageView = [[class alloc] initWithImage:_customLoadingImage];
        imageView.frame = CGRectMake(0, 0, _customLoadingSize.width, _customLoadingSize.height);
        hud.customView = imageView;
        hud.color = [UIColor whiteColor];
        
        CALayer * layer = hud.layer;
        layer.shadowColor = UIColor.blackColor.CGColor;
        layer.shadowOffset = CGSizeMake(2, 2);
        layer.shadowOpacity = 0.05f;
        layer.shadowRadius = hud.cornerRadius;
        
    } else {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.customView = nil;
    }
}


#pragma mark - success & error
/// 显示成功/失败
+ (void)showToastWithText:(NSString *)text image:(UIImage * _Nullable)image imageSize:(CGSize)imageSize willDismiss:(dispatch_block_t)dismiss {
    if (image != nil && imageSize.width > 0 && imageSize.height > 0) {
        
    } else {
        /// 未设置, 转show text
        [self showText:text willDismiss:dismiss];
        return;
    }
    
    NSTimeInterval duration = [self toastDuration:text];
    if (dismiss) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dismiss();
        });
    }
    
    dispatch_async_on_main_queue(^{
        MBProgressHUD *HUD = [self getHud];
        HUD.detailsLabelText = [NSString stringWithFormat:@"%@", text];
        HUD.detailsLabelFont = [UIFont systemFontOfSize:FONT_SIZE];
        HUD.color = [UIColor colorWithWhite:0 alpha:0.9f];
        
        HUD.mode = MBProgressHUDModeCustomView;
        /// 图片容器+间距
        UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height + 10)];
        HUD.customView = customView;
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        [customView addSubview:imageView];
        
        [HUD hide:YES afterDelay:duration];
    });
}

static UIImage * _customSuccessImage;
static CGSize _successImageSize;

+ (void)setCustomSuccessImage:(UIImage *)image size:(CGSize)size {
    _customSuccessImage = image;
    _successImageSize = size;
}


+ (void)showSuccessMessage:(NSString *)text willDismiss:(dispatch_block_t)dismiss {
    [self showToastWithText:text image:_customSuccessImage imageSize:_successImageSize willDismiss:dismiss];
}

static UIImage * _customErrorImage;
static CGSize _errorImageSize;
+ (void)setCustomErrorImage:(UIImage *)image size:(CGSize)size {
    _customErrorImage = image;
    _errorImageSize = size;
}

+ (void)showErrorMessage:(NSString *)text willDismiss:(dispatch_block_t)dismiss {
    [self showToastWithText:text image:_customErrorImage imageSize:_errorImageSize willDismiss:dismiss];
}



@end
