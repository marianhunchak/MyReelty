//
//  ErrorHandler.h
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorHandler : NSObject

+(NSString *)handleError:(NSError *) error;
+(NSString *)handleCommentError:(NSError *) error;
+(NSString *)handleSignError:(NSError *) error;
+(NSString *)handleResetPassError:(NSError *) error;
@end
