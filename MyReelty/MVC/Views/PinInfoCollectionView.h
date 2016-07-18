//
//  PinInfoCollectionView.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PinInfoCollectionView;
@class Review;

@protocol PinInfoCollectionViewDelegate <NSObject>

@optional
- (void) pinInfoCollectionViewDidSelectCell:(Review *)review;

@end

@interface PinInfoCollectionView : UIView

@property (nonatomic, strong) NSArray *pinsArray;
@property (nonatomic, weak) id <PinInfoCollectionViewDelegate> delegate;
+ (instancetype)newView;

@end
