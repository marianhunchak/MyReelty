//
//  DBProfile.h
//  MyReelty
//
//  Created by Marian Hunchak on 01/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBProfile : NSManagedObject


+ (DBProfile *)main;

- (void)fromDict:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END

#import "DBProfile+CoreDataProperties.h"
