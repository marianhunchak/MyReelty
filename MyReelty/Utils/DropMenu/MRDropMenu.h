//
//  MRDropMenu.h
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRDropMenu : UIView

@property (nonatomic, readonly) NSInteger selectedIndex;

+ (instancetype)newMenuWithHostView:(UIView *)hostView list:(NSArray *)list;

- (void)selectItemAtIndex:(NSInteger)index;

@end
