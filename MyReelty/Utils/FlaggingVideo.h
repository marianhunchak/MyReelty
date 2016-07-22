//
//  FlaggingVideo.h
//  MyReelty
//
//  Created by Admin on 7/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlaggingVideo : NSObject


+ (instancetype)sharedInstance;
- (void)flagVideoWithReviewID:(NSInteger) revievID;

@end
