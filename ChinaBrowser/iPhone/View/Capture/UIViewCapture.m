//
//  UIViewCapture.m
//  ChinaBrowser
//
//  Created by David on 14-10-8.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewCapture.h"

#define kAnchorRadius (6.0f)

#define kAnchorWidth (20.0f)
#define kAnchorHeight (3.0f)


#define kScreenScale [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, AnchorType) {
    AnchorTypeNone,
    AnchorTypeLT,
    AnchorTypeRT,
    AnchorTypeRB,
    AnchorTypeLB,
    AnchorTypeT,
    AnchorTypeR,
    AnchorTypeB,
    AnchorTypeL,
    AnchorTypeInside,
    AnchorTypeOutside = AnchorTypeNone
};

@implementation UIViewCapture
{
    UIView *_viewMask;
    AnchorType _anchorType;
}

@synthesize captureFrame = _captureFrame;

#pragma mark - property
- (CGRect)captureFrame
{
    return _viewMask.frame;
}

- (void)setCaptureFrame:(CGRect)captureFrame
{
    
    
    //
    captureFrame.size.width = captureFrame.size.width<self.imageFrame.size.width?captureFrame.size.width:(self.imageFrame.size.width);
    captureFrame.size.height = captureFrame.size.height<self.imageFrame.size.height?captureFrame.size.height:(self.imageFrame.size.height);
    
    if(ScreenshotIcon == self.screenshotType)
    {
        captureFrame.size.width = captureFrame.size.width<=captureFrame.size.height?captureFrame.size.width:captureFrame.size.height;
        captureFrame.size.height = captureFrame.size.width;
        
    }
    
    if (ScreenshotSkin == self.screenshotType) {
        float scale = kScreenScale;
        scale = scale<=1?scale:(1/scale);
        
        captureFrame.size.width = captureFrame.size.height*scale;
        if (captureFrame.size.width>self.imageFrame.size.width) {
            captureFrame.size.width = self.imageFrame.size.width;
            captureFrame.size.height = self.imageFrame.size.width/scale;
        }
    }
    captureFrame.origin.x = (self.width-captureFrame.size.width)*0.5>self.imageFrame.origin.x?(self.width-captureFrame.size.width)*0.5:(self.imageFrame.origin.x);
    captureFrame.origin.y = (self.height-captureFrame.size.height)*0.5>=self.imageFrame.origin.y?(self.height-captureFrame.size.height)*0.5:(self.imageFrame.origin.y);
    
    _viewMask.frame = captureFrame;
    [self setNeedsDisplay];
}

- (void)setImageFrame:(CGRect)imageFrame
{
    _imageFrame = imageFrame;
    [self setCaptureFrame:CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(0.6, 0.6))];
}

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
    
    _viewMask = [[UIView alloc] init];
    _viewMask.backgroundColor = [UIColor clearColor];
    _viewMask.alpha = 0.1;
    [self addSubview:_viewMask];
    
    [self setCaptureFrame:CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(0.6, 0.6))];
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setCaptureFrame:CGRectIntegral(CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(0.6, 0.6)))];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 画背景
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.1 alpha:0.7].CGColor);
    CGContextFillRect(context, rect);
    
    
    // 画截图区域
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillRect(context, _viewMask.frame);
    
    // 画锚点
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:1].CGColor);
    
    CGFloat radius = kAnchorRadius;
    CGRect rcLT = CGRectMake(_viewMask.left-kAnchorHeight, _viewMask.top-kAnchorHeight, kAnchorWidth, kAnchorHeight);
    CGRect rcLTL = CGRectMake(_viewMask.left-kAnchorHeight, _viewMask.top-kAnchorHeight, kAnchorHeight, kAnchorWidth);
    
    CGRect rcRT = CGRectMake(_viewMask.right-kAnchorWidth + kAnchorHeight, _viewMask.top-kAnchorHeight, kAnchorWidth, kAnchorHeight);
    CGRect rcRTR = CGRectMake(_viewMask.right, _viewMask.top-kAnchorHeight, kAnchorHeight, kAnchorWidth);
    
    CGRect rcRB = CGRectMake(_viewMask.right-kAnchorWidth + kAnchorHeight, _viewMask.bottom, kAnchorWidth, kAnchorHeight);
    CGRect rcRBR = CGRectMake(_viewMask.right, _viewMask.bottom+kAnchorHeight-kAnchorWidth, kAnchorHeight, kAnchorWidth);
    
    CGRect rcLB = CGRectMake(_viewMask.left-kAnchorHeight, _viewMask.bottom, kAnchorWidth, kAnchorHeight);
    CGRect rcLBL = CGRectMake(_viewMask.left-kAnchorHeight, _viewMask.bottom+kAnchorHeight - kAnchorWidth, kAnchorHeight, kAnchorWidth);
