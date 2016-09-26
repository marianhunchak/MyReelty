//
//  SignUpViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 01/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignInViewController.h"
#import "PrivacyPolicyController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTF;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)termsOfUseBtnPressed:(UIButton *)sender;
- (IBAction)PrivacyPolicyBtnPressed:(UIButton *)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
     self.navigationItem.title = @"Sign Up";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void) signUp {
    DBProfile *lProfile = [DBProfile main];
    lProfile.email = _emailTF.text;
    lProfile.password = _passwordTF.text;
    lProfile.name = _userNameTF.text;
    
    SAMHUDView *hd = [[SAMHUDView alloc] initWithTitle:@"Registering..." loading:YES];
    hd.tag = 1;
    hd.textLabel.minimumScaleFactor = 0.5;
    [hd show];
    
    __weak typeof(self) weakSelf = self;
    
    [Network signUp:lProfile WhithCompletion:^(id object, NSError *error) {
        if(error) {
            
            NSString *msg = [ErrorHandler handleSignError:error];
            [hd failAndDismissWithTitle:msg];
            
         } else {
//        NSDictionary *lDict = (NSDictionary *)object[@"account"];
//        [DBProfile main].id_ = [lDict stringForKey:@"id"];
//        [DBProfile main].created_at =[lDict stringForKey:@"created_at"];
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakSelf signInWithProfile:lProfile andActivityView:hd];
        }
    }];

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (textField.tag == 1) {
            [_emailTF becomeFirstResponder];
        } else if (textField.tag == 2) {
            [_passwordTF becomeFirstResponder];
        } else if (textField.tag == 3)      
        {
            [_confirmPassTF becomeFirstResponder];
        } else {
                if ([self check]) {
                    [self signUp];
                }
            }
        return NO;
    }
    return YES;
}

- (BOOL)check {
    BOOL lOK = YES;
    
//    if (_userNameTF.text.length == 0) {
//        [self showAlertWithMessage:@"Please, fill in name field" handler:^(UIAlertAction *action) {
//            [_userNameTF becomeFirstResponder];
//        }];
//        lOK = NO;
//    }
    if (_userNameTF.text.length < 5 || _userNameTF.text.length > 30) {
        [self showAlertWithMessage:@"Name field should be between 5 and 30 characters" handler:^(UIAlertAction *action) {
            [_userNameTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    if (_emailTF.text.length == 0) {
        [self showAlertWithMessage:@"Please, fill in email" handler:^(UIAlertAction *action) {
            [_emailTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    if (![self NSStringIsValidEmail:_emailTF.text]) {
        [self showAlertWithMessage:@"Incorrect email" handler:^(UIAlertAction *action) {
            [_emailTF becomeFirstResponder];
        }];
        lOK = NO;
    } else if (_passwordTF.text.length == 0) {
        [self showAlertWithMessage:@"Please, fill in password" handler:^(UIAlertAction *action) {
            [_passwordTF becomeFirstResponder];
        }];
        lOK = NO;
    } else if (_passwordTF.text.length < 6) {
        [self showAlertWithMessage:@"The password should contain at least 6 characters" handler:^(UIAlertAction *action) {
            [_passwordTF becomeFirstResponder];
        }];
        lOK = NO;
    } else if (![_confirmPassTF.text isEqualToString:_passwordTF.text]) {
        [self showAlertWithMessage:@"Passwords don't match" handler:^(UIAlertAction *action) {
            [_confirmPassTF becomeFirstResponder];
        }];
        lOK = NO;
    }
    return lOK;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (_userNameTF.text.length > 0 && _emailTF.text.length > 0 && _passwordTF.text.length >= 6 && [_confirmPassTF.text isEqualToString:_passwordTF.text]) {
        self.joinButton.backgroundColor = navigationBarColor;
        [self.joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        self.joinButton.backgroundColor = [UIColor whiteColor];
        [self.joinButton setTitleColor:navigationBarColor forState:UIControlStateNormal];
    }
}

#pragma mark - Actions

- (void)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)logInBtnPressed:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self check]) {
        [self signUp];
    }
    
}

- (IBAction)termsOfUseBtnPressed:(UIButton *)sender {
    PrivacyPolicyController *vc = VIEW_CONTROLLER(@"PrivacyPolicyController");
    vc.infoType = InfoTypeTermsOfService;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)PrivacyPolicyBtnPressed:(UIButton *)sender {
    PrivacyPolicyController *vc = VIEW_CONTROLLER(@"PrivacyPolicyController");
    vc.infoType = InfoTypePrivacyPolicy;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}
@end
