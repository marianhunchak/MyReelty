//
//  DBProfile+CoreDataProperties.h
//  MyReelty
//
//  Created by Marian Hunchak on 01/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBProfile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *created_at;
@property (nullable, nonatomic, retain) NSString *description_;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *id_;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *avatarUrl;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSNumber *autorized;
@property (nullable, nonatomic, retain) NSString *roleName;

@end

NS_ASSUME_NONNULL_END
