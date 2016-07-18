//
//  Pin.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Pin.h"
#import "NSDictionary+Accessors.h"

@implementation Pin

+ (instancetype)pinWithDict:(NSDictionary *)dict {
    
    Pin *lPin = [Pin new];
    lPin.id_ = [dict stringForKey:@"id"];
    if ([dict objectForKey:@"location"]) {
        CLLocationCoordinate2D lLocation = CLLocationCoordinate2DMake ([[[dict objectForKey:@"location"] firstObject] doubleValue],
                                                                       [[[dict objectForKey:@"location"] lastObject] doubleValue]);
        lPin.location = lLocation;
    }

    return lPin;
}

@end
