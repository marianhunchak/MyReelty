//
//  PremiumReview.m
//  MyReelty
//
//  Created by Admin on 8/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PremiumReview.h"
#import "NSDictionary+Accessors.h"

@implementation PremiumReview

+ (instancetype)premiumReviewWithDict:(NSDictionary *)dict {
    
    PremiumReview *lReview = [PremiumReview new];
    
    lReview.created_at = [dict stringForKey:@"created_at"];
    lReview.id_ = [dict unsignedIntegerForKey:@"id"];
    lReview.imageURL = [NSURL URLWithString:[dict stringForKey:@"image_url"]];
    lReview.review_id = [dict unsignedIntegerForKey:@"review_id"];
    lReview.review = [Review reviewWithDict:[dict dictionaryForKey:@"review"]];
    
    return lReview;
}

@end
