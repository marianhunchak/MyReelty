//
//  Pin.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Pin : NSObject

@property (nonatomic, copy) NSString *id_;
@property (nonatomic, assign) CLLocationCoordinate2D location;

+ (instancetype)pinWithDict:(NSDictionary *)dict;

@end
