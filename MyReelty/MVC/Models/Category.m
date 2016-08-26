//
//  Category.m
//  MyReelty
//
//  Created by Admin on 8/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Category.h"
#import "NSDictionary+Accessors.h"
#import "Parser.h"

@implementation Category

+ (instancetype)categoryWithDict:(NSDictionary *)dict {
    
    Category *lCategory = [Category new];
    lCategory.created_at = [dict stringForKey:@"created_at"];
    lCategory.id_ = [dict unsignedIntegerForKey:@"id"];
    lCategory.visible = [dict boolForKey:@"visible"];
    lCategory.name = [dict stringForKey:@"name"];
    lCategory.reviews = [Parser parseReviews:dict];
    
    return lCategory;
}

@end
