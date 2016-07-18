//
//  FrontViewController.h
//  MyReelty
//
//  Created by Admin on 01.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "SearchFilter.h"

@interface SearchViewController : BaseTableViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *reviews;
@property (nonatomic, strong) SearchFilter *searchFilter;
@property (nonatomic, assign) BOOL searchResultChanged;

@end
