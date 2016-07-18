//
//  CellFabric.h
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DBProfile;

@interface CellFabric : NSObject

- (instancetype)initWithTV:(UITableView *)tv reuseID:(NSString *)reuseID;
- (id)createCell:(UITableView *)tb idexPath:(NSIndexPath *)path reuseID:(NSString *)identifier model:(DBProfile*)profile;

@end
