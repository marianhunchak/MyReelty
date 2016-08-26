//
//  Category.h
//  MyReelty
//
//  Created by Admin on 8/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger id_;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, strong) NSArray *reviews;

+ (instancetype)categoryWithDict:(NSDictionary *)dict;

@end
