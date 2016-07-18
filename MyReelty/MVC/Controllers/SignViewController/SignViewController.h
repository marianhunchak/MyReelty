//
//  SignViewController.h
//  MyReelty
//
//  Created by Marian Hunchak on 27/02/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

- (IBAction)facebookBtnPressed:(UIButton *)sender;
- (IBAction)emailBtnPressed:(UIButton *)sender;

@end
