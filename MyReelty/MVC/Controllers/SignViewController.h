//
//  SignViewController.h
//  MyReelty
//
//  Created by Marian Hunchak on 29/02/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "BookmarksViewController.h"
#import "DBProfile.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Network.h"
#import "SAMHUDView.h"
#import "NSDictionary+Accessors.h"
#import "ErrorHandler.h"

@interface SignViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) BookmarksViewController *bookmarksViewController;

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler;
- (IBAction)facebookBtnPressed:(UIButton *)sender;
- (IBAction)emailBtnPressed:(UIButton *)sender;
- (IBAction)logInBtnPressed:(UIButton *)sender;
- (void)signInWithProfile:(DBProfile *)pProfile andActivityView:(SAMHUDView *) hd;
- (BOOL) NSStringIsValidEmail:(NSString *)checkString;
@end
