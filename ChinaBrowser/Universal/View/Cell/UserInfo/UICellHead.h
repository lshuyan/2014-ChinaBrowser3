//
//  UICellHead.h
//  ChinaBrowser
//
//  Created by HHY on 14/10/31.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICellHead : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel  *labelSynchro;
@property (strong, nonatomic) IBOutlet UIButton *btnSynchro;



@end
