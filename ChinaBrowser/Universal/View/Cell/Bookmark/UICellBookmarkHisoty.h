//
//  UICellSelectionFolder.h
//  ChinaBrowser
//
//  Created by HHY on 14/11/13.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellSeparatorStyle) {
    CellSeparatorStyleNone,
    CellSeparatorStyleFill,
    CellSeparatorStyleFolder
};

typedef NS_ENUM(NSInteger, CellStyle) {
    CellStyleNone,
    CellStyleFolder
};

@interface UICellBookmarkHisoty : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageVIewFolder;
@property (strong, nonatomic) IBOutlet UILabel *labelFolderTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewLeftIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelBookmarkTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelBookmarkDetail;
@property (assign, nonatomic) CellSeparatorStyle cellSeparatorStyle;
@property (assign, nonatomic) CellStyle cellStyle;

@end