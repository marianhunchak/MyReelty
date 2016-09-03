//
//  NSDate+String.m
//  MyReelty
//
//  Created by Marian Hunchak on 9/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)


+ (NSDate *)getDateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-ddEEEEHH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

@end
