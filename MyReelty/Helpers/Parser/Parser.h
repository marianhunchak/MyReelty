//
//  Parser.h
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

+ (NSArray *)parseReviews:(NSDictionary *)dict;
+ (NSArray *)parseBookmarkedReviews:(NSDictionary *)dict;
+ (NSArray *)parsePins:(NSDictionary *)dict;
+ (void)parseProfile:(NSDictionary *)dict;
+ (NSDictionary *)parseReviewsWhithPagination:(NSDictionary *)dict;
+ (NSArray *)parseReviews:(NSDictionary *)dict withKey:(NSString *)key;

@end