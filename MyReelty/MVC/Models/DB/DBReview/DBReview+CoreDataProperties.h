//
//  DBReview+CoreDataProperties.h
//  MyReelty
//
//  Created by Ihor on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBReview.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBReview (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nonatomic) BOOL availability;
@property (nonatomic) int16_t baths;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *description_;
@property (nullable, nonatomic, retain) NSString *full_address;
@property (nullable, nonatomic, retain) NSString *id_;
@property (nonatomic) float price;
@property (nullable, nonatomic, retain) NSString *property_type;
@property (nonatomic) int16_t rooms;
@property (nonatomic) float square;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *video_url;
@property (nullable, nonatomic, retain) NSString *zipcode;
@property (nonatomic) BOOL watchLater;
@property (nullable, nonatomic, retain) NSManagedObject *relationship;

@end

NS_ASSUME_NONNULL_END
