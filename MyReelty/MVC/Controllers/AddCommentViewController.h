//
//  AddCommentViewController.h
//  MyReelty
//
//  Created by Marian Hunchak on 3/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddCommentViewController;

@protocol CommentViewControllerDelegate <NSObject>

- (void) commentViewControllerPostBtnPressed:(NSDictionary *) comment;

@end

@interface AddCommentViewController : UIViewController

@property (nonatomic, assign) NSString *revieID;
@property (nonatomic, weak) id <CommentViewControllerDelegate> delegate;

@end
