//
//  Global.h
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#ifndef Global_h
#define Global_h

#define kHelveticaNeueM(fontSize) [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize]
#define kHelveticaNeue(fontSize)  [UIFont fontWithName:@"HelveticaNeue" size:fontSize]
#define kHelveticaNeueB(fontSize) [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]

#define TEST 1
#define ACCESS_TOKEN_DICT_KEY @"acces_token_dict_key"

#define STORYBOARD_NAME @"Main"
#define VIEW_CONTROLLER(viewController) [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil] instantiateViewControllerWithIdentifier:viewController];


#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)


#define RGBHColor(hexValue)     [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define colorWithRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define navigationBarColor [UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:95.0/255.0 alpha:1.0]


#endif /* Global_h */