//    
//    CGRect rcT = CGRectMake(_viewMask.left+_viewMask.width*0.5-kAnchorWidth*.5, _viewMask.top-kAnchorHeight, kAnchorWidth, kAnchorHeight);
//    CGRect rcR = CGRectMake(_viewMask.right, _viewMask.top+_viewMask.height*0.5-kAnchorWidth*.5, kAnchorHeight, kAnchorWidth);
//    CGRect rcB = CGRectMake(_viewMask.left+_viewMask.width*0.5-kAnchorWidth*.5, _viewMask.bottom, kAnchorWidth, kAnchorHeight);
//    CGRect rcL = CGRectMake(_viewMask.left-kAnchorHeight, _viewMask.top+_viewMask.height*0.5-kAnchorWidth*.5, kAnchorHeight, kAnchorWidth);
    
    CGContextFillRect(context, rcLT);
    CGContextFillRect(context, rcLTL);
    
    CGContextFillRect(context, rcRT);
    CGContextFillRect(context, rcRTR);
    
    CGContextFillRect(context, rcRB);
    CGContextFillRect(context, rcRBR);
    
    CGContextFillRect(context, rcLB);
    CGContextFillRect(context, rcLBL);
    
    CGRect rc = _viewMask.frame;
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(rc.origin.x-1, rc.origin.y-1, rc.size.width+2, rc.size.height+2));
    CGContextSetLineWidth(context, 0);
    
    // LT
//    CGContextFillEllipseInRect(context, rcLT);
    // RB
//    CGContextFillEllipseInRect(context, rcRB);
//    // LB
//    CGContextFillEllipseInRect(context, rcLB);
//    // RT
//    CGContextFillEllipseInRect(context, rcRT);
    //头像模式不用这几个点
