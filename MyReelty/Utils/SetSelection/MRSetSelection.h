//
//  MRSetSelection.h
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSetSelection : UIView

+ (instancetype)newSetSelectionWithItems:(NSArray *)items;

@property (nonatomic) NSInteger selectedItem;

@end
