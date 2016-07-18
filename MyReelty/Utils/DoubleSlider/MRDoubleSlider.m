//
//  MRDoubleSlider.m
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MRDoubleSlider.h"

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, ChangingValue) {
    ChangingValueNone,
    ChangingValueLeft,
    ChangingValueRight
};

@interface MRDoubleSlider ()

@property (weak, nonatomic) IBOutlet UIView *rangeView;
@property (weak, nonatomic) IBOutlet UIView *selectedRangeView;
@property (weak, nonatomic) IBOutlet UIView *leftHolderView;
@property (weak, nonatomic) IBOutlet UIView *rightHolderView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (nonatomic) ChangingValue changingValue;

@end

@implementation MRDoubleSlider

+ (instancetype)newSliderWithRange:(NSRange)valueRange {
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"MRDoubleSlider" owner:nil options:nil];
    MRDoubleSlider *newSlider = [viewes firstObject];
    [newSlider setValuesRange:valueRange];
    
    return newSlider;
}

- (void)awakeFromNib {
    _leftHolderView.layer.cornerRadius = _leftHolderView.frame.size.height / 2.f;
    _rightHolderView.layer.cornerRadius = _rightHolderView.frame.size.height / 2.f;
    
    _valueRange = NSMakeRange(0, 1);
    _selectedRange = NSMakeRange(0, 1);
    _validRange = NSMakeRange(0, 1);
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self updateConstraints];
    
    [self updateLabelsContent];
    [self updateLabelsPosition];
    [self updateHoldersPosition];
}

#pragma mark - Public methods

- (void)updateComponents {
    [self updateLabelsContent];
    
    if((_selectedRange.location - _valueRange.location) > (_valueRange.length - _selectedRange.length)) {
        _changingValue = ChangingValueLeft;
    } else {
        _changingValue = ChangingValueRight;
    }
    ChangingValue value = _changingValue;
    
    [self updateView:_leftLabel positionValue:_selectedRange.location];
    _changingValue = value;
    [self updateView:_rightLabel positionValue:_selectedRange.length];
    
    [self updateHoldersPosition];
}

