//
//  VideoCell.m
//  MyReelty
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "VideoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Network+Processing.h"
#import "SAMHUDView.h"
#import "UIView+Layer.h"
#import "NSString+DivideNumber.h"

@interface VideoCell()<AVPlayerViewControllerDelegate> {
    AVPlayerViewController *_playerVC;
}

@property (weak, nonatomic) IBOutlet UIButton *showMenuButton;

- (IBAction)showMenuBtnPressed:(UIButton *)sender;

@end


@implementation VideoCell {
    
}

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.videoView.image = nil;
    self.poupMenu.hidden = YES;
}

- (void)setReview:(Review *)review {
    _review = review;
    NSString *url1 = review.thumb_url;
    [self.videoView setImageWithURL:[NSURL URLWithString:url1] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.zipLabel.text = [NSString stringWithFormat:@"%@, %@",review.address, review.city];
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@",review.state ,review.zipcode];
    self.priceLabel.text = [[ NSString stringWithFormat:@"%lu" ,(NSUInteger) review.price] divideNumber];
    if (review.liked) {
        [self.likeButton setSelected:YES];
    } else {
        [self.likeButton setSelected:NO];
    }
    if (review.bookmarked) {
        [self.bookmarkButton setSelected:YES];
    } else {
        [self.bookmarkButton setSelected:NO];
    }
    
}

#pragma mark - Private methods


#pragma mark - Actions
- (IBAction)likeBtnPressed:(id)sender {
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableCellLikeButtonPressed:)]) {
        [self.delegate tableCellLikeButtonPressed:self];
    }
}

- (IBAction)bookmarkBtnPressed:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableCellBookmarkButtonPressed:)]) {
        [self.delegate tableCellBookmarkButtonPressed:self];
    }
}

- (IBAction)shareBtnPressed:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableCellShareButtonPressed:)]) {
        [self.delegate tableCellShareButtonPressed:self];
    }
    
}

- (IBAction)showMenuBtnPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableCellShowMenuButtonPressed:)]) {
        [self.delegate tableCellShowMenuButtonPressed:self];
    }

}
@end