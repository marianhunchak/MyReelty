//
//  Review.m
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Review.h"
#import "NSDictionary+Accessors.h"

@implementation Review

+ (instancetype)reviewWithDict:(NSDictionary *)dict {
    
    Review *lReview = [Review new];
    
    lReview.address = [[dict stringForKey:@"address"] capitalizedString];
    lReview.availability = [dict boolForKey:@"availability"];
    lReview.baths = [dict intForKey:@"baths"];
    lReview.city = [[dict stringForKey:@"city"] capitalizedString];
    lReview.description_ = [dict stringForKey:@"description"];
    lReview.full_address = [[dict stringForKey:@"full_address"] capitalizedString];
    lReview.id_ = [dict stringForKey:@"id"];
    lReview.price = [dict floatForKey:@"price"];
    lReview.property_type = [dict stringForKey:@"property_type"];
    lReview.beds = [dict intForKey:@"beds"];
    lReview.square = [dict floatForKey:@"square"];
    lReview.state = [[dict stringForKey:@"state"] capitalizedString];
    lReview.zipcode = [dict stringForKey:@"zipcode"];
    if ([dict objectForKey:@"location"]) {
        CLLocationCoordinate2D lLocation = CLLocationCoordinate2DMake ([[[dict objectForKey:@"location"] firstObject] doubleValue],
                                                                        [[[dict objectForKey:@"location"] lastObject] doubleValue]);
        lReview.location = lLocation;
    }
    lReview.user = [dict objectForKey:@"user"];
    lReview.bookmarked = [dict boolForKey:@"bookmarked"];
    lReview.liked = [dict boolForKey:@"liked"];
    lReview.visits_count = [dict stringForKey:@"visits_count"];
    if(![[dict objectForKey:@"files"] isKindOfClass:[NSNull class]]) {
        lReview.files = [dict objectForKey:@"files"];
    }
    if(![[dict objectForKey:@"pictures"] isKindOfClass:[NSNull class]]) {
        NSArray *lArray = [[dict objectForKey:@"pictures"] objectForKey:@"sizes"];
        lReview.thumb_url = [[lArray lastObject] objectForKey:@"link"];
    }
    if(![[dict objectForKey:@"thumb_url"] isKindOfClass:[NSNull class]]) {
        lReview.thumb_url = [dict objectForKey:@"thumb_url"];
    }
    return lReview;
}

@end