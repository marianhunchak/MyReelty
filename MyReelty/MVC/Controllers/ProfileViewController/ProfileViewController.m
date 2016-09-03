//
//  ProfileViewController.m
//  MyReelty
//
//  Created by Admin on 15.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "Profile.h"
#import "CellFabric.h"
#import "DBProfile.h"
#import "OptionsTableController.h"
#import "VideoCell.h"
#import "Network+Processing.h"
#import "ReviewViewController.h"
#import "SAMHUDView.h"
#import "Page.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define SBSI_GO_TO_OPTIONS @"showOptions"


typedef NS_ENUM(NSInteger, ListType) {
    ListTypeUploads = 0,
    ListTypeBookmarks = 1
};

static CGFloat sectionHeaderHeight = 40.f;

@interface ProfileViewController () <UITabBarDelegate, TableCellDelegate> {
    CellFabric *_cellFabric;
}
@property (strong, nonatomic) NSMutableArray *accountReviews;
@property (strong, nonatomic) DBProfile *profile;
@property (strong, nonatomic) Page *page;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (assign, nonatomic) ListType listType;
@property (strong, nonatomic) IBOutlet UIView *noBookmarksView;
@property (weak, nonatomic) IBOutlet UIImageView *footerImageView;
@property (weak, nonatomic) IBOutlet UITextView *footerTextView;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellFabric = [[CellFabric alloc] initWithTV:self.tableView reuseID:@"ProfileCellTableViewCell"];
    [self.tableView registerNib: [UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
    
//    [self.refreshControl beginRefreshing];
    
    if (self.showCurrentUserProfile) {
        
        
        _listType = ListTypeUploads;
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Uploads", @"My Videobook"]];
        _segmentControl.tintColor = [UIColor redColor];
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];

        __weak typeof(self)weakSelf = self;
        
        [Network profileWithCompletion:^(id object, NSError *error) {
            if (!error) {
                weakSelf.profile = object;
                [weakSelf.tableView reloadData];
            }
        }];
    }
    
    self.tableView.tableFooterView = nil;
    
    self.allowLoadData = YES;
    [self reloadTableData];
    self.allowLoadMore = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.showCurrentUserProfile) {
        
        NSMutableArray *lArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        if (lArray.count > 2) {
            [lArray removeObjectAtIndex:1];
            self.navigationController.viewControllers = lArray;
        }
        
        self.profile = [DBProfile main];
        
        self.tabBarController.tabBar.hidden = NO;
        [self.navigationItem setHidesBackButton:YES animated:NO];
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"options"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(showOptions)];
        self.navigationItem.rightBarButtonItem = optionsButton;
        
        [self configureFooterView];
        
    } else {
        
        __weak typeof(self) weakSelf = self;
        
        [Network profileForUserID:weakSelf.userID WithCompletion:^(id object, NSError *error) {
            if (!error) {
                weakSelf.profile = object;
                [weakSelf.tableView reloadData];
                [self configureFooterView];
            }
        }];
        
        [self.navigationController.tabBarController.tabBar setHidden:YES];
        [self.navigationItem setTitle:@"Profile"];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


#pragma mark - Private methods 

- (void)reloadTableData {
    
    if (self.isLoadingData || !self.allowLoadData) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.isLoadingData = YES;
    [self loadDataMore:NO];
    [self showLoadMoreProgress:YES];
}

- (void)loadDataMore:(BOOL)more {
    
    __weak typeof(self)weakSelf = self;
    
    void (^getReviews)(NSDictionary *, NSError *) = ^(NSDictionary *array, NSError *error) {
        
        if (error == nil) {
            
            NSArray *lArray = [array objectForKey:@"reviews"];
            if(weakSelf.isLoadingMore) {
                NSUInteger startIndex = [weakSelf.accountReviews count];
                [weakSelf.accountReviews addObjectsFromArray:lArray];
                
                NSMutableArray *newRowsPaths = [NSMutableArray new];
                for(NSUInteger i = startIndex; i < [weakSelf.accountReviews count]; i++) {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:1];
                    [newRowsPaths addObject:newPath];
                }
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            } else {
                
                UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                weakSelf.accountReviews = [lArray mutableCopy];
                [weakSelf.tableView reloadData];
                
                if (weakSelf.tableView.contentOffset.y > cell.frame.size.height) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }

            }
            
            weakSelf.allowLoadMore = [weakSelf.accountReviews count] < ((Page *)[array objectForKey:@"page"]).total_entries;
        }
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
        
        weakSelf.isLoadingData = NO;
        weakSelf.isLoadingMore = NO;
        
        if ([weakSelf.accountReviews count] == 0 && !error) {
            weakSelf.tableView.tableFooterView = self.noBookmarksView;
        } else {
            [weakSelf showLoadMoreProgress:NO];
        }
    };
    
    if (self.showCurrentUserProfile) {
        
        if (_listType == ListTypeUploads) {
            [Network accountReviewsLoadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
                weakSelf.page = [array objectForKey:@"page"];
                getReviews(array, error);
            }];
        } else {
            [Network listBookmarkedReviewsLoadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
                weakSelf.page = [array objectForKey:@"page"];
                getReviews(array, error);
            }];
        }
        
    } else {
        
        [Network userReviewsForUserID:weakSelf.userID loadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
               weakSelf.page = [array objectForKey:@"page"];
               getReviews(array, error);
        }];
    }
    
}

