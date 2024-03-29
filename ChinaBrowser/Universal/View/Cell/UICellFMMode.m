//
//  UICellFMMode.m
//  ChinaBrowser
//
//  Created by David on 14/11/18.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UICellFMMode.h"

@implementation UICellFMMode
{
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
    self.selectedBackgroundView = view;
    
    CGRect rc = self.bounds;
    rc.size.height-=1;
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:rc];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    bgView.image = [[UIImage imageWithBundleFile:@"iPhone/FM/bg_fmmode.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self insertSubview:bgView atIndex:0];
    
    rc.size.width = 1;
    rc.origin.x = _btnRadio.left-10;
    rc.origin.y = 10;
    rc.size.height = self.height-rc.origin.y*2-1;
    UIImageView *lineV = [[UIImageView alloc] initWithFrame:rc];
    lineV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    lineV.image = [[UIImage imageWithBundleFile:@"iPhone/FM/line_v_fmmode.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:4];
    [self insertSubview:lineV aboveSubview:bgView];
    
    [_btnRadio setImage:[UIImage imageWithBundleFile:@"iPhone/FM/fn_0.png"] forState:UIControlStateNormal];
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    _DEBUG_LOG(@"%@", NSStringFromCGPoint([panGesture translationInView:self]));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}

- (void)updateBtnRadioImageWithSelect:(BOOL)select
{
    _btnRadio.selected = select;
    if (select) {
        [_btnRadio setImage:[UIImage imageWithBundleFile:@"iPhone/FM/fn_2.png"] forState:UIControlStateNormal];
    }
    else {
        [_btnRadio setImage:[UIImage imageWithBundleFile:@"iPhone/FM/fn_0.png"] forState:UIControlStateNormal];
    }
}

@end
