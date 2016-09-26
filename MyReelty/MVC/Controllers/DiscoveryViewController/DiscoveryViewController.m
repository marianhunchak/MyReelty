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
#import "Category.h"
#import "SearchTile.h"
#import "Page.h"
#import "SearchTileCell.h"
#import "MapViewController.h"
#import "NSString+DivideNumber.h"

static NSString *videoCellIdentifier = @"Cell";
static NSString *premiumCellIdentifier = @"premiumCell";
static NSString *searchTileCellIdentifier = @"searchTileCell";

@interface DiscoveryViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TableCellDelegate> {
}
@property (strong, nonatomic) IBOutlet UILabel *totalVideoCountLabel;

@property (strong, nonatomic) NSArray *premiumReviews;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *searchTiles;
@property (strong, nonatomic) NSArray *reviews;
@property (strong, nonatomic) UIView *activityIndicator;
@property (strong, nonatomic) NSIndexPath *selectedRowIndex;
@property (strong, nonatomic) PremiumVideoCollectionView *premiumVideoCollectionView;

@end

@implementation DiscoveryViewController

static NSString * const reuseIdentifier = @"reviewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
 
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTileCell" bundle:nil] forCellReuseIdentifier:searchTileCellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];

    _premiumVideoCollectionView = [PremiumVideoCollectionView newView];
    
    [self reloadTableData];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_logo_small.png"]];
    titleImageView.clipsToBounds = YES;
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = CGRectMake(0, 0, 40, 20);
    self.navigationItem.titleView = titleImageView;
    
//    self.tabBarController.navigationItem.titleView.center = CGPointMake(self.view.center.x,
//                                                                        self.tabBarController.navigationItem.titleView.center.y);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)reloadTableData {
    
    [self.refreshControl beginRefreshing];
    
    [self getPremiumReviews];
    [self getCategories];
    [self getSearchTiles];
    [self getTotalVideoCount];

}

#pragma mark - Private methods 

- (void)getPremiumReviews {
    
    __weak typeof(self) weakSelf = self;
    
    [Network getPremiumReviewsWithConletion:^(NSArray *array, NSError *error) {
        
        DLog(@"%@", array);
        
        weakSelf.premiumReviews = array;
        [weakSelf.tableView reloadData];
    }];
}

- (void)getCategories {
    
    __weak typeof(self) weakSelf = self;
    
    [Network getCategoriesWithCompletion:^(NSArray *array, NSError *error) {

        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        weakSelf.categories = [array sortedArrayUsingDescriptors:sortDescriptors];
        
        [weakSelf.tableView reloadData];
        
        
    }];
}

- (void)getSearchTiles {
    
    __weak typeof(self)weakSelf = self;
    
    [Network getSearchTilesWithCompletion:^(NSArray *array, NSError *error) {
        
        weakSelf.searchTiles = array;
        
        [weakSelf.tableView reloadData];
        
        [weakSelf.refreshControl endRefreshing];
    }];
    
}

- (void)getTotalVideoCount {
    
    __weak typeof(self)weakSelf = self;
    
    [Network getTotalReviesCountWithCompletion:^(id object, NSError *error) {
       
        weakSelf.totalVideoCountLabel.text = [[NSString stringWithFormat:@"%lu", ((Page *)object).total_entries] divideNumber];
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [((Category *)_categories[0]).reviews count];
    } else if (section == 2) {
        return [((Category *)_categories[1]).reviews count];
    }
    
    return _searchTiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"premium"];
        
        [cell addSubview:_premiumVideoCollectionView];
        _premiumVideoCollectionView.premiumRevies = _premiumReviews;
        
        return cell;
        
    } else if (indexPath.section == 1) {
    
        VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];

        cell.rowHeight = self.view.bounds.size.width * koeficientForCellHeight;
        cell.review = [((Category *)_categories[0]).reviews objectAtIndex:indexPath.row];
        cell.delegate = self;
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
        VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
        
        cell.rowHeight = self.view.bounds.size.width * koeficientForCellHeight;
        cell.review = [((Category *)_categories[1]).reviews objectAtIndex:indexPath.row];
        cell.delegate = self;
        
        return cell;
    }
    
    SearchTileCell *cell = [tableView dequeueReusableCellWithIdentifier:searchTileCellIdentifier];
    
    SearchTile *lSearchTile = _searchTiles[indexPath.row];
    
    [cell.backgroundImageView setImageWithURL:lSearchTile.imageURL placeholderImage:nil];
    
    cell.nameLabel.text = lSearchTile.name;
    
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
        
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        
        return (int)(self.view.bounds.size.width * koeficientForCellHeight);
    }
    
    return  self.view.frame.size.height / 3.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        return;
    } else if (indexPath.section == 3) {
        
        if ([[[self.tabBarController viewControllers] objectAtIndex:1] isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *lNavigationController = [[self.tabBarController viewControllers] objectAtIndex:1];
            
            [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:lNavigationController];
            [self.tabBarController setSelectedIndex:1];
            
            [lNavigationController popToRootViewControllerAnimated:NO];
            
            MapViewController *mapVC = (MapViewController *)lNavigationController.visibleViewController;
            
            SearchTile *lSearchTile = _searchTiles[indexPath.row];
            
            [mapVC reloadSearchResultWithAddress:lSearchTile.search_query];

            mapVC.searchBar.text = lSearchTile.search_query;
            
        }
    
        return;
    }
    
    if (self.previousIndexPath) {
        VideoCell *cell = [tableView cellForRowAtIndexPath:self.previousIndexPath];
        [UIView animateWithDuration:0.5 animations:^{
            cell.poupMenu.alpha = 0;
        }];
        self.previousIndexPath = nil;
    } else {
        
        ReviewViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
        
        NSInteger index = indexPath.section == 1 ? 0 : 1;
        
        Review *review = [((Category *)_categories[index]).reviews objectAtIndex:indexPath.row];
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
        
    } else if (section == 1) {
        return ((Category *)_categories[0]).name;
    } else if (section == 2) {
        return ((Category *)_categories[1]).name;
    }
    
    return @"Suggestions";
}

#pragma mark - Notifications

- (void)reloadAllData:(NSNotification *) sender {
    
    [self.refreshControl beginRefreshing];
    [self reloadTableData];
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
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:1];
    
    ((Review *)[self.reviews objectAtIndex:row]).liked = lReview.liked;
    ((Review *)[self.reviews objectAtIndex:row]).bookmarked = lReview.bookmarked;
    
    [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
}

@end
