//
//  PremiumVideoCell.m
//  MyReelty
//
//  Created by Admin on 8/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PremiumVideoCell.h"
#import "PremiumReview.h"
#import "ReviewViewController.h"

@interface PremiumVideoCell()

@property (strong, nonatomic) IBOutlet UIImageView *backroundImageView;


@end

@implementation PremiumVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setPremiumReview:(PremiumReview *)premiumReview {
    
    _premiumReview = premiumReview;
    self.backroundImageView.image = nil;
    [self.backroundImageView setImageWithURL:premiumReview.imageURL placeholderImage:nil];
}

- (IBAction)playButtonPressed:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ReviewViewController *videoVC = [storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    videoVC.reiew = _premiumReview.review;
    UIViewController *tabBar = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UINavigationController *nav = ((UITabBarController *)tabBar).viewControllers.firstObject;
    
    [nav pushViewController:videoVC animated:YES];
}

@end
