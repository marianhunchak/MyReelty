//
//  PinInfoCollectionCell.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Review;

@interface PinInfoCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSString *reviewID;
@property (strong, nonatomic) Review *review;
@property (nonatomic, assign) NSRange reviewRange;

@end
