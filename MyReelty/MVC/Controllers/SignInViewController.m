//
//  SignInViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 29/02/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SignInViewController.h"
#import "ResetPasswordController.h"
#import "SignUpViewController.h"


@interface SignInViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *LogInBtn;
- (IBAction)forgotPassBtnPressed:(UIButton *)sender;

@property (strong, nonatomic) ResetPasswordController *resetPasswordVC;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Sign In";
    self.emailTF.layer.borderColor = navigationBarColor.CGColor;
    self.passwordTF.layer.borderColor = navigationBarColor.CGColor;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:NO];
    self.tabBarController.tabBar.hidden = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY]) {
        if (self.navigationController.tabBarItem.tag == 3) {
            [self.navigationController pushViewController:self.bookmarksViewController animated:NO];
        } else if (self.navigationController.tabBarItem.tag == 4) {
            self.profileViewController.showCurrentUserProfile = YES;
            [self.navigationController pushViewController:self.profileViewController animated:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (ResetPasswordController *)resetPasswordVC {
    if (!_resetPasswordVC) {
        _resetPasswordVC = VIEW_CONTROLLER(@"ResetPasswordController");
    }
    return _resetPasswordVC;
}

#pragma mark - Private methods

- (void) signIn {
    DBProfile *lProfile = [DBProfile main];
    lProfile.email = _emailTF.text;
    lProfile.password = _passwordTF.text;
    
    SAMHUDView *hd = [[SAMHUDView alloc] initWithTitle:@"Logging in..." loading:YES];
    hd.tag = 2;
    [hd show];

    [self signInWithProfile:lProfile andActivityView:hd];
}

- (BOOL)check {
    BOOL lOK = YES;
    if (_emailTF.text.length == 0) {
        [self showAlertWithMessage:@"Please, fill in email" handler:^(UIAlertAction *action) {
            [_emailTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    if (![_emailTF.text containsString:@"@"]) {
        [self showAlertWithMessage:@"Incorrect email" handler:^(UIAlertAction *action) {
            [_emailTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    if (_passwordTF.text.length == 0) {
        [self showAlertWithMessage:@"Please, fill in password" handler:^(UIAlertAction *action) {
            [_passwordTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    if (_passwordTF.text.length < 6) {
        [self showAlertWithMessage:@"The password should contain at least 6 characters" handler:^(UIAlertAction *action) {
            [_passwordTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    return lOK;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (textField.tag == 1) {
            [_passwordTF becomeFirstResponder];
        } else if (textField.tag == 2) {
            if ([self check]) {
                [self signIn];
            }
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (_emailTF.text.length > 0 && _passwordTF.text.length >= 6 ) {
        self.LogInBtn.backgroundColor = navigationBarColor;
        [self.LogInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        self.LogInBtn.backgroundColor = [UIColor whiteColor];
        [self.LogInBtn setTitleColor:navigationBarColor forState:UIControlStateNormal];
    }
}

#pragma mark - Actions

- (IBAction)logInBtnPressed:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self check]) {
        [self signIn];
    }
    
}

- (IBAction)forgotPassBtnPressed:(UIButton *)sender {
    [self.navigationController pushViewController:self.resetPasswordVC animated:YES];
}

- (IBAction)signUpBtnPressed:(UIButton *)sender {
    
    SignUpViewController *signUpVC = VIEW_CONTROLLER(@"SignUpViewController");
    [self.navigationController pushViewController:signUpVC animated:YES];
}

@end
