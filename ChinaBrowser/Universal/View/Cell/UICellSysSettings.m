//
//  UICellSysSettings.m
//  ChinaBrowser
//
//  Created by David on 14/11/18.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UICellSysSettings.h"

@implementation UICellSysSettings

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRightView:(UIView *)rightView
{
    if (_rightView) {
        [_rightView removeFromSuperview];
        _rightView = nil;
    }
    _rightView = rightView;
    [_rightView sizeToFit];
    if ([_rightView isKindOfClass:[UISwitch class]]) {
        [_rightView removeFromSuperview];
        self.accessoryView = _rightView;
    }
    else {
        self.accessoryView = nil;
        CGRect rc = _rightView.bounds;
        rc.origin.y = (self.contentView.height-rc.size.height)*0.5;
        rc.origin.x = self.contentView.width-rc.size.width-(self.accessoryType==UITableViewCellAccessoryNone?10:0);
        _rightView.frame = rc;
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:_rightView];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

+ (instancetype)cellFromXib
{
    NSString *szClass = NSStringFromClass([self class]);
    return [[NSBundle mainBundle] loadNibNamed:szClass owner:nil options:nil][0];
}

@end
