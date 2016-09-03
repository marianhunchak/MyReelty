//
//  EditProfileController.m
//  MyReelty
//
//  Created by Marian Hunchak on 9/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "EditProfileController.h"
#import "DBProfile.h"

@interface EditProfileController()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@end

@implementation EditProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Edit Profile";
    
    DBProfile *profile = [DBProfile main];
}

@end
