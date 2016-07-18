//
//  SignViewController.m
//  MyReelty
//
//  Created by Marian Hunchak on 27/02/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SignViewController.h"

@interface SignViewController ()

@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.navigationItem.title = self.navigationController.tabBarItem.title;
    self.emailButton.layer.borderWidth = 0.8;
    self.emailButton.layer.borderColor = navigationBarColor.CGColor;
    self.emailButton.layer.cornerRadius = 18.f;
    self.facebookButton.layer.cornerRadius = 18.f;
    navigationBarColor;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)facebookBtnPressed:(UIButton *)sender {
}

- (IBAction)emailBtnPressed:(UIButton *)sender {
}
@end
