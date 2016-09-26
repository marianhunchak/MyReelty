//
//  ResetPasswordController.m
//  MyReelty
//
//  Created by Marian Hunchak on 5/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ResetPasswordController.h"
#import "Network.h"
#import "SAMHUDView.h"
#import "ErrorHandler.h"

@interface ResetPasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *resetPassButton;
- (IBAction)resetPassBtnPressed:(UIButton *)sender;

@end

@implementation ResetPasswordController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.emailTF.text = @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Reset Password";
    self.resetPassButton.layer.borderWidth = 0.8;
    self.resetPassButton.layer.borderColor = navigationBarColor.CGColor;
    self.resetPassButton.layer.cornerRadius = 18.f;

    UITapGestureRecognizer *gestutre = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestutre];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetPassBtnPressed:(UIButton *)sender {
    
    [self.view endEditing:YES];
    SAMHUDView *hd = [[SAMHUDView alloc] initWithTitle:@"Sending..." loading:YES];
    [hd show];
    
    __weak typeof(self) weakSelf = self;
    
    [Network sendMessageWithEmail:_emailTF.text WithCompletion:^(NSDictionary *array, NSError *error) {
        if (error) {
            
            NSString *title = [ErrorHandler handleResetPassError:error];
            [hd failAndDismissWithTitle:title];
            
        } else {
            [hd completeAndDismissWithTitle:@"Sended!"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)handleGesture:(UITapGestureRecognizer *)gesture {
    
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [self resetPassBtnPressed:_resetPassButton];
        return NO;
    }
    return YES;
}

#pragma mark - Actions

- (void)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
