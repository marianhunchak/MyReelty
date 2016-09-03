//
//  ReviewViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 03/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ReviewViewController.h"
#import "LikeTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Network+Processing.h"
#import "CustomFooterView.h"
#import "UIImageView+AFNetworking.h"
#import "SAMHUDView.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "KrVideoPlayerController.h"
#import "AddCommentViewController.h"
#import "NSDictionary+Accessors.h"
#import "NSString+ValidateValue.h"
#import "FlaggingVideo.h"
#import "NSDate+String.h"
#import "NSDate+TimeAgo.h"

static NSString *CellIdentifier = @"likeCell";
static NSString *footerIdentifier = @"customFooter";

@interface ReviewViewController () <AVPlayerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, VideoPlayerDelegate, UIScrollViewDelegate, CommentViewControllerDelegate> {
    CGFloat footerHeight;
    NSInteger likesCount;
    NSInteger commentsCount;
    NSMutableArray *contentOffsetsArray;
}

@property (nonatomic, strong) KrVideoPlayerController  *videoController;
@property (weak, nonatomic) IBOutlet UIView *tabBarView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *tabLikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *tabInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *tabCommentBtn;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) AddCommentViewController *addCommentViewController;
@property (strong, nonatomic) CustomFooterView *footer;
@property (strong,nonatomic) NSMutableArray *commentsList;
@property (strong,nonatomic) NSMutableArray *likesList;
@property (strong, nonatomic) UIView *activityIndicator;
@property (assign, nonatomic) BOOL isLoadingData;
@property (assign, nonatomic) BOOL allowLoadMoreLikes;
@property (assign, nonatomic) BOOL allowLoadMoreComments;
@property (assign, nonatomic) BOOL isLoadingMoreLikes;
@property (assign, nonatomic) BOOL isLoadingMoreComments;

@property (strong, nonatomic) UIBarButtonItem *flagVideoButton;

@property (strong, nonatomic) AVPlayerViewController *playerVC;

- (IBAction)tabLikeBtnPressed:(UIButton *)sender;
- (IBAction)tabInfoBtnPressed:(UIButton *)sender;
- (IBAction)tabCommentBtnPressed:(UIButton *)sender;

@end

@implementation ReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.hidesBarsOnSwipe = NO;
    contentOffsetsArray = [NSMutableArray arrayWithArray:@[[NSValue valueWithCGPoint:CGPointZero],
                                                           [NSValue valueWithCGPoint:CGPointZero],
                                                           [NSValue valueWithCGPoint:CGPointZero]]];
    
    UIBarButtonItem *likeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"likeButton"] style:UIBarButtonItemStylePlain target:self action:@selector(likeBtnPressed:)];
    if (self.reiew.liked) {
        [likeBtn setImage:[UIImage imageNamed:@"likeButton(Active)"]];
    }
    UIBarButtonItem *bookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmarkButton"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(bookmarkBtnPressed:)];
    if (self.reiew.bookmarked) {
        [bookmarkBtn setImage:[UIImage imageNamed:@"bookmarkButton(Active)"]];
    }
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shareButton"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(shareBtnPressed:)];
    
    
    NSString *imageName = self.reiew.complained ? @"flag(Active)" : @"flag";
    
    _flagVideoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(flagVideoBtnPressed:)];
    
    
    self.navigationItem.rightBarButtonItems = @[_flagVideoButton, shareBtn, bookmarkBtn, likeBtn];
    
    self.likesList = [NSMutableArray array];
    self.commentsList = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LikeTableCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self.tabInfoBtn setSelected:YES];

    _footer = [CustomFooterView newView];
    footerHeight = _footer.frame.size.height;
    _footer.review = self.reiew;
    [self playVideo];

    
    [self getLikesList:NO];
    [self getCommentsList:NO];
    
    _allowLoadMoreLikes = YES;
    _allowLoadMoreComments = YES;
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanledFlaginVideo:) name:USER_DID_FLAG_VIDEO object:nil];
    
    [Network getReviewForId:_reiew.id_ WithCompletion:^(id object, NSError *error) {
        if (object) {
            self.reiew = object;
            _footer.review = object;
            [self.tableView reloadData];
        }
    }];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.videoController.delegate = self;

    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoController.delegate = nil;
    [self.videoController pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setReiew:(Review *)reiew {
    _reiew = reiew;
}

- (ProfileViewController *)profileViewController {
    if(!_profileViewController) {
        _profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    }
    return _profileViewController;
}

- (AddCommentViewController *)addCommentViewController {
    if (!_addCommentViewController) {
        _addCommentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCommentViewController"];
        _addCommentViewController.delegate = self;
    }
    return _addCommentViewController;
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

#pragma mark - Actions 

- (void) likeBtnPressed:(UIBarButtonItem *) sender {
    
    void (^sendNotification)() = ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:LIKE_PRESSED_ON_REVIEW_CONTROLLER object:self.reiew];
    };
    if (self.reiew.liked) {
        [Network deleteLikeForReviewID:self.reiew.id_ WithCompletion:^(NSDictionary *array, NSError *error) {
            if (error) {
                
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            
            else if (!error) {
                self.reiew.liked = NO;
                [sender setImage:[UIImage imageNamed:@"likeButton"]];

                [self deleteObjectWhithID:[array objectForKey:@"id"] inArray:self.likesList];
                [self setTitleWhithCount:--likesCount ForTabBarButton:self.tabLikeBtn];

                sendNotification();
            }
        }];
    } else {
        [Network createLikeForReviewID:self.reiew.id_ WithCompletion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            
            else if (!error) {
                
                self.reiew.liked = YES;
                
                [sender setImage:[UIImage imageNamed:@"likeButton(Active)"]];
 
                NSIndexPath *indx = [NSIndexPath indexPathForRow:0 inSection:0];
                
                [self.likesList insertObject:array atIndex:0];
                
                [self setTitleWhithCount:++likesCount ForTabBarButton:self.tabLikeBtn];
                
                if (self.tabLikeBtn.selected) {
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }

                sendNotification();
            }
        }];
    }

}

