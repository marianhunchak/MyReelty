//
//  PremiumVideoCollectionView.m
//  MyReelty
//
//  Created by Admin on 8/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PremiumVideoCollectionView.h"
#import "PremiumVideoCell.h"
#import "PremiumReview.h"
#import "Review.h"

@interface PremiumVideoCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) NSTimer *myTimer;

@end

static NSString *premiunCellIdentifier = @"premiumCell";

@implementation PremiumVideoCollectionView

+ (instancetype)newView {
    
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"PremiumVideoCollectionView" owner:nil options:nil];
    
    PremiumVideoCollectionView *newPremiumVideoCollectionView = [viewes firstObject];
    
    newPremiumVideoCollectionView.dataSource = newPremiumVideoCollectionView;
    newPremiumVideoCollectionView.delegate = newPremiumVideoCollectionView;
    [newPremiumVideoCollectionView registerNib:[UINib nibWithNibName:@"PremiumVideoCell" bundle:nil] forCellWithReuseIdentifier:premiunCellIdentifier];
    
    
    
    
    return newPremiumVideoCollectionView;
}


- (void)setPremiumRevies:(NSArray *)premiumRevies {
    
    _premiumRevies = premiumRevies;
    [self reloadData];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                     target:self
                                                   selector:@selector(showNextCollectionItem)
                                                   userInfo:nil
                                                    repeats:YES];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _premiumRevies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PremiumVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:premiunCellIdentifier forIndexPath:indexPath];
    
    cell.premiumReview = _premiumRevies[indexPath.row];
    
    cell.alpha = 0.1f;

    [UIView animateWithDuration:1 animations:^{
        cell.alpha = 1.f;
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.frame.size;
}

#pragma mark - Actions

- (void)showNextCollectionItem {
    
    NSIndexPath *curentIndexPath = [self indexPathsForVisibleItems].firstObject;
    
    NSInteger nextItemIndex = curentIndexPath.item + 1;
    
    if (nextItemIndex >= [_premiumRevies count]) {
        nextItemIndex = 0;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItemIndex inSection:0];
    
    [self scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
//    self.pageControl.currentPage = nextItemIndex;
    
}

@end
