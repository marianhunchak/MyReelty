//
//  CellFabric.m
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CellFabric.h"
#import "ProfileCellTableViewCell.h"
#import "DBProfile.h"

@implementation CellFabric

- (instancetype)initWithTV:(UITableView *)tv reuseID:(NSString *)reuseID
{
    self = [super init];
    if (self) {
        [tv registerNib:[UINib nibWithNibName:reuseID bundle:nil] forCellReuseIdentifier:reuseID];
    }
    return self;
}

- (id)createCell:(UITableView *)tb idexPath:(NSIndexPath *)path reuseID:(NSString *)identifier model:(DBProfile*)profile {
    
    if (path.section == 0) {
        
        ProfileCellTableViewCell *lProfileCell = [tb dequeueReusableCellWithIdentifier:@"ProfileCellTableViewCell"];
        lProfileCell.profile = profile;

        return lProfileCell;
        
    } else {

        static NSString *profileTableIdentifier = @"ProfileTable";
        UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:profileTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: profileTableIdentifier];
        }
        
        return cell;
    }
}

@end
