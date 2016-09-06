//
//  Role.h
//  MyReelty
//
//  Created by Marian Hunchak on 9/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Role : NSObject

@property (nonatomic, assign) NSUInteger id_;
@property (nonatomic, copy) NSString *name;

+ (instancetype)roleWithDict:(NSDictionary *)dict;

@end
