//
//  ErrorHandler.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ErrorHandler.h"

@implementation ErrorHandler

+(NSString *)handleError:(NSError *) error {
    
    NSHTTPURLResponse  *response = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];
    
    NSString *msg = nil;
    
    if ([response statusCode] == 403) {
        msg = @"Please register or log in!";
    } else if ([response statusCode] == 0) {
        msg = @"No Internet connection!";
    }
    return msg;
}

+(NSString *)handleCommentError:(NSError *) error {
    
    NSHTTPURLResponse  *response = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];
    
    NSString *msg = nil;
    
    if ([response statusCode] == 403) {
        msg = @"Please register or log in!";
    } else if ([response statusCode] == 0) {
        msg = @"No Internet connection!";
    } else if ([response statusCode] == 422) {
        msg = @"Should be at least 2 characters!";
    }
    return msg;
}

+(NSString *)handleSignError:(NSError *) error {
    
    NSHTTPURLResponse  *response = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];
    
    NSString *msg = nil;
    
    if ([response statusCode] == 422) {
        msg = @"This email already exists!";
    } else if ([response statusCode] == 0) {
        msg = @"No Internet connection!";
    } else if ([response statusCode] == 401) {
        msg = @"Invalid email or password!";
    }
    return msg;
}

+(NSString *)handleResetPassError:(NSError *) error {
    
    NSHTTPURLResponse  *response = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];
    
    NSString *msg = nil;
    if ([response statusCode] == 0) {
        msg = @"No Internet connection!";
    } else if ([response statusCode] == 404) {
        msg = @"Invalid email!";
    }
    return msg;
}

@end
