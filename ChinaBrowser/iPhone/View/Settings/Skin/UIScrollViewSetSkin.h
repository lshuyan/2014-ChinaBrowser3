//
//  UIScrollViewSetSkin.h
//  ChinaBrowser
//
//  Created by David on 14-3-17.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewSetSkinItem.h"

#import "ModelSkin.h"

@protocol UIScrollViewSetSkinDelegate;

@interface UIScrollViewSetSkin : UIScrollView
{
    
}

@property (nonatomic, weak) IBOutlet id<UIScrollViewSetSkinDelegate> delegateSetSkin;

@property (nonatomic, assign) CGFloat itemW, itemH;
@property (nonatomic, assign) CGFloat minPaddingLR, paddingTB;
@property (nonatomic, assign) CGFloat spaceX, spaceY;
@property (nonatomic, assign) BOOL edit;

@property (nonatomic, assign, readonly) SkinInfo skinInfo;

- (void)addSkinImageWithPath:(NSString *)path animated:(BOOL)animated;
- (void)selectLastSkinImage;

@end

@protocol UIScrollViewSetSkinDelegate <NSObject>

- (void)scrollViewSetSkin:(UIScrollViewSetSkin *)scrollViewSetSkin selectSkinFileIndex:(NSInteger)fileIndex isInternal:(BOOL)isInternal;
- (void)scrollViewSetSkinWillAddSkin:(UIScrollViewSetSkin *)scrollViewSetSkin;
- (void)scrollViewSetSkin:(UIScrollViewSetSkin *)scrollViewSetSkin didChangedEdit:(BOOL)edit;

@end
