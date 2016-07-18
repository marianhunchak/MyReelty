//
//  VideoCell.h
//  MyReelty
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Review.h"

@class VideoCell;
@protocol TableCellDelegate <NSObject>
@optional
- (void)tableCellBookmarkButtonPressed:(VideoCell *)cell;
- (void)tableCellShareButtonPressed:(VideoCell *)cell;
- (void)tableCellLikeButtonPressed:(VideoCell *)cell;
- (void)tableCellShowMenuButtonPressed:(VideoCell *)cell;

@end


@interface VideoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *videoView;
@property (weak, nonatomic) IBOutlet UIView *poupMenu;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) id <TableCellDelegate> delegate;

@property (nonatomic, strong) NSURL *videoUrl;
@property (strong, nonatomic) AVPlayer * player;
@property (strong, nonatomic) Review *review;
@property (assign, nonatomic) double rowHeight;

- (IBAction)likeBtnPressed:(id)sender;
- (IBAction)bookmarkBtnPressed:(id)sender;
- (IBAction)shareBtnPressed:(id)sender;

@end
