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
#import "ErrorHandler.h"

static NSString *CellIdentifier = @"Cell";

@interface DiscoveryViewController () <UITableViewDataSource, UITableViewDelegate, TableCellDelegate, UIScrollViewDelegate, TableCellDelegate> {
}

@property (strong, nonatomic) NSMutableArray *reviews;
@property (strong, nonatomic) UIView *activityIndicator;
@property (strong, nonatomic) NSIndexPath *selectedRowIndex;

@end

@implementation DiscoveryViewController

static NSString * const reuseIdentifier = @"reviewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
 
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];

    [self.refreshControl beginRefreshing];
    
    self.allowLoadData = YES;
    [self reloadTableData];
    
    self.allowLoadMore = YES;
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

- (void)reloadTableData {
    
    if (self.isLoadingData || !self.allowLoadData) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.isLoadingData = YES;
    [self loadDataMore:NO];
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

- (void) showLoadMoreProgress:(BOOL) show {
    
    self.tableView.tableFooterView = show ? self.activityIndicator : nil;
}

- (void)loadDataMore:(BOOL)more {
    __weak typeof(self)weakSelf = self;
    [Network reviewsWithFilter:nil loadMore:more completion:^(NSArray *array, NSError *error) {
        
        if (error == nil) {
            if(weakSelf.isLoadingMore) {
                NSUInteger startIndex = [weakSelf.reviews count];
                [weakSelf.reviews addObjectsFromArray:array];
                
                NSMutableArray *newRowsPaths = [NSMutableArray new];
                for(NSUInteger i = startIndex; i < [weakSelf.reviews count]; i++) {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [newRowsPaths addObject:newPath];
                }
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            } else {
                weakSelf.reviews = [array mutableCopy];
                [weakSelf.tableView reloadData];
            }
            
            weakSelf.allowLoadMore = [array count] >= REVIEWS_PAGE_SIZE;
        }
        [weakSelf.refreshControl endRefreshing];
        
        weakSelf.isLoadingData = NO;
        weakSelf.isLoadingMore = NO;
        [weakSelf showLoadMoreProgress:NO];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _reviews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  (int)(self.view.bounds.size.width * koeficientForCellHeight);
    //    return 230.f;
}
#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Review *review = [self.reviews objectAtIndex:indexPath.row];
    
    cell.rowHeight = self.view.bounds.size.width * koeficientForCellHeight;
    cell.review = review;
    cell.delegate = self;
    //    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.previousIndexPath) {
        VideoCell *cell = [tableView cellForRowAtIndexPath:self.previousIndexPath];
        cell.poupMenu.hidden = YES;
        self.previousIndexPath = nil;
    }else {
        
        ReviewViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
        Review *review = [self.reviews objectAtIndex:indexPath.row];
        videoVC.reiew = review;
        self.selectedRowIndex = [tableView indexPathForSelectedRow];
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

#pragma mark - Notifications

-(void)reloadAllData:(NSNotification *) sender {
    
    [self.refreshControl beginRefreshing];
    self.allowLoadData = YES;
    [self reloadTableData];
    self.allowLoadMore = YES;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.isLoadingData || !self.allowLoadData || !self.allowLoadMore) {
        return;
    }
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    if(distanceFromBottom <= 2 * height) {
        self.isLoadingMore = YES;
        self.isLoadingData = YES;
        
        [self showLoadMoreProgress:YES];
        [self loadDataMore:YES];
    }
}

@end
