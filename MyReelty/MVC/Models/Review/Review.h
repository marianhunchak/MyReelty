//
//  Review.h
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Review : NSObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) BOOL availability;
@property (nonatomic, assign) NSUInteger baths;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *full_address;
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *property_type;
@property (nonatomic, assign) NSUInteger beds;
@property (nonatomic, assign) float square;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, copy) NSArray *pictures;
@property (nonatomic, copy) NSArray *files;
@property (nonatomic, copy) NSDictionary *user;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL complained;
@property (nonatomic, copy) NSString *visits_count;
@property (nonatomic, copy) NSString *thumb_url;

+ (instancetype)reviewWithDict:(NSDictionary *)dict;

@end