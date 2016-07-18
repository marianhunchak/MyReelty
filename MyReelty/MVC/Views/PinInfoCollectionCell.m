//
//  PinInfoCollectionCell.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PinInfoCollectionCell.h"
#import "Network.h"
#import "Review.h"
#import "NSString+DivideNumber.h"

@interface PinInfoCollectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *adrressLable;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reviewImageView;
@property (weak, nonatomic) IBOutlet UILabel *reviewNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;

@property (nonatomic, strong) NSString *imageUrl;

@end

@implementation PinInfoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewInfo:)
                                                 name:LIKE_DID_CHANGE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewInfo:)
                                                 name:BOOKMARK_DID_CHANGE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewInfo:)
                                                 name:LIKE_PRESSED_ON_REVIEW_CONTROLLER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewInfo:)
                                                 name:BOOKMARK_PRESSED_ON_REVIEW_CONTROLLER
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters 

-(void)setReviewID:(NSString *)reviewID {
    _reviewID = reviewID;

    __weak typeof(self) weakSelf = self;
    [Network getReviewForId:weakSelf.reviewID WithCompletion:^(id object, NSError *error) {
        if (!error) {
            
            Review *lReview = (Review *)object;
            weakSelf.review = lReview;
            
            NSString *url1= lReview.thumb_url;
            [weakSelf.reviewImageView setImageWithURL:[NSURL URLWithString:url1] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            weakSelf.adrressLable.text = [NSString stringWithFormat:@"%@", lReview.address];
            weakSelf.zipLabel.text = [NSString stringWithFormat:@"%@, %@, %@",lReview.city, lReview.state, lReview.zipcode];;
            weakSelf.priceLabel.text = [NSString stringWithFormat:@"$ %@",[[ NSString stringWithFormat:@"%1.f" , lReview.price] divideNumber]];
        }
    }];
}

- (void)setReviewRange:(NSRange)reviewRange {
    _reviewRange = reviewRange;
    _reviewNumberLabel.text = [NSString stringWithFormat:@"%lu of %lu", reviewRange.location, reviewRange.length];
    _leftArrow.hidden = reviewRange.location == 1 ? YES : NO;
    _rightArrow.hidden = reviewRange.location == reviewRange.length ? YES : NO;
}

- (void)prepareForReuse {
    _reviewNumberLabel.text = nil;
    _reviewImageView.image = nil;
}

#pragma mark - Notification 

- (void) updateReviewInfo:(NSNotification *)sender {
    
    Review *lReview = [sender object];
    
    if ([lReview.id_ isEqualToString:_reviewID]) {
        _review.liked = lReview.liked;
        _review.bookmarked = lReview.bookmarked;
        [self reloadInputViews];
    }
    
}

@end
