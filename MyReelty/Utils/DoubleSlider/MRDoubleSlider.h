//
//  MRDoubleSlider.h
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LabelDisplayFormat) {
    LabelDisplayNon = 0,
    LabelDisplayFront,
    LabelDisplayBack
};

@protocol MRDoubleSliderDelegate;
@interface MRDoubleSlider : UIView

@property (nonatomic) NSRange selectedRange;
@property (nonatomic, readonly) NSRange valueRange;
@property (nonatomic, assign) NSRange validRange;

@property (nonatomic, copy) NSString *displayLabelStr;
@property (nonatomic) LabelDisplayFormat labelDisplayFormat;

@property (nonatomic) BOOL useNumberDivider;
@property (nonatomic) BOOL showMaxValueIndicator;

@property (nonatomic, weak) id <MRDoubleSliderDelegate> delegate;

+ (instancetype)newSliderWithRange:(NSRange)valueRange;

- (void)updateComponents;

@end

@protocol MRDoubleSliderDelegate <NSObject>

@optional
- (void)doubleSliderDidStartDraging:(MRDoubleSlider *)slider;
- (void)doubleSliderDidFinishDraging:(MRDoubleSlider *)slider;

@end
