//
//  ProfileViewController.h
//  MyReelty
//
//  Created by Admin on 15.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCellTableViewCell.h"
#import "BaseTableViewController.h"

@interface ProfileViewController : BaseTableViewController  <UITableViewDataSource, UITextFieldDelegate> {

}

@property (nonatomic, assign) BOOL showCurrentUserProfile;
@property (nonatomic, strong) NSString *userID;
@end
