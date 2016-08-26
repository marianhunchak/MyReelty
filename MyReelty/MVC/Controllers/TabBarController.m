//
//  TabBarController.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "TabBarController.h"

NSUInteger prevSelectedTag;

@interface TabBarController () <UITabBarDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSString *prevViewController;
@property (nonatomic, assign) NSInteger previousTag;

@end

@implementation TabBarController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
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
