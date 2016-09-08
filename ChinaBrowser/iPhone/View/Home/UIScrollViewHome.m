//
//  UIScrollViewHome.m
//  ChinaBrowser
//
//  Created by David on 14-9-27.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIScrollViewHome.h"

#import "UITableViewMode.h"

@implementation UIScrollViewHome

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    _DEBUG_LOG(@"%s", __FUNCTION__);
    NSInteger page = self.contentOffset.x/self.bounds.size.width;
    
    [super setFrame:frame];
    
    NSInteger itemCount = self.subviews.count;
    CGFloat inset = 0, paddingB = 0;
    for (NSInteger i=0; i<itemCount; i++) {
        UIView *viewItem = self.subviews[i];
        CGRect rc = CGRectInset(self.bounds, inset, inset);
        rc.origin.x = self.bounds.size.width*i+inset;
        rc.size.height-=paddingB;
        if ([viewItem isKindOfClass:[UITableViewMode class]]) {
            rc = CGRectInset(rc, 15, 0);
//            rc.origin.y = 10;
            viewItem.frame = rc;
        }
        else {
            viewItem.frame = rc;
        }
    }
    
    self.contentSize = CGSizeMake(frame.size.width*itemCount, frame.size.height);
    self.contentOffset = CGPointMake(frame.size.width*page, 0);
}

@end
