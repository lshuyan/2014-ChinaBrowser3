//
//  VPImageCropperViewController.m
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import "UIControllerScreenshotIcon.h"
#import "UIImage+Resize.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f
//允许最大放大倍数
#define kLimitRatio 10

@interface UIControllerScreenshotIcon ()
{
    
    UIButton *_btnClear;
    UIButton *_btnConfirm;

}
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *editedImage;

@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;

@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation UIControllerScreenshotIcon

- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.editedImage = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}

- (id)initWithImage:(UIImage *)originalImage {
    self = [super init];
    if (self) {
        
        self.originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self initView];
    [self initControlBtn];
}

-(void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
//    CGRect rc = CGRectApplyAffineTransform(self.view.bounds, CGAffineTransformMakeScale((self.view.width/2)/self.view.width, (self.view.width/2)/self.view.height));
    CGRect rc = CGRectMake(0, 0, 200, 200);
    rc.origin.x = (self.view.width - rc.size.width)*.5;
    rc.origin.y = (self.view.height - rc.size.height)*.5;
    self.cropFrame = rc;
    // scale to fit the screen
    //CGFloat maxWH = self.originalImage.size.width>self.originalImage.size.height?self.originalImage.size.height:self.originalImage.size.width;
    BOOL isWH = self.originalImage.size.width>self.originalImage.size.height?YES:NO;
    CGFloat oriWidth ;
    CGFloat oriHeight;
    if (isWH)
    {
        oriHeight = self.cropFrame.size.height;
        oriWidth = self.originalImage.size.width * (oriHeight / self.originalImage.size.height);
    }
    else
    {
        oriWidth = self.cropFrame.size.width;
        oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    }
    CGFloat oriX = (self.view.width - oriWidth) / 2;
    CGFloat oriY = (self.view.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, kLimitRatio * self.oldFrame.size.width, kLimitRatio * self.oldFrame.size.height);
    
    self.ratioView.frame = self.cropFrame;
    
    _btnClear.frame = CGRectMake(32, self.view.height - 60.0f, 41, 41);
    _btnConfirm.frame = CGRectMake(self.view.width - 41 - 32, self.view.height - 60.0f, 41, 41);
    [self overlayClipping];
}

- (void)initView {
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    self.showImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = .5f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    self.ratioView = [[UIView alloc] init];
    self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
}

- (void)initControlBtn {
    UIButton *cancelBtn = [[UIButton alloc] init];
    _btnClear = cancelBtn;
    [_btnClear.layer setCornerRadius:20];
    [_btnClear.layer setMasksToBounds:YES];
    [_btnClear setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/SetSkin/delete_0.png"] forState:UIControlStateNormal];
    [_btnClear setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/SetSkin/delete_1.png"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    
    UIButton *confirmBtn = [[UIButton alloc] init];
    _btnConfirm = confirmBtn;
    [_btnConfirm.layer setCornerRadius:20];
    [_btnConfirm.layer setMasksToBounds:YES];
    [_btnConfirm setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/SetSkin/enter_0.png"] forState:UIControlStateNormal];
    [_btnConfirm setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/SetSkin/enter_1.png"] forState:UIControlStateHighlighted];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
}

- (void)cancel:(id)sender {
//    if (self.delegate && [self.delegate conformsToProtocol:@protocol(UIControllerScreenshotIconDelegate)]) {
//        [self.delegate controllerScreenshotIcon:self];
//    }
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)confirm:(id)sender {
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(UIControllerScreenshotIconDelegate)]) {
        [self.delegate controllerScreenshotIcon:self didFinished:[[self getSubImage] resizeImageWithNewSize:self.cropFrame.size]];
        
        [self cancel:nil];
    }
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat acceleratorX = 1;
        CGFloat acceleratorY = 1;
        if(view.frame.origin.x>self.cropFrame.origin.x)
        {
            acceleratorX = 1 - (view.frame.origin.x - self.cropFrame.origin.x) / self.cropFrame.size.width/.6;
            
        }
        else if((view.frame.origin.x + view.frame.size.width)<(self.cropFrame.origin.x + self.cropFrame.size.width))
        {
            acceleratorX = 1 - ((self.cropFrame.origin.x + self.cropFrame.size.width) - (view.frame.origin.x + view.frame.size.width)) / self.cropFrame.size.width/.6;
        }
        if(view.frame.origin.y>self.cropFrame.origin.y)
        {
            acceleratorY = 1 - (view.frame.origin.y - self.cropFrame.origin.y) / self.cropFrame.size.height/.6;
        }
        else if((view.frame.origin.y+view.frame.size.height)<(self.cropFrame.origin.y + self.cropFrame.size.height))
        {
            acceleratorY = 1 - ((self.cropFrame.origin.y + self.cropFrame.size.height) - (view.frame.origin.y+view.frame.size.height)) / self.cropFrame.size.width/.6;
        }
                
        if (acceleratorX < 0.1) {
            acceleratorX = 0.1;
        }
        else if (acceleratorY < 0.1) {
            acceleratorY = 0.1;
        }
        
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
//        [view setCenter:(CGPoint){view.center.x + translation.x , view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < (self.cropFrame.size.width + self.cropFrame.origin.x)) newFrame.origin.x = self.cropFrame.size.width+self.cropFrame.origin.x- newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

-(UIImage *)getSubImage{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

@end
