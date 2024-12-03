//
//  BasicTableViewCell.m
//  SOCKS5VPN
//
//  Created by Niko on 2024/11/30.
//

#import "BasicTableViewCell.h"
#import "MCXMacro.h"

@interface BasicTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *bgButton;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (weak, nonatomic) IBOutlet UILabel *lineNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *pingLabel;

@end

@implementation BasicTableViewCell

- (void)setIpModel:(IPModel *)ipModel {
    _ipModel = ipModel;
    
    self.lineNameLabel.text = [NSString stringWithFormat:@"线路%@", self.ipModel.name];
    if (!MCXStringIsNil(self.ipModel.ping)) {
        self.pingLabel.text = [NSString stringWithFormat:@"%@ms", self.ipModel.ping];
    }
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    self.bgButton.selected = isSelect;
    self.selectButton.selected = isSelect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