//    // T
//    CGContextFillRect(context, rcT);
//    // R
//    CGContextFillRect(context, rcR);
//    // B
//    CGContextFillRect(context, rcB);
//    // L
//    CGContextFillRect(context, rcL);
    
    // 画文字信息
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:1].CGColor);
    CGPoint point = CGPointMake(MAX(_viewMask.left, 20), MAX(_viewMask.top-13-radius, 20));
    [[NSString stringWithFormat:@"(%0.1f, %0.1f, %0.1f, %0.1f)", _viewMask.left, _viewMask.top, _viewMask.width, _viewMask.height] drawAtPoint:point withFont:[UIFont systemFontOfSize:10]];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currPoint = [touch locationInView:self];
    
    _anchorType = [self getAnchorTypeWithPoint:currPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint prevPoint = [touch previousLocationInView:self];
    CGPoint currPoint = [touch locationInView:self];
    
    
    CGRect rc = _viewMask.frame;
    CGFloat r = _viewMask.right, b = _viewMask.bottom , l = _viewMask.left, t = _viewMask.top;
    
    float scale = 1;
    CGPoint transPoint = CGPointMake(currPoint.x-prevPoint.x, currPoint.y-prevPoint.y);
    
    if (ScreenshotSkin == self.screenshotType) {
        scale = kScreenScale;
        scale = scale<1?scale:(1/scale);
    }
    if (currPoint.x < self.imageFrame.origin.x) {
        currPoint.x = self.imageFrame.origin.x;
        
    }
    if (currPoint.y < self.imageFrame.origin.y) {
        currPoint.y = self.imageFrame.origin.y;
    }
    if (currPoint.x > (self.imageFrame.origin.x + self.imageFrame.size.width)) {
        currPoint.x = self.imageFrame.origin.x + self.imageFrame.size.width;
    }
    if (currPoint.y > (self.imageFrame.origin.y+self.imageFrame.size.height)) {
        currPoint.y = self.imageFrame.origin.y + self.imageFrame.size.height;
    }
    
    
    CGFloat LW = r-currPoint.x, TH = b-currPoint.y, RW = currPoint.x-l, BH = currPoint.y-t, CW = .5*(l+r), CH = .5*(t+b);
    LW = LW>=kAnchorWidth*4?LW:kAnchorWidth*4;
    TH = TH>=kAnchorWidth*4?TH:kAnchorWidth*4;
    RW = RW>=kAnchorWidth*4?RW:kAnchorWidth*4;
    BH = BH>=kAnchorWidth*4?BH:kAnchorWidth*4;
    
    if (self.screenshotType == ScreenshotSkin) {
        TH = TH>=kAnchorWidth*4/scale?TH:kAnchorWidth*4/scale;
        BH = BH>=kAnchorWidth*4/scale?BH:kAnchorWidth*4/scale;

    }
    
    if (self.imageFrame.size.width<=LW || self.imageFrame.size.height<=TH) {
        _anchorType = AnchorTypeInside;
    }
    switch (_anchorType) {
        case AnchorTypeLT:
        {
            
            if (ScreenshotSkin == self.screenshotType) {
                if(TH>self.imageFrame.size.width/scale)
                {
                    TH = self.imageFrame.size.width/scale;
                }
                LW = TH*scale;
            }
            rc.size.width = LW;
            rc.origin.x = r-LW;
            
            rc.size.height = TH;
            rc.origin.y = b-TH;
            
        }break;
        case AnchorTypeRT:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(TH>self.imageFrame.size.width/scale)
                {
                    TH = self.imageFrame.size.width/scale;
                }
            }
            if (ScreenshotIcon == self.screenshotType) {
                RW = RW>=TH?TH:RW;
                TH = RW;
            }
            if (ScreenshotSkin == self.screenshotType) {
                RW = TH*scale;
            }
            rc.size.width = RW;
            
            rc.size.height = TH;
            rc.origin.y = b-TH;
        }break;
        case AnchorTypeRB:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(BH>self.imageFrame.size.width/scale)
                {
                    BH = self.imageFrame.size.width/scale;
                }
            }
            if (ScreenshotIcon == self.screenshotType) {
                RW = RW>=BH?BH:RW;
                BH = RW;
            }
            if (ScreenshotSkin == self.screenshotType) {
                RW = BH*scale;
            }
            rc.size.width = RW;
            rc.size.height = BH;
            
        }break;
        case AnchorTypeLB:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(BH>self.imageFrame.size.width/scale)
                {
                    BH = self.imageFrame.size.width/scale;
                }
            }
            if (ScreenshotIcon == self.screenshotType) {
                LW = LW>=BH?BH:LW;
                BH = LW;
            }
            if (ScreenshotSkin == self.screenshotType) {
                LW = BH*scale;
            }
            rc.size.width = LW;
            rc.origin.x = r-LW;
            
            rc.size.height = BH;
            // _viewMask.frame = rc;
        }break;
        case AnchorTypeT:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(TH>self.imageFrame.size.width/scale)
                {
                    TH = self.imageFrame.size.width/scale;
                }
            }
            rc.size.height = TH;
            rc.origin.y = b-TH;
            
            if (!(ScreenshotDraw == self.screenshotType)) {
                RW = TH*scale;
                rc.size.width = RW;
                rc.origin.x = CW-.5*RW;
            }
            
            
        }break;
        case AnchorTypeR:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(RW>self.imageFrame.size.height*scale)
                {
                    RW = self.imageFrame.size.height*scale;
                }
            }
            rc.size.width = RW;
            if (!(ScreenshotDraw == self.screenshotType)) {
                TH = RW/scale;
                rc.size.height = TH;
                rc.origin.y = CH-.5*TH;
            }
        }break;
        case AnchorTypeB:
        {
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(BH>self.imageFrame.size.width/scale)
                {
                    BH = self.imageFrame.size.width/scale;
                }
            }
            rc.size.height = BH;
            if (!(ScreenshotDraw == self.screenshotType)) {
                RW = BH*scale;
                rc.size.width = RW;
                rc.origin.x = CW-.5*RW;
            }
        }break;
        case AnchorTypeL:
        {
            
            if (!(ScreenshotDraw == self.screenshotType)) {
                
                if(LW>self.imageFrame.size.height*scale)
                {
                    LW = self.imageFrame.size.height*scale;
                }
                
            }
            rc.size.width = LW;
            rc.origin.x = r-LW;
            if (!(ScreenshotDraw == self.screenshotType)) {
                TH = LW/scale;
                rc.size.height = TH;
                rc.origin.y = CH-.5*TH;
            }
        }break;
        case AnchorTypeInside:
        {
            //如果移动后在里面 才行
            rc.origin.x += transPoint.x;
            rc.origin.y += transPoint.y;
            
        }break;
        default:break;
    }
    
        _viewMask.frame = rc;
        
        if (_viewMask.left < self.imageFrame.origin.x) {
            rc.origin.x = self.imageFrame.origin.x;
        }
        if (_viewMask.top < self.imageFrame.origin.y) {
            rc.origin.y = self.imageFrame.origin.y;
        }
        if (_viewMask.right > (self.imageFrame.origin.x + self.imageFrame.size.width)) {
            rc.origin.x = self.imageFrame.origin.x + self.imageFrame.size.width - rc.size.width;
        }
        if (_viewMask.bottom > (self.imageFrame.origin.y+self.imageFrame.size.height)) {
            rc.origin.y = self.imageFrame.origin.y + self.imageFrame.size.height -rc.size.height;
        }
        

        
        
        _viewMask.frame = rc;
        [self setNeedsDisplay];
    
}

