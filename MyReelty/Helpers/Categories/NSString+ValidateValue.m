//
//  NSString+ValidateValue.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSString+ValidateValue.h"

@implementation NSString (ValidateValue)


+ (NSString *)validateValue:(id)value {
    
    if([value isKindOfClass:[NSString class]]) {
        
        if ([value isEqualToString:@"<null>"] || [value isEqualToString:@"null"] || [value isEqualToString:@""]) {
            return nil;
        } else {
            return value;
        }
    }
    return nil;
}

@end
