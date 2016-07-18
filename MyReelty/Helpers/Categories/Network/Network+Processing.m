//
//  Network+Processing.m
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Network+Processing.h"
#import "NSCache+Instance.h"

@implementation Network (Processing)

+ (void)videoThumbNailForURL:(NSURL *)url completionBlock:(ObjectCompletionBlock)completion {
    
    UIImage *lCachedImage = [[NSCache instance] objectForKey:url.path];
    if (lCachedImage) {
        completion(lCachedImage, nil);
        return;
    }
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("thread.background", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMake(1, 1);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (thumbnail) {
                completion(thumbnail,nil);
                [[NSCache instance] setObject:thumbnail forKey:url.path];
            } else {
                completion(nil,[NSError errorWithDomain:@"" code:500 userInfo:nil]);
            }
        });
    });
}

@end
