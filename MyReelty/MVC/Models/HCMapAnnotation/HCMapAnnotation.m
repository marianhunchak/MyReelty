//
//  HCMapAnnotation.m
//  MapTest
//
//  Created by Admin on 13.01.16.
//  Copyright © 2016 Marian Hunchak. All rights reserved.
//

#import "HCMapAnnotation.h"

CGFloat e = 0.1;

@implementation HCMapAnnotation

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithMKCoordinate:_coordinate] forKey:@"coordinate"];
    [aCoder encodeObject:_reviewID forKey:@"reviewID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.coordinate = [[aDecoder decodeObjectForKey:@"coordinate"] MKCoordinateValue];
        self.reviewID = [aDecoder decodeObjectForKey:@"reviewID"];
    }
    
    return self;
}

@end