- (void) bookmarkBtnPressed:(UIBarButtonItem *) sender {
 
    void (^sendNotification)() = ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKMARK_PRESSED_ON_REVIEW_CONTROLLER object:self.reiew];
    };
    if (self.reiew.bookmarked) {
        [Network deleteBookmarkForReviewID:self.reiew.id_ WithCompletion:^(id object, NSError *error) {
            
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                self.reiew.bookmarked = NO;
                [sender setImage:[UIImage imageNamed:@"bookmarkButton"]];
                sendNotification();
            }
        }];
    } else {
        [Network createBookmarkForReviewID:self.reiew.id_ WithCompletion:^(id object, NSError *error) {
            if (error) {
                NSString *msg = [ErrorHandler handleError:error];
                if (msg) {
                    [self showAlertWithMessage:msg handler:nil];
                }
            }
            else if (!error) {
                self.reiew.bookmarked = YES;
                [sender setImage:[UIImage imageNamed:@"bookmarkButton(Active)"]];
                sendNotification();
            }
        }];
    }
    
}

- (void) shareBtnPressed:(UIBarButtonItem *) sender {
    
    if ([self isInternetConnection]) {
        NSString *shareText = @"This is my text I want to share.";
        NSURL *shareURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://myreelty.com/#/review/%@", _reiew.id_]];
        NSArray *itemsToShare = @[shareText, shareURL];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        [self showAlertWithMessage:@"No Internet connection!" handler:nil];
    }
    
}

- (void) flagVideoBtnPressed:(UIBarButtonItem *) sender {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY]) {
        
        [ErrorHandler showAlertWithTitle:@"Warning" message:@"Please register or login"];
        
    } else  if (_reiew.complained) {
        
        [ErrorHandler showAlertWithTitle:@"Warning" message:@"You have already reported this video"];
        
    } else {
        
        [[FlaggingVideo sharedInstance] flagVideoWithReviewID:[_reiew.id_ integerValue]];
        
    }
}

- (void) handleTapGesture:(UITapGestureRecognizer *) sender {
    
    [self.videoController pause];
    if (self.tabCommentBtn.selected) {
        self.addCommentViewController.revieID = self.reiew.id_;
        [self.navigationController pushViewController:self.addCommentViewController animated:YES];
        return;
    }
}

-(void) showPopViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)playVideo{
    NSURL *url = [NSURL URLWithString:[NSString  stringWithFormat:@"%@",  [[_reiew.files firstObject] objectForKey:@"link"]]];
    [self addVideoPlayerWithURL:url];
}

