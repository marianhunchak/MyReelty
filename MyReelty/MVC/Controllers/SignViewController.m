//
//  SignViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 29/02/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SignViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "ErrorHandler.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SignViewController ()
@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    if (self.navigationController.tabBarItem.tag == 3) {
        self.navigationItem.title = @"Bookmarks";
    } else {
        self.navigationItem.title = @"My Profile";
    }
    self.emailButton.layer.borderWidth = 0.8;
    self.emailButton.layer.borderColor = navigationBarColor.CGColor;
    self.emailButton.layer.cornerRadius = 18.f;
    self.facebookButton.layer.cornerRadius = 18.f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY]) {
        if (self.navigationController.tabBarItem.tag == 3) {
            [self.navigationController pushViewController:self.bookmarksViewController animated:NO];
        } else if (self.navigationController.tabBarItem.tag == 4) {
            self.profileViewController.showCurrentUserProfile = YES;
            [self.navigationController pushViewController:self.profileViewController animated:NO];
        }
    }
    
    [self.navigationItem setHidesBackButton:YES];
    UITapGestureRecognizer *gestutre = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestutre];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)textFieldDidChange:(UITextField *)textField {
    
}

- (BookmarksViewController *)bookmarksViewController {
    if (!_bookmarksViewController) {
        _bookmarksViewController = VIEW_CONTROLLER(@"BookmarksViewController");
    }
    return _bookmarksViewController;
}
- (ProfileViewController *)profileViewController {
    if(!_profileViewController) {
        _profileViewController = VIEW_CONTROLLER(@"ProfileViewController");
    }
    return _profileViewController;
}

- (void)handleGesture:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(action);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)signInWithProfile:(DBProfile *)pProfile andActivityView:(SAMHUDView *) hd {
    
    __weak typeof(self)wealSelf = self;
    
    [Network signIn:pProfile WithCompletion:^(NSDictionary *array, NSError *error) {

        if(error) {
            NSString *msg = [ErrorHandler handleSignError:error];
            hd.textLabel.adjustsFontSizeToFitWidth = YES;
            hd.textLabel.minimumScaleFactor = 0.3f;
            [hd failAndDismissWithTitle:msg];
        } else {
            NSDictionary *dict = [array objectForKey:@"authentication_token"];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"content"] forKey:ACCESS_TOKEN_DICT_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [DBProfile main].autorized = [NSNumber numberWithBool:YES];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            if (wealSelf.navigationController.tabBarItem.tag == 3) {
                [wealSelf.navigationController pushViewController:wealSelf.bookmarksViewController animated:YES];
            } else {
                wealSelf.profileViewController.showCurrentUserProfile = YES;
                [wealSelf.navigationController pushViewController:wealSelf.profileViewController animated:YES];
            }
            
                NSString *title = hd.tag == 1 ? @"Registered!" : @"Logged in!";
                [hd completeQuicklyWithTitle:title];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_DID_LOG_IN object:nil];
        }
        
    }];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Actions

- (IBAction)facebookBtnPressed:(UIButton *)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             [Network signInWhithFacebookToken:result.token.tokenString WithCompletion:^(NSDictionary *array, NSError *error) {
                 if (!error) {  
                     NSDictionary *dict = [array objectForKey:@"authentication_token"];
                     [[NSUserDefaults standardUserDefaults] setObject:dict[@"content"] forKey:ACCESS_TOKEN_DICT_KEY];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     if (self.navigationController.tabBarItem.tag == 3) {
                         [self.navigationController pushViewController:self.bookmarksViewController animated:NO];
                     } else {
                         self.profileViewController.showCurrentUserProfile = YES;
                         [self.navigationController pushViewController:self.profileViewController animated:NO];
                     }
                     
                     [DBProfile main].autorized = [NSNumber numberWithBool:YES];
                     [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:USER_DID_LOG_IN object:nil];
                 }
             }];
             
         }
     }];
}

- (IBAction)emailBtnPressed:(UIButton *)sender {

    SignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUpVC animated:YES];
}

- (IBAction)logInBtnPressed:(UIButton *)sender {
    
    SignInViewController *signInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    signInVC.presentedVC = self.title;
    [self.navigationController pushViewController:signInVC animated:YES];
}

#pragma mark - NOtifications



@end
