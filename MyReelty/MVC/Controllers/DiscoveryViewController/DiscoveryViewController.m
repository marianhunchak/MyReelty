//
//  CollectionViewController.m
//  MyReelty
//
//  Created by Admin on 12.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "Network.h"
#import "Review.h"
#import "SAMHUDView.h"
#import "ReviewViewController.h"
#import "UIImageView+AFNetworking.h"
#import "VideoCell.h"
#import "PremiumVideoCell.h"
#import "ErrorHandler.h"
#import "PremiumReview.h"
#import "PremiumVideoCollectionView.h"

static NSString *videoCellIdentifier = @"Cell";
static NSString *premiumCellIdentifier = @"premiumCell";

@interface DiscoveryViewController () <UITableViewDataSource, UITableViewDelegate, TableCellDelegate, UIScrollViewDelegate, TableCellDelegate> {
}

@property (strong, nonatomic) NSArray *premiumReviews;
@property (strong, nonatomic) NSMutableArray *reviews;
@property (strong, nonatomic) UIView *activityIndicator;
@property (strong, nonatomic) NSIndexPath *selectedRowIndex;
@property (strong, nonatomic) PremiumVideoCollectionView *premiumVideoCollectionView;

@end

@implementation DiscoveryViewController

static NSString * const reuseIdentifier = @"reviewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    
    _reviews = [NSMutableArray array];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
 
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:videoCellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];

    _premiumVideoCollectionView = [PremiumVideoCollectionView newView];
    
    [Network getPremiumReviewsWithConletion:^(NSArray *array, NSError *error) {
        
        NSLog(@"%@", array);
        
        _premiumReviews = array;
        
        for (PremiumReview *lPremium in array) {
            [_reviews addObject:lPremium.review];
        }
        
        [self.tableView reloadData];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)reloadTableData {
//    
//    if (self.isLoadingData || !self.allowLoadData) {
//        [self.refreshControl endRefreshing];
//        return;
//    }
//    
//    self.isLoadingData = YES;
//    [self loadDataMore:NO];
//}

//- (UIView *)activityIndicator {
//    if (!_activityIndicator) {
//        _activityIndicator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 40.f)];
//        
//        UIActivityIndicatorView *actIndicator = [[ UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        actIndicator.center = CGPointMake(_activityIndicator.frame.size.width / 2.f, _activityIndicator.frame.size.height / 2.f);
//        [_activityIndicator addSubview:actIndicator];
//        [actIndicator startAnimating];
//        
//    }
//    return _activityIndicator;
//}

#pragma mark - Private methods 

- (void) showLoadMoreProgress:(BOOL) show {
    
    self.tableView.tableFooterView = show ? self.activityIndicator : nil;
}

//- (void)loadDataMore:(BOOL)more {
//    __weak typeof(self)weakSelf = self;
//    [Network reviewsWithFilter:nil loadMore:more completion:^(NSArray *array, NSError *error) {
//        
//        if (error == nil) {
//            if(weakSelf.isLoadingMore) {
//                NSUInteger startIndex = [weakSelf.reviews count];
//                [weakSelf.reviews addObjectsFromArray:array];
//                
//                NSMutableArray *newRowsPaths = [NSMutableArray new];
//                for(NSUInteger i = startIndex; i < [weakSelf.reviews count]; i++) {
//                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:0];
//                    [newRowsPaths addObject:newPath];
//                }
//                
//                [weakSelf.tableView beginUpdates];
//                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
//                [weakSelf.tableView endUpdates];
//            } else {
//                weakSelf.reviews = [array mutableCopy];
//                [weakSelf.tableView reloadData];
//            }
//            
//            weakSelf.allowLoadMore = [array count] >= REVIEWS_PAGE_SIZE;
//        }
//        [weakSelf.refreshControl endRefreshing];
//        
//        weakSelf.isLoadingData = NO;
//        weakSelf.isLoadingMore = NO;
//        [weakSelf showLoadMoreProgress:NO];
//    }];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    
    return _reviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
        
        _premiumVideoCollectionView.premiumRevies = _premiumReviews;
        [cell addSubview:_premiumVideoCollectionView];
        
        return cell;
    }
    
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    Review *review = [self.reviews objectAtIndex:indexPath.row];
    
    cell.rowHeight = self.view.bounds.size.width * koeficientForCellHeight;
    cell.review = review;
    cell.delegate = self;

    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        CGFloat fistCellHeight = self.view.frame.size.height / 2.f;
        
        CGRect frameBefore = _premiumVideoCollectionView.frame;
        frameBefore.size.height = fistCellHeight;
        frameBefore.size.width = self.view.frame.size.width;
        
        _premiumVideoCollectionView.frame = frameBefore;
        
        return fistCellHeight;
    }
    
    return  (int)(self.view.bounds.size.width * koeficientForCellHeight);
    //    return 230.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        return;
    }
    
    if (self.previousIndexPath) {
        VideoCell *cell = [tableView cellForRowAtIndexPath:self.previousIndexPath];
        cell.poupMenu.hidden = YES;
        self.previousIndexPath = nil;
    } else {
        
        ReviewViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
        Review *review = [self.reviews objectAtIndex:indexPath.row];
        videoVC.reiew = review;
        self.selectedRowIndex = [tableView indexPathForSelectedRow];
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.f;
    }
    
    return 40.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    
    return @"Featured";
}

#pragma mark - Notifications

- (void)reloadAllData:(NSNotification *) sender {
    
    [self.refreshControl beginRefreshing];
//    self.allowLoadData = YES;
//    [self reloadTableData];
//    self.allowLoadMore = YES;
    [self.tableView setContentOffset:CGPointZero];
    
}

- (void)likeBtnPressedOnReviewController:(NSNotification *)sender {
 
    [self updateReviewInfo:[sender object]];
}

- (void)likeDidChange:(NSNotification *)sender {
    if ([[sender.userInfo objectForKey:CLASS_NAME] isEqualToString:NSStringFromClass([self class])]) {
        return;
    }
    
    [self updateReviewInfo:[sender object]];
}

- (void)bookmarkBtnPressedOnReviewController:(NSNotification *)sender {
    [self updateReviewInfo:[sender object]];
    
}
- (void)bookmarkDidChange:(NSNotification *)sender {
    if ([[sender.userInfo objectForKey:CLASS_NAME] isEqualToString:NSStringFromClass([self class])]) {
        return;
    }
    [self updateReviewInfo:[sender object]];
}
- (void)updateReviewInfo:(Review *)lReview {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_==%@",lReview.id_];
    
    NSArray *lArray = [self.reviews filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [self.reviews indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:0];
    
    ((Review *)[self.reviews objectAtIndex:row]).liked = lReview.liked;
    ((Review *)[self.reviews objectAtIndex:row]).bookmarked = lReview.bookmarked;
    
    [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIScrollViewDelegate

@end
