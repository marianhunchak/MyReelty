//
//  SearchFilter.h
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchFilter : NSObject

@property (nonatomic) NSInteger typeOfProperty;
@property (nonatomic) BOOL onTheMarket;
@property (nonatomic) BOOL offTheMarket;
@property (nonatomic) NSInteger priceMin;
@property (nonatomic) NSInteger priceMax;
@property (nonatomic) NSInteger beds;
@property (nonatomic) NSInteger baths;
@property (nonatomic) NSInteger sizeMin;
@property (nonatomic) NSInteger sizeMax;

@property (nonatomic) BOOL isChanged;

+ (instancetype)newFilter;
- (void)resetFilters;

@end
