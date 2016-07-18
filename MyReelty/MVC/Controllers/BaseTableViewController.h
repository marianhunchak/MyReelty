//
//  BaseTableViewController.h
//  MyReelty
//
//  Created by Marian Hunchak on 18/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorHandler.h"

@class Review;

@interface BaseTableViewController : UITableViewController

@property (strong, nonatomic) NSIndexPath *previousIndexPath;
@property (assign, nonatomic) BOOL isLoadingData;
@property (assign, nonatomic) BOOL allowLoadData;
@property (assign, nonatomic) BOOL allowLoadMore;
@property (assign, nonatomic) BOOL isLoadingMore;
@property (assign, nonatomic) BOOL allowReloadData;


- (void) showLoadMoreProgress:(BOOL) show;

- (void)likeBtnPressedOnReviewController:(NSNotification *) sender;
- (void)bookmarkBtnPressedOnReviewController:(NSNotification *) sender;
- (void)likeDidChange:(NSNotification *) sender;
- (void)bookmarkDidChange:(NSNotification *) sender;
- (void)updateReviewInfo:(Review *) lReview;
- (void)reloadAllData;

@end