#pragma mark - User actions

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *lastTouch = [touches anyObject];
    
    UIView *touchedView = lastTouch.view;
    
    if([touchedView isEqual:_leftHolderView] || [touchedView isEqual:_rightHolderView]) {

//        UIView *lView = ![touchedView isEqual:_leftHolderView] ? _leftHolderView : _rightHolderView;
//        lView.userInteractionEnabled = NO;
        
        if([_delegate respondsToSelector:@selector(doubleSliderDidStartDraging:)]) {
            [_delegate doubleSliderDidStartDraging:self];
        }
        
        CGPoint viewCenter = touchedView.center;
        CGFloat newX = [lastTouch locationInView:self].x;
        
        if([touchedView isEqual:_leftHolderView]) {

            newX = MIN(CGRectGetMaxX(_rangeView.frame),newX);
            
            if (newX <= CGRectGetMinX(_rangeView.frame) ) {
                newX = CGRectGetMinX(_rangeView.frame);
            }
            
            _selectedRange.location = [self valueForX:newX - _rangeView.frame.origin.x];
            _changingValue = ChangingValueLeft;
            
        } else if ([touchedView isEqual:_rightHolderView]) {
            
            newX = MIN(CGRectGetMaxX(_rangeView.frame),newX);
            if (newX <= CGRectGetMinX(_rangeView.frame) ) {
                newX = CGRectGetMinX(_rangeView.frame);
            }
            _selectedRange.length = [self valueForX:newX - _rangeView.frame.origin.x];
            
            _changingValue = ChangingValueRight;
        }
        
        if (newX >= _rangeView.frame.origin.x + _rangeView.frame.size.width) {
            newX = _rangeView.frame.origin.x + _rangeView.frame.size.width;
        }
        
        viewCenter.x = newX;
        touchedView.center = viewCenter;
        
        [self updateLabelsContent];
        [self updateLabelsPosition];
        [self updateSelectedRangeView];
        
        [self setValidRange:_selectedRange];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *lastTouch = [touches anyObject];

    if([_delegate respondsToSelector:@selector(doubleSliderDidFinishDraging:)]) {
        [_delegate doubleSliderDidFinishDraging:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if([_delegate respondsToSelector:@selector(doubleSliderDidFinishDraging:)]) {
        [_delegate doubleSliderDidFinishDraging:self];
    }
}

#pragma mark - Private methods

- (void) setValidRange:(NSRange)validRange {
    _validRange = validRange;
    
    if (_selectedRange.length < _selectedRange.location) {
        _validRange.location = _selectedRange.length;
        _validRange.length = _selectedRange.location;
    } else {
        _validRange.location = _selectedRange.location;
        _validRange.length = _selectedRange.length;
    }
}
- (void)setValuesRange:(NSRange)range {
    _valueRange = range;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    _selectedRange = selectedRange;

    [self setValidRange:_selectedRange];
    [self updateLabelsContent];
    [self updateLabelsPosition];
    [self updateHoldersPosition];
}

- (void)updateLabelsContent {
    [self updateLabel:_leftLabel contentValue:_selectedRange.location];
    [self updateLabel:_rightLabel contentValue:_selectedRange.length];
}

- (void)updateLabelsPosition {
    [self updateView:_leftLabel positionValue:_selectedRange.location];
    [self updateView:_rightLabel positionValue:_selectedRange.length];
    
    _changingValue = ChangingValueNone;
}

- (void)updateHoldersPosition {
    [self updateView:_leftHolderView positionValue:_selectedRange.location];
    [self updateView:_rightHolderView positionValue:_selectedRange.length];
    
    [self updateSelectedRangeView];
}

#pragma mark - Helpers

- (void)updateLabel:(UILabel *)label contentValue:(NSInteger)value {
    NSString *labelText = [NSString stringWithFormat:@"%li", (long)value];
    if(_useNumberDivider) {
        labelText = [self divideNumber:labelText];
    }
    
    if(_showMaxValueIndicator && [self isMaxValue:value forLabel:label]) {
        labelText = [labelText stringByAppendingString:@"+"];
    }
    
    if([_displayLabelStr length] > 0) {
        if(_labelDisplayFormat == LabelDisplayFront) {
            labelText = [NSString stringWithFormat:@"%@ %@", _displayLabelStr, labelText];
        } else if (_labelDisplayFormat == LabelDisplayBack) {
            labelText = [NSString stringWithFormat:@"%@ %@", labelText, _displayLabelStr];
        }
    }
    label.text = labelText;
    
    //update label frame
    CGPoint labelCenter = label.center;
    
    CGFloat width = [labelText boundingRectWithSize:CGSizeMake(9999, label.frame.size.height)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: label.font}
                                            context:nil].size.width;
    CGRect labelFrame = label.frame;
    labelFrame.size.width = width;
    label.frame = labelFrame;
    label.center = labelCenter;
}

- (void)updateSelectedRangeView {
    CGRect selectedFrame = _selectedRangeView.frame;
    selectedFrame.origin.x = _leftHolderView.center.x;
    selectedFrame.size.width = _rightHolderView.center.x - selectedFrame.origin.x;
//    if (selectedFrame.origin.x + selectedFrame.size.width > _rangeView.frame.origin.x + _rangeView.frame.size.width) {
//        selectedFrame.size.width = selectedFrame.size.width -((selectedFrame.origin.x + selectedFrame.size.width) - (_rangeView.frame.origin.x +_rangeView.frame.size.width));
//    }
    _selectedRangeView.frame = selectedFrame;
}

- (void)updateView:(UIView *)view positionValue:(NSInteger)value {
    NSInteger scaledValue = value - _valueRange.location;
    
    CGPoint center = view.center;
    CGFloat newX = [self xForValue:scaledValue];
    NSInteger sign = CGRectGetMaxX(_rightHolderView.frame) > CGRectGetMaxX(_leftHolderView.frame) ? 1 : -1;
    
    if([view isEqual:_leftLabel] && _changingValue == ChangingValueLeft) {
        CGFloat rightCenter = _rightLabel.center.x;
        CGFloat leftWidth = _leftLabel.frame.size.width;
        if (CGPointEqualToPoint(_leftHolderView.frame.origin, _rightHolderView.frame.origin)) {
            newX = _rightLabel.center.x;
        } else if(fabs(rightCenter  - newX) <= leftWidth) {
            newX = ceil(rightCenter - sign * leftWidth);
        }
        
        _changingValue = ChangingValueNone;
    } else if ([view isEqual:_rightLabel] && _changingValue == ChangingValueRight) {
        CGRect leftFrame = _leftLabel.frame;
        CGFloat widthHalfSize = (_rightLabel.frame.size.width / 2);
        if (CGPointEqualToPoint(_leftHolderView.frame.origin, _rightHolderView.frame.origin)) {
            newX = _leftLabel.center.x;
        }else if(fabs(newX - _leftLabel.center.x) <= widthHalfSize * 2) {
            newX = ceil(_leftLabel.center.x + sign * (widthHalfSize * 2));
        }
        
        _changingValue = ChangingValueNone;
    }
    
    center.x = newX;
    view.center = center;
}

- (CGFloat)xForValue:(NSInteger)value {
    CGFloat x = 0;
    
    CGFloat xPerValue = _rangeView.frame.size.width / (_valueRange.length - _valueRange.location);
    x = xPerValue * value + _rangeView.frame.origin.x;
    
    return x;
}

- (NSInteger)valueForX:(CGFloat)x {
    CGFloat xPerValue = _rangeView.frame.size.width / (_valueRange.length - _valueRange.location);
    
    NSInteger value = x / xPerValue;
    
    return value + _valueRange.location;
}

- (NSString *)divideNumber:(NSString *)number {
    NSMutableString *newNumber = [NSMutableString stringWithString:number];
    
    for(NSInteger i = [number length] - 3; i > 0; i-=3) {
        if(i <= 0) {
            break;
        }
        [newNumber insertString:@"." atIndex:i];
    }
    
    return newNumber;
}

- (BOOL)isMaxValue:(NSInteger)value forLabel:(UILabel *)label {
//    if([label isEqual:_rightLabel]) {
        return value >= _valueRange.length;

    return NO;
}

@end
