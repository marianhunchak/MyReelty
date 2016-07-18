//
//  ReviewViewController.h
//  MyReelty
//
//  Created by Marian Hunchak on 03/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Review.h"
#import "VideoCell.h"

@interface ReviewViewController : UIViewController

@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) Review *reiew;
@property (strong, nonatomic) VideoCell *cell;

@end
