//
//  BookmarksViewController.m
//  MyReelty
//
//  Created by Admin on 12.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "BookmarksViewController.h"
#import "VideoCell.h"
#import "DBProfile.h"
#import "Network+Processing.h"
#import "Review.h"
#import "ReviewViewController.h"
#import "SAMHUDView.h"

static NSString *CellIdentifier = @"Cell";

@interface BookmarksViewController () <UITableViewDataSource, UITableViewDelegate, TableCellDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *bookmarkedReviews;
@property (nonatomic, strong) SAMHUDView *activityView;
@property (strong, nonatomic) IBOutlet UIView *noBookmarksView;

@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bookmarkedReviews = [ NSMutableArray array];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY] isEqualToString:@""]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.refreshControl beginRefreshing];
    self.tableView.tableHeaderView = nil;

    self.allowLoadData = YES;
    [self reloadTableData];
    self.allowLoadMore = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
}

#pragma mark - Private methods

- (SAMHUDView *)activityView {
    if(!_activityView) {
        _activityView = [[SAMHUDView alloc] initWithTitle:@"" loading:YES];
    }
    
    return _activityView;
}

- (void)reloadTableData {
    
    if (self.isLoadingData || !self.allowLoadData) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.isLoadingData = YES;
    [self loadDataMore:NO];
}


- (void)loadDataMore:(BOOL) loadMore {
    
    [self.refreshControl beginRefreshing];
    __weak typeof(self)weakSelf = self;
    [Network listBookmarkedReviewsLoadMore:loadMore WithCompletion:^(NSArray *array, NSError *error) {
        if (error == nil) {
            
            if ([array count] > 0) {
            weakSelf.tableView.tableHeaderView = nil;
            weakSelf.tableView.scrollEnabled = YES;
            } else if ([weakSelf.bookmarkedReviews count] == 0) {
                
                weakSelf.tableView.tableHeaderView = self.noBookmarksView;
                weakSelf.tableView.scrollEnabled = NO;
            }
            
            if(weakSelf.isLoadingMore) {
                NSUInteger startIndex = [weakSelf.bookmarkedReviews count];
                [weakSelf.bookmarkedReviews addObjectsFromArray:array];
                
                NSMutableArray *newRowsPaths = [NSMutableArray new];
                for(NSUInteger i = startIndex; i < [weakSelf.bookmarkedReviews count]; i++) {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [newRowsPaths addObject:newPath];
                }
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            } else {
                weakSelf.bookmarkedReviews = [array mutableCopy];
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

- (void)showActivityViewDelayed {
    [self.activityView show];
}

- (void)hideActivityView {
    [_activityView dismissAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarkedReviews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (int)(self.view.bounds.size.width * koeficientForCellHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Review *review = [self.bookmarkedReviews objectAtIndex:indexPath.row];
    cell.review = review;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.previousIndexPath) {
        VideoCell *cell = [tableView cellForRowAtIndexPath:self.previousIndexPath];
        cell.poupMenu.hidden = YES;
        self.previousIndexPath = nil;
    }else {
        
        ReviewViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
        Review *review = [self.bookmarkedReviews objectAtIndex:indexPath.row];
        videoVC.reiew = review;
        
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

#pragma mark - Notifications

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
    
    [self deleteCellWhithReview:[sender object]];
    
}
- (void)bookmarkDidChange:(NSNotification *)sender {
    
    [self deleteCellWhithReview:[sender object]];
}

- (void)updateReviewInfo:(Review *)lReview {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_==%@",lReview.id_];
    
    NSArray *lArray = [self.bookmarkedReviews filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [self.bookmarkedReviews indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:0];
    
    ((Review *)[self.bookmarkedReviews objectAtIndex:row]).liked = lReview.liked;
    ((Review *)[self.bookmarkedReviews objectAtIndex:row]).bookmarked = lReview.bookmarked;
    
    [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteCellWhithReview:(Review *)lReview {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_==%@",lReview.id_];
    
    NSArray *lArray = [self.bookmarkedReviews filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [self.bookmarkedReviews indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self.bookmarkedReviews removeObjectAtIndex:row];
    self.previousIndexPath = nil;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationLeft];
    
    if (![self.bookmarkedReviews count]) {
        
            self.tableView.tableHeaderView = self.noBookmarksView;
            self.tableView.scrollEnabled = NO;
    }
    [self.tableView endUpdates];
}

-(void)reloadAllData:(NSNotification *) sender {
    if ([sender.name isEqualToString:LOG_OUT_BUTTON_PRESSED]) {
        
        self.bookmarkedReviews = nil;
        [self.tableView reloadData];
        self.isLoadingData = NO;
        [self.navigationController popViewControllerAnimated:NO];
        [self removeFromParentViewController];
    } else {
        self.isLoadingData = NO;
        self.allowLoadData = YES;
        [self loadDataMore:NO];
        self.allowLoadMore = YES;
    }
}



@end
