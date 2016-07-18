//
//  Network+Filter.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Network.h"

@class SearchFilter;

@interface Network (Filter)

+ (NSString *)getUrlParametersWhithFilters:(SearchFilter *)filter;

@end
