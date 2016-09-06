//
//  Role.m
//  MyReelty
//
//  Created by Marian Hunchak on 9/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Role.h"
#import "NSDictionary+Accessors.h"

@implementation Role

+ (instancetype)roleWithDict:(NSDictionary *)dict {
    
    Role *lRole = [Role new];
    lRole.id_ = [dict unsignedIntegerForKey:@"id"];
    lRole.name = [dict stringForKey:@"name"];

    return lRole;
}

@end