- (void)addVideoPlayerWithURL:(NSURL *)url{
    if (!self.videoController) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:CGRectMake(0.f, 0.f, width, width*(9.0/16.0))];
        self.videoController.delegate = self;
        [self.videoController pause];
        
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController setWillBackOrientationPortrait:^{
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
        }];

        [self.view addSubview:self.videoController.view];
    }
    self.videoController.contentURL = url;
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) getLikesList:(BOOL) more {
    __weak typeof(self) weakSelf = self;
    [Network likesListForReviewID:weakSelf.reiew.id_ loadMore:more WithCompletion:^(NSDictionary *array, NSError *error) {
        
        if (error == nil ) {
            
            NSArray *lArray = [array objectForKey:@"likes"];
            
            if(weakSelf.isLoadingMoreLikes) {
                NSUInteger startIndex = [weakSelf.likesList count];
                [weakSelf.likesList addObjectsFromArray:lArray];
                
                NSMutableArray *newRowsPaths = [NSMutableArray new];
                for(NSUInteger i = startIndex; i < [weakSelf.likesList count]; i++) {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [newRowsPaths addObject:newPath];
                }
                if (weakSelf.tabLikeBtn.selected) {
                    
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
                    
                }
                
            } else {
                
                NSDictionary *lDictionary = [array objectForKey:@"pagination"];
                
                likesCount = [lDictionary integerForKey:@"total_entries"];
                
                [weakSelf setTitleWhithCount:likesCount ForTabBarButton:weakSelf.tabLikeBtn];
                
                weakSelf.likesList = [lArray mutableCopy];
                [weakSelf.tableView reloadData];
            }
            
            weakSelf.allowLoadMoreLikes = [weakSelf.likesList count] < likesCount;
        }
        
        weakSelf.isLoadingData = NO;
        weakSelf.isLoadingMoreLikes = NO;
        [weakSelf showLoadMoreProgress:NO];
    }];
    
}

- (void) getCommentsList:(BOOL) loadMore {
    
    __weak typeof(self) weakSelf = self;
    [Network commentsListForReviewID:weakSelf.reiew.id_ loadMore:loadMore WithCompletion:^(NSDictionary *array, NSError *error) {
        
        if (error == nil ) {
            
            NSArray *lArray = [array objectForKey:@"comments"];
            
            if(weakSelf.isLoadingMoreComments) {
                NSUInteger startIndex = [weakSelf.commentsList count];
                [weakSelf.commentsList addObjectsFromArray:lArray];
                
                NSMutableArray *newRowsPaths = [NSMutableArray new];
                for(NSUInteger i = startIndex; i < [weakSelf.commentsList count]; i++) {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [newRowsPaths addObject:newPath];
                }

                if (weakSelf.tabCommentBtn.selected) {
                    
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:newRowsPaths withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
                    
                }
               
                
            } else {
                
                NSDictionary *lDictionary = [array objectForKey:@"pagination"];
                
                commentsCount = [lDictionary integerForKey:@"total_entries"];
                
                [weakSelf setTitleWhithCount:commentsCount ForTabBarButton:weakSelf.tabCommentBtn];
                
                weakSelf.commentsList = [lArray mutableCopy];
                [weakSelf.tableView reloadData];
            }
            
            weakSelf.allowLoadMoreComments = [weakSelf.commentsList count] < commentsCount;
        }

        weakSelf.isLoadingData = NO;
        weakSelf.isLoadingMoreComments = NO;
        [weakSelf showLoadMoreProgress:NO];
        
    }];
    
}

- (void) showLoadMoreProgress:(BOOL) show {
    
    self.tableView.tableFooterView = show ? self.activityIndicator : nil;
}

- (void)loadDataMore:(BOOL)more {
    
    if (self.tabCommentBtn.isSelected && _allowLoadMoreComments) {
        
        _isLoadingMoreComments = YES;
        _isLoadingData = YES;
        
        [self showLoadMoreProgress:YES];
        [self getCommentsList:more];
        
    } else if (self.tabLikeBtn.isSelected && _allowLoadMoreLikes){
        
        _isLoadingMoreLikes = YES;
        _isLoadingData = YES;
        
        [self showLoadMoreProgress:YES];
        [self getLikesList:more];
    }

    
}

- (void) setTitleWhithCount:(NSInteger) count ForTabBarButton:(UIButton *) pButton {
    
    NSString *lTitle = nil;
    
    if (count!=0) {
        lTitle = [NSString stringWithFormat:@" %lu",count];
    }
    
    [pButton setTitle:lTitle  forState:UIControlStateNormal & UIControlStateSelected];
}

