//
//  TabBarController.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "TabBarController.h"
#import <SKSplashView/SKSplashIcon.h>
NSUInteger prevSelectedTag;

@interface TabBarController () <UITabBarDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSString *prevViewController;
@property (nonatomic, assign) NSInteger previousTag;
@property (strong, nonatomic) SKSplashView *splashView;

@end

@implementation TabBarController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self twitterSplash];
    
    self.delegate = self;
}

- (void) twitterSplash
{
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"main_logo.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = navigationBarColor;
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeBounce];
    _splashView.animationDuration = 3.2; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    DLog(@"Curennt view controller - %ld", [viewController.childViewControllers count]);
        if (_previousTag == viewController.tabBarItem.tag) {
             return NO;
        }
             _previousTag = viewController.tabBarItem.tag;
    
    return YES;
}

@end
