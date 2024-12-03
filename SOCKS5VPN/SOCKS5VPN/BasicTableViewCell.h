//
//  BasicTableViewCell.h
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import <UIKit/UIKit.h>
#import "IPModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BasicTableViewCell : UITableViewCell

@property (nonatomic, strong) IPModel *ipModel;

@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