- (void) deleteObjectWhithID:(NSString *) pID inArray:(NSMutableArray *) pArray  {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",pID];
    
    NSArray *lArray = [pArray filteredArrayUsingPredicate:predicate];
    
    if ([lArray count] != 1) {
        return;
    }
    
    NSInteger row = [pArray indexOfObject:[lArray firstObject]];
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:row inSection:0];
    
    [pArray removeObjectAtIndex:row];
    
    if (self.tabLikeBtn.selected) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (CGPoint) getValidYContentOffset {
    
    CGFloat lYOffset = _tableView.contentOffset.y;
    CGFloat lContentSize = _tableView.contentSize.height;
    CGFloat lTableHeight = _tableView.frame.size.height;
    
    if (lYOffset <= 0 ) {
        lYOffset = 0;
    } else if (lYOffset + lTableHeight > lContentSize) {
        if(lContentSize <= lTableHeight) {
            lYOffset = 0;
        } else {
            lYOffset = lContentSize - lTableHeight;
        }
    }
    return CGPointMake(0.0, lYOffset);
}

- (NSInteger) selectedButtonIndex {
    
    if (_tabInfoBtn.selected) {
        return  _tabInfoBtn.tag;
    }
    if (_tabLikeBtn.selected) {
        return  _tabLikeBtn.tag;
    }
    if (_tabCommentBtn.selected) {
        return  _tabCommentBtn.tag;
    }
    return 0;
}

-(BOOL) isInternetConnection
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.tabInfoBtn.selected) {
        return 1;
    }
    if (self.tabLikeBtn.selected) {

        return self.likesList.count;
    }
    
    return self.commentsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LikeTableCell *cell = (LikeTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *url1;
    if (self.tabInfoBtn.selected) {
        cell.commentLabel.hidden = YES;
        cell.profileNameLabel.text = [self.reiew.user objectForKey:@"name"];
        url1 = [self.reiew.user stringForKey:@"avatar_url"];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:url1] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell.createdAtLabel.text = [self.reiew.visits_count stringByAppendingString: [self.reiew.visits_count isEqualToString:@"1"] ? @"  view" : @" views"];
        if (!_tableView.tableFooterView) {
            CGRect newFrame = _footer.frame;
            newFrame.size.height = 450.f + [CustomFooterView heightForDescription:self.reiew.description_ inTable:self.tableView];
            _footer.frame = newFrame;
            [_tableView setTableFooterView:_footer];
        }

  
    } else if (self.tabLikeBtn.selected) {
        cell.commentLabel.hidden = YES;
        NSDictionary *lDictionary = [self.likesList objectAtIndex:indexPath.row];
        cell.profileNameLabel.text = [[lDictionary objectForKey:@"user"] objectForKey:@"name"];
        cell.createdAtLabel.text = [[NSDate getDateFromString:[lDictionary stringForKey:@"created_at"]] timeAgo];
        url1 = [[lDictionary objectForKey:@"user"] stringForKey:@"avatar_url"];

    } else if (self.tabCommentBtn.selected) {

        cell.commentLabel.hidden = NO;
        NSDictionary *lDictionary = [self.commentsList objectAtIndex:indexPath.row];
        cell.commentLabel.text = [lDictionary objectForKey:@"content"];
        cell.profileNameLabel.text = [[lDictionary objectForKey:@"user"] objectForKey:@"name"];
        cell.createdAtLabel.text = [[NSDate getDateFromString:[lDictionary stringForKey:@"created_at"]] timeAgo];
        url1 = [[lDictionary objectForKey:@"user"] stringForKey:@"avatar_url"];
    }

    cell.profileImageView.layer.cornerRadius = 5.f;
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.clipsToBounds = YES;
    if (![NSString validateValue:url1]) {
        cell.profileImageView.image = [UIImage imageNamed:@"avatar(Empty)"];
    }
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:url1] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *comment = nil;
    if (self.tabCommentBtn.selected) {
        NSDictionary *lDictionary = [self.commentsList objectAtIndex:indexPath.row];
        comment = [lDictionary objectForKey:@"content"];
    }
    return ceil([LikeTableCell heightForComment:comment inTable:tableView]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.f)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.f)];
    [label setFont:[UIFont systemFontOfSize:15]];
    label.textColor = navigationBarColor;
    label.textAlignment = NSTextAlignmentCenter;
    NSString *string = @"ADD COMMENT";
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [view addGestureRecognizer:tapGesture];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.tabInfoBtn.selected || self.tabLikeBtn.selected) {
        return 0;
    }
    return 40.f;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *lDictionary;
    if (_tabLikeBtn.selected) {
        lDictionary = [[self.likesList objectAtIndex:indexPath.row] objectForKey:@"user"];
    } else if (_tabCommentBtn.selected) {
        lDictionary = [[self.commentsList objectAtIndex:indexPath.row] objectForKey:@"user"];
    } else {
        lDictionary = self.reiew.user;
    }

    self.profileViewController.userID = [lDictionary objectForKey:@"id"];
    self.profileViewController.showCurrentUserProfile = NO;
    [self.navigationController pushViewController:self.profileViewController animated:YES];
    
}

