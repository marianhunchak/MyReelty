//
//  UIView+Layer.m
//  MyReelty
//
//  Created by Marian Hunchak on 10/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIView+Layer.h"

#define GRADIENT_LAYER_TAG 999999

@implementation UIView (Layer)

- (void)addGradientToViewWithCellHeight: (double)cellHeight
{
    for(CALayer *layer in self.layer.sublayers) {
        if([layer isKindOfClass:[CAGradientLayer class]]) {
            return;
        }
    }
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, cellHeight);
    gradient.frame = rect;
    gradient.colors = @[(id)[[UIColor clearColor] CGColor],
                        (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
    [self.layer insertSublayer:gradient atIndex:0];

   
}

@end
