//
//  SearchTileCell.m
//  MyReelty
//
//  Created by Admin on 8/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SearchTileCell.h"

@implementation SearchTileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    
    self.backgroundImageView.image = nil;
}

@end
