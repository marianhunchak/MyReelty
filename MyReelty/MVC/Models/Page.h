//
//  Page.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/12/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Page : NSObject

@property (nonatomic, assign) NSUInteger total_pages;
@property (nonatomic, assign) NSUInteger total_entries;
@property (nonatomic, assign) NSUInteger page_size;
@property (nonatomic, assign) NSUInteger page_number;

+ (instancetype)pagewWithDict:(NSDictionary *)dict;

@end
