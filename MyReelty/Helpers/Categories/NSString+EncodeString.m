//
//  NSString+EncodeString.m
//  MyReelty
//
//  Created by Marian Hunchak on 3/31/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSString+EncodeString.h"

@implementation NSString (EncodeString)

-(NSString *)encodeUrlString {
    return CFBridgingRelease(
                             CFURLCreateStringByAddingPercentEscapes(
                                                                     kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)self,
                                                                     NULL,
                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                     kCFStringEncodingUTF8));
}


@end
