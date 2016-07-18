//
//  MRSetSelection.m
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MRSetSelection.h"

#import <QuartzCore/QuartzCore.h>

@interface MRSetSelection ()

@property (nonatomic, strong) NSArray *itemsArray;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *setItems;

@end

@implementation MRSetSelection

+ (instancetype)newSetSelectionWithItems:(NSArray *)items {
    if([items count] != 6) {
        return nil;
    }
    
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"MRSetSelection" owner:nil options:nil];
    MRSetSelection *setSelection = [viewes firstObject];
    setSelection.itemsArray = items;
    
    return setSelection;
}

#pragma mark - Public methods

- (void)setSelectedItem:(NSInteger)selectedItem {
    _selectedItem = selectedItem;
    
    [self setItemSelectedAtIndex:selectedItem];
}

#pragma mark - Private methods

- (void)setItemsArray:(NSArray *)itemsArray {
    [_setItems enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * stop) {
        [button setTitle:itemsArray[idx] forState:UIControlStateNormal];
        button.layer.cornerRadius = button.frame.size.height / 2.f;
    }];
}

- (void)setItemSelectedAtIndex:(NSInteger)index {
    [_setItems enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * stop) {
        if(idx == index) {
            [button setSelected:YES];
            [button setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:95.f/255.f alpha:1.f]];
        } else {
            [button setSelected:NO];
            [button setBackgroundColor:[UIColor clearColor]];
        }
    }];
}

#pragma mark - User actions

- (IBAction)didPressedButton:(UIButton *)sender {
    [self setSelectedItem:sender.tag];
}

@end
