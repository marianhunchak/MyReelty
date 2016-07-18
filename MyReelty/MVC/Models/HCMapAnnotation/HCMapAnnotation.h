//
//  HCMapAnnotation.h
//  MapTest
//
//  Created by Admin on 13.01.16.
//  Copyright © 2016 Marian Hunchak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Review.h"

@interface HCMapAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, nullable) NSString *reviewID;

@end