#pragma mark - TabBarButton handler

- (IBAction)tabInfoBtnPressed:(UIButton *)sender {

    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    contentOffsetsArray[[self selectedButtonIndex]] = [NSValue valueWithCGPoint:[self getValidYContentOffset]];
    [sender setSelected:YES];
    [sender setUserInteractionEnabled:NO];
    [self.tabLikeBtn setSelected:NO];
    [self.tabCommentBtn setSelected:NO];
    [self.tabLikeBtn setUserInteractionEnabled:YES];
    [self.tabCommentBtn setUserInteractionEnabled:YES];
    [self.tableView reloadData];
    if (!_tableView.tableFooterView) {
        CGRect newFrame = _footer.frame;
        newFrame.size.height = 450.f + [CustomFooterView heightForDescription:self.reiew.description_ inTable:self.tableView];
        _footer.frame = newFrame;
        [_tableView setTableFooterView:_footer];
    }
    [self.tableView setContentOffset:[contentOffsetsArray[sender.tag] CGPointValue]];
}

- (IBAction)tabLikeBtnPressed:(UIButton *)sender {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    contentOffsetsArray[[self selectedButtonIndex]] = [NSValue valueWithCGPoint:[self getValidYContentOffset]];
    [sender setSelected:YES];
    [sender setUserInteractionEnabled:NO];
    [self.tabCommentBtn setSelected:NO];
    [self.tabInfoBtn setSelected:NO];
    [self.tabCommentBtn setUserInteractionEnabled:YES];
    [self.tabInfoBtn setUserInteractionEnabled:YES];
    self.tableView.tableFooterView = nil;
    [self.tableView reloadData];
    [self.tableView setContentOffset:[contentOffsetsArray[sender.tag] CGPointValue]];
}

- (IBAction)tabCommentBtnPressed:(UIButton *)sender {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    contentOffsetsArray[[self selectedButtonIndex]] = [NSValue valueWithCGPoint:[self getValidYContentOffset]];
    [sender setSelected:YES];
    [sender setUserInteractionEnabled:NO];
    [self.tabLikeBtn setSelected:NO];
    [self.tabInfoBtn setSelected:NO];
    [self.tabLikeBtn setUserInteractionEnabled:YES];
    [self.tabInfoBtn setUserInteractionEnabled:YES];
    self.tableView.tableFooterView = nil;
    [self.tableView reloadData];
    [self.tableView setContentOffset:[contentOffsetsArray[sender.tag] CGPointValue]];
    
}

- (void)videoPlayerChangedVideoOriintation:(UIDeviceOrientation)Orientation {
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        [[self navigationController] setNavigationBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        [[self navigationController] setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

#pragma - mark CommentViewControllerDelegate

- (void) commentViewControllerPostBtnPressed:(NSDictionary *) comment {
    
    NSIndexPath *indx = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.commentsList insertObject:comment atIndex:0];
    
    [self setTitleWhithCount:++commentsCount ForTabBarButton:self.tabCommentBtn];
    
    if (self.tabCommentBtn.selected) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView setContentOffset:CGPointZero];
    }
    
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_isLoadingData) {
        return;
    }

    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;

    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;

    if(distanceFromBottom <= 2 * height) {

        [self loadDataMore:YES];

       }
    }

#pragma mark - Notifications 

- (void)hanledFlaginVideo:(NSNotification *) notification {
    
    _flagVideoButton.image = [UIImage imageNamed:@"flag(Active)"];
    _reiew.complained = YES;
}

@end