- (void)configureFooterView {
    
    NSString *imageName = _listType == ListTypeBookmarks ? @"bookmarksEmpty" : @"uploadsEmpty";
    _footerImageView.image = [UIImage imageNamed:imageName];
    
    NSString *textViewContent = @"";
    
    if (_showCurrentUserProfile) {
        
        switch (_listType) {
            case ListTypeUploads:
                textViewContent = @"You don't have any videos uploaded. Please visit MyReelty (http://myreelty.com) to upload your first video.";
                break;
            case ListTypeBookmarks:
                textViewContent = @"You have no bookmarks.\nThey will be saved here.";
                break;
                
            default:
                break;
        }
    } else {
        
        textViewContent = [NSString stringWithFormat:@"%@ don't have any videos uploaded.", _profile.name];
    }
    
    _footerTextView.text = textViewContent;
}

#pragma mark - Actions

- (void)showOptions {
    [self performSegueWithIdentifier:SBSI_GO_TO_OPTIONS sender:self];
}

- (void)segmentControlValueChanged:(UISegmentedControl *)sender {
    
    _listType = sender.selectedSegmentIndex;
    
    [self reloadTableData];
    [self configureFooterView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;                                              //number of section in table
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return _accountReviews.count;
}

- (NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 1 && !_showCurrentUserProfile)
        return [NSString stringWithFormat:@"Uploads (%i)", (integer_t)_page.total_entries];
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [ProfileCellTableViewCell heightForInfoUser:self.profile.description_ inTable:self.tableView];
    } else {
        return (int)(self.view.bounds.size.width * koeficientForCellHeight);
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ProfileCellTableViewCell *cell = [_cellFabric createCell:tableView idexPath:indexPath reuseID:@"ProfileCellTableViewCell" model:self.profile];
        return cell;
    }
    
    if (indexPath.section == 1) {
        VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.review = [self.accountReviews objectAtIndex:indexPath.row];
        cell.delegate = self;
        return  cell;
    }
    return nil;
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
        Review *review = [self.accountReviews objectAtIndex:indexPath.row];
        videoVC.reiew = review;
        
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 1 && _showCurrentUserProfile) {
        
        UIView *lBackView = [[UIView alloc] initWithFrame:CGRectMake(5.f, 0.f, tableView.frame.size.width - 10.f, sectionHeaderHeight)];
        lBackView.backgroundColor = [UIColor whiteColor];
        _segmentControl.frame = CGRectMake(lBackView.frame.origin.x,
                                           lBackView.frame.origin.y,
                                           lBackView.frame.size.width,
                                           30.f);
        _segmentControl.center = lBackView.center;
        [lBackView addSubview:_segmentControl];
        
        return  lBackView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1 ) {
        return sectionHeaderHeight;
    }
    
    return 0.f;
}

#pragma mark - Notifications

- (void)reloadAllData:(NSNotification *) sender {
    
    __weak typeof(self)weakSelf = self;
    
    if ([sender.name isEqualToString:LOG_OUT_BUTTON_PRESSED]) {
        [DBProfile main].avatarUrl = nil;
    } else {
        [Network profileWithCompletion:^(id object, NSError *error) {
            if (!error) {
                weakSelf.profile = object;
                [weakSelf.tableView reloadData];
            }
        }];
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
    
    if (_listType == ListTypeBookmarks) {
        [self deleteCellWhithReview:[sender object]];
    }
    
}
- (void)bookmarkDidChange:(NSNotification *)sender {
    
    if (_listType == ListTypeBookmarks) {
        [self deleteCellWhithReview:[sender object]];
    }
}

- (void)updateReviewInfo:(Review *)lReview {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_==%@",lReview.id_];
    
    NSArray *lArray = [self.accountReviews filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [self.accountReviews indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:1];
    
    ((Review *)[self.accountReviews objectAtIndex:row]).liked = lReview.liked;
    ((Review *)[self.accountReviews objectAtIndex:row]).bookmarked = lReview.bookmarked;
    
    [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteCellWhithReview:(Review *)lReview {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_==%@",lReview.id_];
    
    NSArray *lArray = [self.accountReviews filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [self.accountReviews indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:1];
    
    [self.accountReviews removeObjectAtIndex:row];
    self.previousIndexPath = nil;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
    
    if (![self.accountReviews count]) {
        
        self.tableView.tableFooterView = self.noBookmarksView;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SBSI_GO_TO_OPTIONS]) {
        OptionsTableController *filterVC = segue.destinationViewController;
    }
}

@end
