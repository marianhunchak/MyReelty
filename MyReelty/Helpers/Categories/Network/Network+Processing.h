//
//  Network+Processing.h
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Network.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Blocks.h"

@interface Network (Processing)

+ (void)videoThumbNailForURL:(NSURL *)url completionBlock:(ObjectCompletionBlock)completion;

@end
