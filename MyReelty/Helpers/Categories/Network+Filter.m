//
//  Network+Filter.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Network+Filter.h"
#import "SearchFilter.h"

@implementation Network (Filter)

+ (NSString *)getUrlParametersWhithFilters:(SearchFilter *)filter {
    
    NSString *requestType = @"";
    
    if (filter) {
        
        NSString *propertyType = @"";
        switch (filter.typeOfProperty) {
            case 0:
                propertyType  = [NSString stringWithFormat:@"&property_type=%@", @"House"];
                break;
            case 1:
                propertyType  = [NSString stringWithFormat:@"&property_type=%@",@"Condo"];
                break;
            case 2:
                propertyType  = [NSString stringWithFormat:@"&property_type=%@",@"Townhouse"];
                break;
            case 3:
                propertyType  = [NSString stringWithFormat:@"&property_type=%@",@"Other"];
                break;
                
            default:
                break;
        }
        
        NSString *beds = @"";
        
        if (filter.beds) {
        
            if (filter.beds != 0 && filter.beds!=5) {
                beds = [NSString stringWithFormat:@"&beds=%lu", (long)filter.beds];
            } else {
                beds = [NSString stringWithFormat:@"&beds_from=%lu", (long)filter.beds];
            }
        }
        
        NSString *baths = @"";
        
        if (filter.baths) {
        
            if (filter.baths != 0 && filter.baths!=5) {
                baths = [NSString stringWithFormat:@"&baths=%lu", (long)filter.baths];
            } else {
                baths = [NSString stringWithFormat:@"&baths_from=%lu", (long)filter.baths];
            }
        }
        NSString *availability = @"";
        if (filter.onTheMarket || filter.offTheMarket) {
            availability = [NSString stringWithFormat:@"&availability=%@", filter.onTheMarket ? @"true" : @"false"];
        }
        
        NSString *price_from = @"";
        if (!(filter.priceMin <= 50000)) {
            price_from = [NSString stringWithFormat:@"&price_from=%lu", (long)filter.priceMin];
        }
//        else {
//            price_from = [NSString stringWithFormat:@"&price_from=%i", 0];
//        }
        
        NSString *price_to = @"";
        if (filter.priceMax != 10000000) {
            price_to = [NSString stringWithFormat:@"&price_to=%lu", (long)filter.priceMax];
        }
        
        NSString *size_from = @"";
        if (filter.sizeMin != 500) {
            size_from = [NSString stringWithFormat:@"&square_from=%lu", (long)filter.sizeMin];
        }
        
        NSString *size_to = @"";
        if (filter.sizeMax != 3000) {
            size_to = [NSString stringWithFormat:@"&square_to=%lu", (long)filter.sizeMax];
        }
        
        requestType = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",propertyType, beds, baths, availability, price_from, price_to, size_from, size_to];
    }
    
//    NSString *requestString = [[NSString stringWithFormat:@"&range=50"] stringByAppendingString:requestType];
    
    return requestType;
    
}

@end
