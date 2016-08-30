//
//  FlaggingVideo.m
//  MyReelty
//
//  Created by Admin on 7/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "FlaggingVideo.h"
#import "Network.h"
#import "SAMHUDView.h"
#import "ErrorHandler.h"
@interface FlaggingVideo() <UIActionSheetDelegate>

@end

@implementation FlaggingVideo

+ (instancetype)sharedInstance {
    
    static FlaggingVideo* flaggingVideo = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        flaggingVideo = [[FlaggingVideo alloc] init];
    });
    
    return flaggingVideo;

}


- (void)flagVideoWithReviewID:(NSInteger) revievID {
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Why are you reporting this video?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Sexual Content",
                                                                      @"Hateful & Abusive",
                                                                      @"Depicting Violence",
                                                                      @"Spam/Misleading Content",
                                                                      @"Quality Issues",
                                                                      @"Copyright Issues", nil];
    
    actionSheet.tag = revievID;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex < 6) {
        
        SAMHUDView *hd = [[SAMHUDView alloc] initWithTitle:@"Reporting..." loading:YES];
        
        [hd show];
    
        [Network reportVideoWithRevievID:actionSheet.tag reasonString:[actionSheet buttonTitleAtIndex:buttonIndex] WithCompletion:^(NSDictionary *array, NSError *error) {
            
            if (error == nil) {
                NSLog(@"%@", array);
                
                [hd completeAndDismissWithTitle:@"Reported"];
                
                NSString *reviewIDString = [NSString stringWithFormat:@"%lu", (long)actionSheet.tag];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_DID_FLAG_VIDEO object:reviewIDString];
                
            } else {
                
                [hd dismissAnimated:NO];
                [ErrorHandler handleFlaggingError:error];
                
            }
        }];
    
    }
}


@end
