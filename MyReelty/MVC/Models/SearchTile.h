//
//  SearchTile.h
//  MyReelty
//
//  Created by Admin on 8/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchTile : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *search_query;
@property (nonatomic, assign) NSUInteger id_;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, copy) NSURL *imageURL;

+ (instancetype)searchTileWithDict:(NSDictionary *)dict;

@end
