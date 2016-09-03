//
//  Profile.h
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *roleName;

+ (instancetype)profileWithDict:(NSDictionary *)dict;

@end
