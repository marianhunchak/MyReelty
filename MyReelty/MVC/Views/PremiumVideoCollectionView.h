//
//  PremiumVideoCollectionView.h
//  MyReelty
//
//  Created by Admin on 8/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PremiumVideoCollectionView : UICollectionView


@property (strong, nonatomic) NSArray *premiumRevies;

+ (instancetype)newView;

@end
