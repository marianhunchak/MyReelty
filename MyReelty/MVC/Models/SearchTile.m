//
//  SearchTile.m
//  MyReelty
//
//  Created by Admin on 8/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SearchTile.h"
#import "NSDictionary+Accessors.h"

@implementation SearchTile

+ (instancetype)searchTileWithDict:(NSDictionary *)dict {
    
    SearchTile *lSearchTile = [SearchTile new];
    lSearchTile.created_at = [dict stringForKey:@"created_at"];
    lSearchTile.id_ = [dict unsignedIntegerForKey:@"id"];
    lSearchTile.visible = [dict boolForKey:@"visible"];
    lSearchTile.name = [dict stringForKey:@"name"];
    lSearchTile.imageURL = [NSURL URLWithString:[dict stringForKey:@"image"]];
    lSearchTile.search_query = [dict stringForKey:@"search_query"];
    
    return lSearchTile;
}

@end
