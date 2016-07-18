//
//  SearchFilter.m
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "SearchFilter.h"

@implementation SearchFilter

+ (instancetype)newFilter {
    SearchFilter *filter = [SearchFilter new];
    
    filter.typeOfProperty = -1;
    
    filter.priceMin = 50000;
    filter.priceMax = 10000000;
    
    filter.beds = 0;
    filter.baths = 0;
    
    filter.sizeMin = 500;
    filter.sizeMax = 3000;
    
    return filter;
}

- (void) resetFilters {
    
    self.typeOfProperty = -1;
    
    self.offTheMarket = NO;
    self.onTheMarket = NO;
    
    self.priceMin = 50000;
    self.priceMax = 10000000;
    
    self.beds = 0;
    self.baths = 0;
    
    self.sizeMin = 500;
    self.sizeMax = 3000;
}

@end
