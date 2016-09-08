//
//  UIControlItem.h
//  ChinaBrowser
//
//  Created by David on 14/10/28.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  控件项类型
 */
typedef NS_ENUM(NSInteger, ControlItemType) {
    /**
     * 菜单项
     */
    ControlItemTypeMenu,
    /**
     *  分享项
     */
    ControlItemTypeShare,
    /**
     *  翻译分类项
     */
    ControlItemTypeTrans,
    /**
     *  截图涂鸦工具栏项
     */
    ControlItemTypeScreenshot,
    /**
     *  推荐分类
     */
    ControlItemTypeRecommendCate,
    /**
     *  推荐子分类
     */
    ControlItemTypeRecommendSubCate,
    /**
     *  应用
     */
    ControlItemTypeApp,
    /**
     *  添加应用按钮
     */
    ControlItemTypeAppAdd
};

@interface UIControlItem : UIControl
{
    @protected
    UIColor *_bgColorNormal;
    UIColor *_bgColorHighlighted;
    
    UIImage *_imageNormal;
    UIImage *_imageSelected;
    UIImage *_imageHighlighted;
    
    UIColor *_textColorNormal;
    UIColor *_textColorSelected;
    UIColor *_textColorHiglighted;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageViewIcon;
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;

/**
 *  加载指定类型的xib控件
 *
 *  @param controlItemType ControlItemType
 *
 *  @return UIControlItem
 */
+ (instancetype)viewFromXibWithType:(ControlItemType)controlItemType;

- (void)setBgColorNormal:(UIColor *)normal highlighted:(UIColor *)highlighted;
- (void)setImageNormal:(UIImage *)normal highlighted:(UIImage *)highlighted selected:(UIImage *)selected;
- (void)setTextColorNormal:(UIColor *)normal highlighted:(UIColor *)highlighted;
- (void)setTextColorNormal:(UIColor *)normal highlighted:(UIColor *)highlighted selected:(UIColor *)selected;

@end
