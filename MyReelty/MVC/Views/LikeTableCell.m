//
//  LikeTableCell.m
//  MyReelty
//
//  Created by Marian Hunchak on 03/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "LikeTableCell.h"

#define BASE_CELL_HEIGHT 45.f

@interface LikeTableCell ()


@end

@implementation LikeTableCell

- (void)awakeFromNib {
    // Initialization code
//    self.profileNameLabel.text = 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    self.profileImageView.image = nil;
    
}

+ (CGFloat)heightForComment:(NSString *)comment inTable:(UITableView *)tableView {
    CGSize commentLabelSize = CGSizeMake(tableView.frame.size.width - 70.f, 99999);
    CGSize size = [comment boundingRectWithSize:commentLabelSize
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.f]}
                                                context:nil].size;
    return BASE_CELL_HEIGHT + size.height;
}

@end
