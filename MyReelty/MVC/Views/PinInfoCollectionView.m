//
//  PinInfoCollectionView.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PinInfoCollectionView.h"
#import "PinInfoCollectionCell.h"
#import "HCMapAnnotation.h"
#import "MapViewController.h"

static NSString *cellIdentifier = @"PinInfoCell";

@interface PinInfoCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PinInfoCollectionView

+ (instancetype)newView {
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"PinReviewInfoView" owner:nil options:nil];
    
    PinInfoCollectionView *newPinInfoCollectionView = [viewes firstObject];
    
    newPinInfoCollectionView.layer.cornerRadius = 5.f;
    newPinInfoCollectionView.layer.masksToBounds = YES;
    
    [newPinInfoCollectionView.collectionView registerNib:[UINib nibWithNibName:@"PinInfoCollectionCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    
    newPinInfoCollectionView.collectionView.userInteractionEnabled = YES;

    return newPinInfoCollectionView;
}

- (void)setPinsArray:(NSArray *)pinsArray {
    _pinsArray = pinsArray;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [_pinsArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PinInfoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.reviewID = ((HCMapAnnotation *)[_pinsArray objectAtIndex:indexPath.row]).reviewID;
    cell.reviewRange = NSMakeRange(indexPath.row + 1, [_pinsArray count]);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate]


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Review *lReview = ((PinInfoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).review;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pinInfoCollectionViewDidSelectCell:)]) {
        [self.delegate pinInfoCollectionViewDidSelectCell:lReview];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
