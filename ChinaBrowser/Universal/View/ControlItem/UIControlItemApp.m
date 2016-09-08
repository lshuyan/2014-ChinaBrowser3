//
//  UIControlItemApp.m
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControlItemApp.h"

@interface UIControlItemApp () <UIGestureRecognizerDelegate>

@end

@implementation UIControlItemApp
{
    CGPoint _ptOriginBeforeDrag;    // 拖拽前 手指位置
    UILongPressGestureRecognizer *_longPressGresture;
    UIBorder _borderBeforeDrag;
    
    UIButton *_btnDelete;
}

#pragma mark - property
- (void)setAllowEdit:(BOOL)allowEdit
{
    _allowEdit = allowEdit;
}

- (void)setEdit:(BOOL)edit
{
    if (!_allowEdit) {
        return;
    }
    _edit = edit;
    
    if (_edit) {
        if (_btnDelete) {
            [_btnDelete removeFromSuperview];
            _btnDelete = nil;
        }
        
        CGRect rc = CGRectMake(0, 0, 24, 24);
        rc.origin.y = 5;
        rc.origin.x = self.width-rc.size.width-rc.origin.y;
        _btnDelete = [[UIButton alloc] initWithFrame:rc];
        _btnDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_btnDelete setImage:[UIImage imageWithBundleFile:@"iPhone/Home/delete_0.png"] forState:UIControlStateNormal];
        [_btnDelete setImage:[UIImage imageWithBundleFile:@"iPhone/Home/delete_1.png"] forState:UIControlStateHighlighted];
        [_btnDelete addTarget:self action:@selector(onTouchDelete:) forControlEvents:UIControlEventTouchUpInside];
        _btnDelete.alpha = 0;
        
        [self addSubview:_btnDelete];
        
        _btnDelete.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(-M_PI_2));
        [UIView animateWithDuration:0.3 animations:^{
            _btnDelete.transform = CGAffineTransformMakeScale(1.1, 1.1);
            _btnDelete.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _btnDelete.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            _btnDelete.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                _btnDelete.alpha = 0;
                _btnDelete.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(-M_PI_2));
            } completion:^(BOOL finished) {
                [_btnDelete removeFromSuperview];
                _btnDelete = nil;
            }];
        }];
    }
}

- (void)setBorder:(UIBorder)border
{
    _border = border;
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

#pragma mark - super methods
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _longPressGresture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:_longPressGresture];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGContextSetLineWidth(context, _borderWidth);
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetAllowsFontSmoothing(context, NO);
    
    if (UIBorderTop&_border) {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, self.width, 0);
    }
    
    if (UIBorderBottom&_border) {
        CGContextMoveToPoint(context, 0, self.height);
        CGContextAddLineToPoint(context, self.width, self.height);
    }
    
    if (UIBorderLeft&_border) {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, self.height);
    }
    
    if (UIBorderRight&_border) {
        CGContextMoveToPoint(context, self.width, 0);
        CGContextAddLineToPoint(context, self.width, self.height);
    }
    
    CGContextStrokePath(context);
}

#pragma mark - private methods
- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateBegan==gesture.state) {
        _ptOriginBeforeDrag = [gesture locationInView:self];
        [_delegate controlItemAppWillEdit:self];
        if (_allowEdit) {
            [_delegate controlItemAppDidBeginDrag:self];
        }
    }
    else if (UIGestureRecognizerStateChanged==gesture.state) {
        if (_allowEdit) {
            self.transform = CGAffineTransformTranslate(self.transform,
                                                        [gesture locationInView:self].x-_ptOriginBeforeDrag.x,
                                                        [gesture locationInView:self].y-_ptOriginBeforeDrag.y);
            
            [_delegate controlItemAppMoving:self];
        }
    }
    else {
        if (_allowEdit) {
            [_delegate controlItemAppDidEndDrag:self];
        }
    }
}

- (void)onTouchDelete:(UIControlItemApp *)item
{
    [_delegate controlItemAppWillDelete:self];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