- (AnchorType)getAnchorTypeWithPoint:(CGPoint)point
{
//    CGFloat radius = kAnchorRadius;
    CGRect rcLT = CGRectMake(_viewMask.left-kAnchorWidth, _viewMask.top-kAnchorWidth, kAnchorWidth*2, kAnchorWidth*2);
    CGRect rcRT = CGRectMake(_viewMask.right-kAnchorWidth, _viewMask.top-kAnchorWidth, kAnchorWidth*2, kAnchorWidth*2);
    CGRect rcRB = CGRectMake(_viewMask.right-kAnchorWidth, _viewMask.bottom-kAnchorWidth, kAnchorWidth*2, kAnchorWidth*2);
    CGRect rcLB = CGRectMake(_viewMask.left-kAnchorWidth, _viewMask.bottom-kAnchorWidth, kAnchorWidth*2, kAnchorWidth*2);
    
    CGRect rcT = CGRectMake(_viewMask.left+kAnchorWidth-kAnchorHeight, _viewMask.top-kAnchorWidth, _viewMask.width-2*kAnchorWidth+2*kAnchorHeight, kAnchorWidth*2);
    CGRect rcR = CGRectMake(_viewMask.right-kAnchorWidth, _viewMask.top+kAnchorWidth-kAnchorHeight, kAnchorWidth*2, _viewMask.height-2*kAnchorWidth+2*kAnchorHeight);
    CGRect rcB = CGRectMake(_viewMask.left+kAnchorWidth-kAnchorHeight, _viewMask.bottom-kAnchorWidth, _viewMask.width-2*kAnchorWidth+2*kAnchorHeight, kAnchorWidth*2);
    CGRect rcL = CGRectMake(_viewMask.left-kAnchorWidth, _viewMask.top+kAnchorWidth-kAnchorHeight, kAnchorWidth*2, _viewMask.height-2*kAnchorWidth+2*kAnchorHeight);
    
    AnchorType anchorType;
    if (CGRectContainsPoint(rcLT, point)) anchorType = AnchorTypeLT;
    else if (CGRectContainsPoint(rcRT, point)) anchorType = AnchorTypeRT;
    else if (CGRectContainsPoint(rcRB, point)) anchorType = AnchorTypeRB;
    else if (CGRectContainsPoint(rcLB, point)) anchorType = AnchorTypeLB;
    
    else if (CGRectContainsPoint(rcT, point) ) anchorType = AnchorTypeT;
    else if (CGRectContainsPoint(rcR, point) ) anchorType = AnchorTypeR;
    else if (CGRectContainsPoint(rcB, point) ) anchorType = AnchorTypeB;
    else if (CGRectContainsPoint(rcL, point) ) anchorType = AnchorTypeL;
    else if (CGRectContainsPoint(_viewMask.frame, point)) anchorType = AnchorTypeInside;
    else anchorType = AnchorTypeInside;
    
    return anchorType;
}

@end
