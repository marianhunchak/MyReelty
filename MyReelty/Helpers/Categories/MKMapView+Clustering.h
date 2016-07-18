//
//  MKMapView+Clustering.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Clustering)

@property (nonatomic, assign) BOOL useCluster;
@property (nonatomic, assign) CGSize cellSize;

- (void)reloadPins:(NSArray *) pins;
- (NSArray *)getTestPins:(NSInteger) count;

@end
