//
//  BookmarksViewController.h
//  MyReelty
//
//  Created by Admin on 12.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
@class Bookmark;

@interface BookmarksViewController : BaseTableViewController

@property (strong, nonatomic) Bookmark *bookmarkReview;

@end
