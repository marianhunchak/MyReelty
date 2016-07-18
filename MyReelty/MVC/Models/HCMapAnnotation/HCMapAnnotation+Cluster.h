//
//  HCMapAnnotation+Cluster.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "HCMapAnnotation.h"

@interface HCMapAnnotation (Cluster)

@property (nonatomic, assign) BOOL isCluster;
@property (nonatomic, readonly, nullable) NSArray *annotations;

-(MKAnnotationView *) annotationViewForAnnotationInMap:(MKMapView *) mapView;
-(void) addClusterAnnotations:(NSArray *) array;

@end
