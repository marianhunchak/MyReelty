//
//  MapViewController.h
//  MyReelty
//
//  Created by Admin on 02.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SearchFilter.h"

@class MKMapView;

@interface MapViewController : UIViewController 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *userLocationString;
@property (nonatomic, assign) BOOL searchResultChanged;

@property (nonatomic, strong) SearchFilter *searchFilter;

- (void)didEnterZip:(NSString*)zip;

@end
