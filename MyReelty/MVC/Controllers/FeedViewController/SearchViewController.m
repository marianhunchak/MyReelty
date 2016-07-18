//
//  FrontViewController.m
//  MyReelty
//
//  Created by Admin on 01.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SearchViewController.h"
#import "VideoCell.h"
#import "UIViewController+NJKFullScreenSupport.h"
#import "NJKScrollFullScreen.h"
#import "MapViewController.h"
#import "FiltersViewController.h"
#import "Review.h"
#import "Network+Processing.h"
#import "SAMHUDView.h"
#import "ReviewViewController.h"
#import "SearchFilter.h"
#import "UIImageView+AFNetworking.h"

#define SBSI_GO_TO_FILTER @"goToFilters"

static NSString *CellIdentifier = @"Cell";
typedef void (^ObjectCompletionBlock)(id object, NSError *error);

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TableCellDelegate, UIScrollViewDelegate> {
    
    UIBarButtonItem *mapButton;
    UIBarButtonItem *filterButton;
}

@property (nonatomic, strong) MapViewController *mapViewController;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UILabel *infoLabel;

@end


@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.navigationItem.titleView = self.searchBar;

//    mapButton = [[ UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map"]
//                                                  style: UIBarButtonItemStylePlain
//                                                 target:self
//                                                 action:@selector(showMapController:)];
    mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMapController:)];
    mapButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = mapButton;
    
//    filterButton = [[ UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filters"]
//                                                   style: UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(filtersButtonPressed:)];
    filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(filtersButtonPressed:)];
    filterButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardOnTap)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.searchFilter = self.mapViewController.searchFilter;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadSearchresult) forControlEvents:UIControlEventValueChanged];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40.f)];
    _infoLabel.text = nil;
    _infoLabel.textColor = [UIColor grayColor];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont systemFontOfSize:13];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.blurEffectView removeFromSuperview];
//    UIButton *clearButton = [textField valueForKey:@"_clearButton"];
//    [clearButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal & UIControlStateHighlighted];
  
    [self recursivelySkinTextField:self.searchBar];
    self.mapViewController.searchResultChanged = NO;
    
    if(!_reviews || _searchFilter.isChanged || _searchResultChanged) {
    self.allowLoadData = YES;
    self.allowLoadMore = YES;
    [self reloadSearchresult];
    }
    
}


- (void)recursivelySkinTextField:(UIView *)view {
    if (!view.subviews.count) return;
    
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subview;
            [searchField setTextColor:[UIColor whiteColor]];
            searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search by ZIP, city or address"
                                                                                attributes:@{
                                                           NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.5]
                                                           }];
            [searchField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.5]];
        }
        [self recursivelySkinTextField:subview];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _searchResultChanged = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SBSI_GO_TO_FILTER]) {
        FiltersViewController *filterVC = segue.destinationViewController;
        filterVC.filter = _searchFilter;
    }
}

#pragma mark - Private methods

- (MapViewController *)mapViewController {
    if(!_mapViewController) {
        _mapViewController = [self.navigationController.viewControllers objectAtIndex:0];
    }
    return _mapViewController;
}


-(void) reloadSearchresult {
    
    if (self.isLoadingData || !self.allowLoadData) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.isLoadingData = YES;
    [self loadDataMore:NO];
    
}

- (void)loadDataMore:(BOOL) loadMore {
    
    self.tableView.tableHeaderView = nil;
    if (!self.mapViewController.searchResultChanged) {
    self.mapViewController.searchResultChanged = _searchFilter.isChanged;
    }
    _searchFilter.isChanged = NO;

    [self.refreshControl beginRefreshing];

    __weak typeof(self)weakSelf = self;
    
    NSString *lAdrress = [self.searchBar.text encodeUrlString];
    
    if ([lAdrress isEqualToString:@""]) {
        lAdrress = [self.mapViewController.userLocationString encodeUrlString];
    }

    [Network listAllNearestReviewsWhithAddress:lAdrress andFilter:_searchFilter loadMore:loadMore withCompletion:^(NSArray *array, NSError *error) {
//        if (error) {
//            NSString *msg = [ErrorHandler handleError:error];
//            weakSelf.allowLoadMore = NO;
//            weakSelf.infoLabel.text = msg;
//            if (weakSelf.isLoadingMore) {
//            weakSelf.tableView.tableFooterView = weakSelf.infoLabel;
//            } else {
//            weakSelf.tableView.tableHeaderView = weakSelf.infoLabel;
//                [weakSelf.tableView reloadData];
//            }
//        }
        if (error == nil) {
            if (![array count] && !weakSelf.isLoadingMore) {
                weakSelf.reviews = nil;
                [weakSelf.tableView reloadData];
                weakSelf.infoLabel.text = @"Nothing was found";
                weakSelf.tableView.tableHeaderView = weakSelf.infoLabel;
            }

             else if(weakSelf.isLoadingMore) {
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
                weakSelf.tableView.tableHeaderView = nil;
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

- (void) addBlurEffectForView:(UIView *) backgroundView {
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        if ([self.view.subviews containsObject:self.blurEffectView]) {
            return;
        }
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVibrancyEffect *vibracyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:vibracyEffect];
        _blurEffectView.effect = blurEffect;
        _blurEffectView.frame = backgroundView.bounds;
        _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:_blurEffectView];
    }
    //    else {
    //        self.view.backgroundColor = [UIColor blackColor];
    //    }
    
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Actions

- (void) hideKeyboardOnTap {
    [self.searchBar resignFirstResponder];
    [self.blurEffectView removeFromSuperview];
}

- (void) showMapController: (UIBarButtonItem *) sender {
    
    if (self.mapViewController.searchResultChanged) {
        [self.mapViewController didEnterZip:self.searchBar.text];
    }
    self.mapViewController.searchBar.text = self.searchBar.text;
    self.mapViewController.searchFilter = self.searchFilter;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)filtersButtonPressed:(id)sender {
    
    [self.searchBar resignFirstResponder];
    [self performSegueWithIdentifier:SBSI_GO_TO_FILTER sender:self];
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
//        videoVC.cell = [tableView cellForRowAtIndexPath:_previousIndexPath];

        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.blurEffectView removeFromSuperview];
    self.mapViewController.searchResultChanged = YES;

    [self reloadSearchresult];

}

#pragma mark - Notifications 

- (void)reloadAllData:(NSNotification *) sender {
    
    if (self.isViewLoaded) {
        self.searchBar.text = @"";
        [self.tableView setContentOffset:CGPointZero];
        [self.searchFilter resetFilters];
        self.allowLoadData = YES;
        self.allowLoadMore = YES;
        [self reloadSearchresult];
    }
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

@end
