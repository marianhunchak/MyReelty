//
//  ProfileCellTableViewCell.h
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBProfile;
@interface ProfileCellTableViewCell : UITableViewCell

@property (nonatomic, strong) DBProfile *profile;

+ (CGFloat)heightForInfoUser:(NSString *)infoUserLabel inTable:(UITableView *)tableView;

@end
