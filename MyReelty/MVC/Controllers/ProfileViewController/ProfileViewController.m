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

@interface ProfileViewController () <UITabBarDelegate, TableCellDelegate> {
    CellFabric *_cellFabric;
}
@property (strong, nonatomic) NSMutableArray *accountReviews;
@property (strong, nonatomic) DBProfile *profile;
@property (strong, nonatomic) Page *page;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellFabric = [[CellFabric alloc] initWithTV:self.tableView reuseID:@"ProfileCellTableViewCell"];
    [self.tableView registerNib: [UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    if (self.showCurrentUserProfile) {

    __weak typeof(self)weakSelf = self;
    
    [Network profileWithCompletion:^(id object, NSError *error) {
        if (!error) {
            weakSelf.profile = object;
            [weakSelf.tableView reloadData];
        }
    }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.allowLoadData = YES;
    [self reloadTableData];
    self.allowLoadMore = YES;
    
    if (self.showCurrentUserProfile) {
        
        NSMutableArray *lArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        if (lArray.count > 2) {
            [lArray removeObjectAtIndex:1];
            self.navigationController.viewControllers = lArray;
        }
        
        self.profile = [DBProfile main];
        
        self.tabBarController.tabBar.hidden = NO;
        [self.navigationItem setHidesBackButton:YES animated:NO];        
        UIBarButtonItem *optionsBtn = [[UIBarButtonItem alloc] initWithTitle:@"Options"
                                                                   style:(UIBarButtonItemStylePlain)
                                                                  target:self
                                                                  action:@selector(showOptions)];
        self.navigationItem.leftBarButtonItem = optionsBtn;
    } else {
        
        __weak typeof(self) weakSelf = self;
        [Network profileForUserID:weakSelf.userID WithCompletion:^(id object, NSError *error) {
            if (!error) {
                
                weakSelf.profile = object;
                [weakSelf.tableView reloadData];
                
            }
        }];
        
        [self.navigationController.tabBarController.tabBar setHidden:YES];
        [self.navigationItem setTitle:@"Profile"];
        
    }
    [super viewWillAppear:animated];
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
}

- (void)loadDataMore:(BOOL)more {
    
    __weak typeof(self)weakSelf = self;
    
    void (^getReviews)(NSDictionary *, NSError *) = ^(NSDictionary *array, NSError *error) {
        if (error == nil){
            
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
                weakSelf.accountReviews = [lArray mutableCopy];
                [weakSelf.tableView reloadData];
            }
            weakSelf.allowLoadMore = [weakSelf.accountReviews count] < ((Page *)[array objectForKey:@"page"]).total_entries;
        }
        [weakSelf.refreshControl endRefreshing];
        
        weakSelf.isLoadingData = NO;
        weakSelf.isLoadingMore = NO;
        [weakSelf showLoadMoreProgress:NO];
    };
    
    if (self.showCurrentUserProfile) {
        [Network accountReviewsLoadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
                weakSelf.page = [array objectForKey:@"page"];
                getReviews(array, error);
        }];
    } else {
        [Network userReviewsForUserID:weakSelf.userID loadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
               weakSelf.page = [array objectForKey:@"page"];
               getReviews(array, error);
        }];
    }
    
}



#pragma mark - Actions

- (void) showOptions {
    [self performSegueWithIdentifier:SBSI_GO_TO_OPTIONS sender:self];
}
#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;                                              //number of section in table
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return _accountReviews.count;
}

-(NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    else
        return [NSString stringWithFormat:@"MY VIDEOS (%i)", (integer_t)_page.total_entries];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [ProfileCellTableViewCell heightForInfoUser:self.profile.description_ inTable:self.tableView];
    } else {
        return (int)(self.view.bounds.size.width * koeficientForCellHeight);
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    }else {
        
        ReviewViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
        Review *review = [self.accountReviews objectAtIndex:indexPath.row];
        videoVC.reiew = review;
        
        [self.navigationController pushViewController:videoVC animated:YES];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SBSI_GO_TO_OPTIONS]) {
        OptionsTableController *filterVC = segue.destinationViewController;
    }
}

@end
