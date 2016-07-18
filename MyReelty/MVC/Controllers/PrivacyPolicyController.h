//
//  PrivacyPolicyController.h
//  MyReelty
//
//  Created by Marian Hunchak on 5/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyPolicyController : UIViewController

typedef NS_ENUM( NSUInteger, InfoType ) {
    InfoTypeTermsOfService = 0,
    InfoTypePrivacyPolicy = 1
};

@property (nonatomic, assign) InfoType infoType;

@end
