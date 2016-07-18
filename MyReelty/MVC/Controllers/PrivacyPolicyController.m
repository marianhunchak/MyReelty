//
//  PrivacyPolicyController.m
//  MyReelty
//
//  Created by Marian Hunchak on 5/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PrivacyPolicyController.h"

@interface PrivacyPolicyController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UITextView *privacyPolicyTV;
@property (weak, nonatomic) IBOutlet UITextView *TermsOfUseTV;

@end

@implementation PrivacyPolicyController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_infoType == InfoTypeTermsOfService) {
        _TermsOfUseTV.hidden = NO;
        _navigationItem.title = @"Terms of service";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _TermsOfUseTV.contentOffset = CGPointZero;
        });
        
    } else if (_infoType == InfoTypePrivacyPolicy) {
        _privacyPolicyTV.hidden = NO;
        _navigationItem.title = @"Privacy Policy";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _privacyPolicyTV.contentOffset = CGPointZero;
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIBarButtonItem *okeyBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showSignUpConroller)];
    [self.navigationItem setLeftBarButtonItem:okeyBarButton animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) showSignUpConroller {
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }];
}


@end
