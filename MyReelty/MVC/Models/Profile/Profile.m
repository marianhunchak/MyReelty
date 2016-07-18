//
//  Profile.m
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Profile.h"
#import "NSDictionary+Accessors.h"

@implementation Profile

+ (instancetype)profileWithDict:(NSDictionary *)dict {
    Profile *lProfile = [Profile new];
    NSDictionary *lAccountDict = [dict dictionaryForKey:@"user"];
    lProfile.phone = [[lAccountDict stringForKey:@"phone"] isEqualToString:@"<null>"] ? @"" : [lAccountDict stringForKey:@"phone"];
    lProfile.name = [[lAccountDict stringForKey:@"name"] isEqualToString:@"<null>"] ? @"" : [lAccountDict stringForKey:@"name"];
    lProfile.id_ = [lAccountDict stringForKey:@"id"];
    lProfile.email = [lAccountDict stringForKey:@"email"];
    if(![[dict objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
    lProfile.description_ = [lAccountDict stringForKey:@"description"];
    }
    lProfile.created_at = [lAccountDict stringForKey:@"created_at"];
    lProfile.avatarUrl = [lAccountDict stringForKey:@"avatar_url"];

    return lProfile;
}


@end
