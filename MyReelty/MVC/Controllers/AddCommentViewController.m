//
//  AddCommentViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 3/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AddCommentViewController.h"
#import "Network+Processing.h"
#import "SAMHUDView.h"
#import "ErrorHandler.h"

@interface AddCommentViewController() <UITextViewDelegate> {
    
    __weak IBOutlet UITextView *textView;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomSpaceConstraint;

@end

@implementation AddCommentViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add comment";
    textView.textContainerInset = UIEdgeInsetsMake(20.f, 20.f, 10.f, 20.f);
    [textView becomeFirstResponder];
    
    UIBarButtonItem *postBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector( postBarBtnPressed:)];
    self.navigationItem.rightBarButtonItem = postBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing) name:UITextViewTextDidChangeNotification object:nil];
    [self registerForKeyboardNotifications];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    textView.text = @"";
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unRegisterFromKeyboardNotifications];
}

#pragma mark - Private mehods

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)unRegisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Actions 

- (void) postBarBtnPressed:(UIBarButtonItem *) sender {
    
    __weak typeof(self) weakSelf = self;
    [Network createCommnetForReviewID:weakSelf.revieID AndContent:textView.text WithCompletion:^(NSDictionary *array, NSError *error) {
        
        if (error) {
            NSString *msg = [ErrorHandler handleCommentError:error];
            if (msg) {
                [self showAlertWithMessage:msg handler:nil];
            }
        } else if (!error) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewControllerPostBtnPressed:)]) {
                [self.delegate commentViewControllerPostBtnPressed:array];
            }
        }
    }];
    
}

#pragma mark - UITextViewDelegate

- (void) textViewDidBeginEditing {
    
//    textView.text = [textView.text stringByReplacingOccurrencesOfString:@"Type comments…" withString:@""];
//    textView.font = [UIFont systemFontOfSize:12.f];
//    [textView setTextColor:[UIColor blackColor]];
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(id)sender {
    
    NSDictionary *info = [sender userInfo];
    CGRect lKeyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.3 animations:^{
        _textViewBottomSpaceConstraint.constant = lKeyboardFrame.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _textViewBottomSpaceConstraint.constant = 8.0;
        [self.view layoutIfNeeded];
    }];
}

@end
