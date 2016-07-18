//
//  LikeTableCell.h
//  MyReelty
//
//  Created by Marian Hunchak on 03/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Review.h"

@interface LikeTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

+ (CGFloat)heightForComment:(NSString *)comment inTable:(UITableView *)tableView;

@end
