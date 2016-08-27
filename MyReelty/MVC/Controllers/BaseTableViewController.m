//
//  BaseTableViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 18/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "BaseTableViewController.h"
#import "VideoCell.h"
#import "Review.h"
#import "Network+Processing.h"

@interface BaseTableViewController () <UITableViewDataSource, UITableViewDelegate, TableCellDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *reviews;
@property (strong, nonatomic) UIView *activityIndicator;


@end

static NSString *CellIdentifier = @"Cell";

static NSString * const reuseIdentifier = @"reviewCell";

@implementation BaseTableViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookmarkBtnPressedOnReviewController:)
                                                 name:BOOKMARK_PRESSED_ON_REVIEW_CONTROLLER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeBtnPressedOnReviewController:)
                                                 name:LIKE_PRESSED_ON_REVIEW_CONTROLLER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeDidChange:)
                                                 name:LIKE_DID_CHANGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookmarkDidChange:)
                                                 name:BOOKMARK_DID_CHANGE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData:)
                                                 name:LOG_OUT_BUTTON_PRESSED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData:)
                                                 name:USER_DID_LOG_IN
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _previousIndexPath = nil;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOOKMARK_PRESSED_ON_REVIEW_CONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LIKE_PRESSED_ON_REVIEW_CONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LIKE_DID_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOOKMARK_DID_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOG_OUT_BUTTON_PRESSED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_DID_LOG_IN object:nil];
}

- (UIView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 40.f)];
        
        UIActivityIndicatorView *actIndicator = [[ UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        actIndicator.center = CGPointMake(_activityIndicator.frame.size.width / 2.f, _activityIndicator.frame.size.height / 2.f);
        [_activityIndicator addSubview:actIndicator];
        [actIndicator startAnimating];
        
    }
    return _activityIndicator;
}

#pragma mark - Private methods

- (void) updateReviewInfo:(Review *) lReview{
}

- (void) loadDataMore:(BOOL) more {
}

- (void) showLoadMoreProgress:(BOOL) show {
    
    self.tableView.tableFooterView = show ? self.activityIndicator : nil;
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL) isInternetConnection
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - TableCellDelegate

- (void)tableCellLikeButtonPressed:(VideoCell *)cell {
    void (^sendNotification)() = ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKE_DID_CHANGE_NOTIFICATION object:cell.review userInfo:[NSDictionary dictionaryWithObject:NSStringFromClass([self class]) forKey:CLASS_NAME]];
    };
    
    if (cell.review.liked) {
        [Network deleteLikeForReviewID:cell.review.id_ WithCompletion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                cell.review.liked = NO;
                [cell.likeButton setSelected:NO];
                sendNotification();
            }
        }];
    } else {
        [Network createLikeForReviewID:cell.review.id_ WithCompletion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                cell.review.liked = YES;
                [cell.likeButton setSelected:YES];
                sendNotification();
            }
        }];
    }   
}

- (void)tableCellBookmarkButtonPressed:(VideoCell *)cell {
    
    void (^sendNotification)() = ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKMARK_DID_CHANGE_NOTIFICATION object:cell.review userInfo:[NSDictionary dictionaryWithObject:NSStringFromClass([self class]) forKey:CLASS_NAME]];
    };
    Review *lCurrentReview = cell.review;
    if (lCurrentReview.bookmarked) {
        [Network deleteBookmarkForReviewID:lCurrentReview.id_ WithCompletion:^(id object, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                cell.review.bookmarked = NO;
                [cell.bookmarkButton setSelected:NO];
                sendNotification();
            }
        }];
    } else {
        [Network createBookmarkForReviewID:lCurrentReview.id_ WithCompletion:^(id object, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                cell.review.bookmarked = YES;
                [cell.bookmarkButton setSelected:YES];
                sendNotification();
            }
        }];
    }
}

- (void)tableCellShowMenuButtonPressed:(VideoCell *)pCell {
    
    if (_previousIndexPath) {
        VideoCell *cell = [self.tableView cellForRowAtIndexPath:_previousIndexPath];
        cell.poupMenu.hidden = YES;
        if (_previousIndexPath == [self.tableView indexPathForCell:pCell]) {
            _previousIndexPath = nil;
            return;
        }
    }
    if (pCell.poupMenu.hidden) {
        
        pCell.poupMenu.hidden = NO;
        
    } else {
        
        pCell.poupMenu.hidden = YES;
    }
    _previousIndexPath = [self.tableView indexPathForCell:pCell];
    
    if ((pCell.frame.origin.y - self.tableView.contentOffset.y) < 0) {
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:pCell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)tableCellShareButtonPressed:(VideoCell *)cell {
    
    if ([self isInternetConnection]) {
        NSString *shareText = @"This is my text I want to share.";
        NSURL *shareURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://myreelty.com/#/review/%@", cell.review.id_]];
        NSArray *itemsToShare = @[shareText, shareURL];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        [self showAlertWithMessage:@"No Internet connection!" handler:nil];
    }
}

#pragma mark - Notifications

- (void)likeBtnPressedOnReviewController:(NSNotification *) sender {
}
- (void)bookmarkBtnPressedOnReviewController:(NSNotification *) sender {
}
- (void)likeDidChange:(NSNotification *) sender {
}
- (void)bookmarkDidChange:(NSNotification *) sender {
}
- (void)reloadAllData:(NSNotification *) sender {
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_isLoadingData || !_allowLoadData || !_allowLoadMore || ![self isInternetConnection]) {
        return;
    }
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    if(distanceFromBottom <= 2 * height && scrollView.contentSize.height >= self.view.frame.size.height) {
        _isLoadingMore = YES;
        _isLoadingData = YES;
        
        [self showLoadMoreProgress:YES];
        [self loadDataMore:YES];
    }
}

@end
