//
//  UIViewPopSearchEngine.m
//  ChinaBrowser
//
//  Created by David on 14/11/10.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewPopSearchEngine.h"

#import "ModelSearchEngine.h"

@interface UIViewPopSearchEngine () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation UIViewPopSearchEngine
{
    __weak IBOutlet UIPickerView *_pickerView;
    
    NSArray *_arrItem;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _arrItem = [AppSetting shareAppSetting].arrSearchEngine;
}

- (void)showInView:(UIView *)view completion:(void (^)())completion
{
    [super showInView:view completion:completion];
    
    [_pickerView selectRow:[AppSetting shareAppSetting].searchIndex inComponent:0 animated:NO];
}

- (void)onTouchOk
{
    NSInteger index = [_pickerView selectedRowInComponent:0];
    if (index>=0) {
        _DEBUG_LOG(@"%s:%@", __FUNCTION__, [(ModelSearchEngine *)_arrItem[index] name]);
        [_deletate viewPopSearchEngine:self selectSearchIndex:index];
    }
    [self dismissWithCompletion:nil];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _arrItem.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ModelSearchEngine *model = _arrItem[row];
    return model.name;
}

@end
