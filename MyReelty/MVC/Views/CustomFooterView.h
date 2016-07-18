//
//  CustomFooterView.h
//  MyReelty
//
//  Created by Marian Hunchak on 04/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Review.h"
#import <MapKit/MapKit.h>

@interface CustomFooterView : UIView

@property (strong, nonatomic) Review *review;

+ (instancetype)newView;
+ (CGFloat)heightForDescription:(NSString *)description inTable:(UITableView *)tableView;

@end
