//
//  PremiumReview.h
//  MyReelty
//
//  Created by Admin on 8/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Review.h"

@interface PremiumReview : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, assign) NSUInteger id_;
@property (nonatomic, assign) NSUInteger review_id;
@property (nonatomic, strong) Review *review;

+ (instancetype)premiumReviewWithDict:(NSDictionary *)dict;

@end
