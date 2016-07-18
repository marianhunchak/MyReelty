//
//  NSString+DivideNumber.m
//  MyReelty
//
//  Created by Marian Hunchak on 11/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSString+DivideNumber.h"

@implementation NSString (DivideNumber)

- (NSString *)divideNumber{
    NSMutableString *newNumber = [NSMutableString stringWithString:self];
    
    for(NSInteger i = [self length] - 3; i > 0; i-=3) {
        if(i <= 0) {
            break;
        }
        [newNumber insertString:@"." atIndex:i];
    }
    
    return [NSString stringWithFormat:@"%@",newNumber];
}
@end
