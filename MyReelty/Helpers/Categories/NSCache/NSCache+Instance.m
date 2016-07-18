//
//  NSCache+Instance.m
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSCache+Instance.h"

@implementation NSCache (Instance)

+ (instancetype)instance {
    static NSCache *sCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sCache = [NSCache new];
    });
    return sCache;
}

@end
