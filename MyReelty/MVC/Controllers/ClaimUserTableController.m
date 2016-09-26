//
//  ClaimUserTableController.m
//  MyReelty
//
//  Created by Marian Hunchak on 9/9/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ClaimUserTableController.h"
#import "Network.h"
#import "UIAlertDialog.h"
#import "DBProfile.h"

static NSString *placeholderString = @"Enter Your Message...";

@interface ClaimUserTableController() <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextView *messageTV;
@property (weak, nonatomic) IBOutlet UIButton *claimButton;

@end

@implementation ClaimUserTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Claiming Request";
    
    [self setBorderWidth:1.f borderColor:navigationBarColor cornerRadius:5.f toView:_nameTF];
    [self setBorderWidth:1.f borderColor:navigationBarColor cornerRadius:5.f toView:_emailTF];
    [self setBorderWidth:1.f borderColor:navigationBarColor cornerRadius:5.f toView:_phoneTF];
    [self setBorderWidth:1.f borderColor:navigationBarColor cornerRadius:5.f toView:_messageTV];
    [self setBorderWidth:1.f borderColor:navigationBarColor cornerRadius:5.f toView:_claimButton];
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleTapOnView)];
    [self.view addGestureRecognizer:tapOnView];
    
    _messageTV.text = placeholderString;
    _messageTV.textColor = [UIColor lightGrayColor];
    
    DBProfile *profile = [DBProfile main];
    _nameTF.text = profile.name;
    _emailTF.text = profile.email;
    _phoneTF.text = profile.phone;
}


#pragma mark - Actions 

- (IBAction)claimBtnPressed:(UIButton *)sender {
    
    if ([self isEnteredInfoValid] && _selectedUserID) {
        
        __weak typeof(self)weakSelf = self;
        
        [Network claimUserWithName:_nameTF.text
                             phone:_phoneTF.text
                             email:_emailTF.text
                           message:_messageTV.text
                     claimedUserID:_selectedUserID
                    WithCompletion:^(NSDictionary *array, NSError *error) {
                        
                        if (!error) {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                        
        }];
    }
}

- (void)handleTapOnView {
    [self.view endEditing:YES];
}

#pragma mark - Private methods

- (void)setBorderWidth:(CGFloat)width borderColor:(UIColor *)color cornerRadius:(CGFloat)radius toView:(UIView *)view {
    
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
    view.layer.cornerRadius = radius;
}

- (BOOL)isEnteredInfoValid {
    
    NSString *alertTitle = @"Warning";
    NSString *alertMessage = @"";
    
    if ([_nameTF.text isEqualToString:@""] || _nameTF.text.length > 50) {
        alertMessage = @"Name field can`t be empty or longer than 50 characters";
    } else if (![self isValidEmail:_emailTF.text] || _emailTF.text.length == 0) {
        alertMessage = @"Please enter valid email";
    } else if (_phoneTF.text.length > 30 || _phoneTF.text.length == 0) {
        alertMessage = @"Phone field can`t be empty or longer than 30 characters";
    } else if (_messageTV.text.length > 500 || _messageTV.text.length == 0) {
        alertMessage = @"Meesage field can`t be empty or longer than 500 characters";
    }
    
    if ([alertMessage isEqualToString:@""]) {
        return YES;
    } else {
        
        UIAlertDialog *alerDialog = [[UIAlertDialog alloc] initWithStyle:UIAlertDialogStyleAlert title:alertTitle andMessage:alertMessage];
        [alerDialog addButtonWithTitle:@"OK" andHandler:nil];
        [alerDialog showInViewController:self];
        
        return NO;
    }
    
}

- (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (textField.tag == 0) {
            [_emailTF becomeFirstResponder];
        } else if (textField.tag == 1) {
            [_phoneTF becomeFirstResponder];
        } else if (textField.tag == 2)
        {
            [_messageTV becomeFirstResponder];
        }
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:placeholderString]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeholderString;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
