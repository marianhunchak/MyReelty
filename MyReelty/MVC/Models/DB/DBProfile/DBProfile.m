//
//  DBProfile.m
//  MyReelty
//
//  Created by Marian Hunchak on 01/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "DBProfile.h"
#import "NSDictionary+Accessors.h"

@implementation DBProfile


+ (DBProfile *)main {
    DBProfile *lMain = nil;
    NSArray *lProfiles = [DBProfile MR_findAll];
    if (lProfiles.count > 0) {
        lMain = lProfiles[0];
    } else {
        lMain = [DBProfile MR_createEntity];
    }
    return lMain;
}
    
- (void)fromDict:(NSDictionary *)dict {

}


@end
