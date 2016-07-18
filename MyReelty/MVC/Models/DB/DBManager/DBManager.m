//
//  DBManager.m
//  MyReelty
//
//  Created by Ihor on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "DBManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DBProfile.h"

@implementation DBManager

+ (DBProfile *)profile {
    
    DBProfile *lProfile = [DBProfile MR_findFirst];
    if (!lProfile) {
        lProfile = [DBProfile MR_createEntity];
        lProfile.name = @"Ihor";
        lProfile.email = @"ihor.koblan@gmail.com";
        lProfile.description_ = @"Very good boy!!!";
        lProfile.id_ = @"1";
    }
    return lProfile;
}

@end