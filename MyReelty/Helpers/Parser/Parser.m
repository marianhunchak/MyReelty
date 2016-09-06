//
//  Parser.m
//  MyReelty
//
//  Created by Ihor on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Parser.h"
#import "Review.h"
#import "PremiumReview.h"
#import "NSDictionary+Accessors.h"
#import "DBProfile.h"
#import "Pin.h"
#import "Page.h"
#import "Category.h"
#import "SearchTile.h"
#import "Role.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation Parser

+ (NSArray *)parseReviews:(NSDictionary *)dict {
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:@"reviews"];
    for (NSDictionary *reviewDict in lReviews) {
        Review *lReview = [Review reviewWithDict:reviewDict];
        [lMutableReviews addObject:lReview];
    }
    return [NSArray arrayWithArray:lMutableReviews];
}

+ (NSArray *)parseReviews:(NSDictionary *)dict withKey:(NSString *)key {
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:key];
    for (NSDictionary *reviewDict in lReviews) {
        PremiumReview *lReview = [PremiumReview premiumReviewWithDict:reviewDict];
        [lMutableReviews addObject:lReview];
    }
    return [NSArray arrayWithArray:lMutableReviews];
}

+ (NSArray *)parseCategories:(NSDictionary *)dict withKey:(NSString *)key {
    
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:key];
    for (NSDictionary *reviewDict in lReviews) {
        Category *lCategory = [Category categoryWithDict:reviewDict];
        [lMutableReviews addObject:lCategory];
    }
    return [NSArray arrayWithArray:lMutableReviews];
}

+ (NSArray *)parseSearchTiles:(NSDictionary *)dict {
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:@"search_tiles_page"];
    for (NSDictionary *reviewDict in lReviews) {
        SearchTile *lSearchTile = [SearchTile searchTileWithDict:reviewDict];
        [lMutableReviews addObject:lSearchTile];
    }
    return [NSArray arrayWithArray:lMutableReviews];
}

+ (NSDictionary *)parseBookmarkedReviews:(NSDictionary *)dict {
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:@"bookmarks"];
    for (NSDictionary *reviewDict in lReviews) {
        Review *lReview = [Review reviewWithDict:[reviewDict objectForKey:@"review"]];
        [lMutableReviews addObject:lReview];
    }
    Page *lPage = [Page pagewWithDict:[dict dictionaryForKey:@"pagination"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithArray:lMutableReviews], @"reviews",
                                                                                         lPage, @"page",nil];
}

+ (void)parseProfile:(NSDictionary *)dict {
    DBProfile *lProfile = [DBProfile MR_findFirst];
    if (!lProfile) {
        lProfile = [DBProfile MR_createEntity];
    }
    
    NSDictionary *lAccountDict = [dict dictionaryForKey:@"account"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        lProfile.phone = [lAccountDict stringForKey:@"phone"];
        lProfile.name = [lAccountDict stringForKey:@"name"];
        lProfile.id_ = [lAccountDict stringForKey:@"id"];
        lProfile.email = [lAccountDict stringForKey:@"email"];
        lProfile.description_ = [lAccountDict stringForKey:@"description"];
        lProfile.created_at = [lAccountDict stringForKey:@"created_at"];
        [Parser writeToFileImageWihtUrl:[lAccountDict stringForKey:@"avatar_url"]];
        lProfile.avatarUrl = [Parser documentsPathForFileName:@"image.png"];
        NSString *role = [[lAccountDict dictionaryForKey:@"role"] stringForKey:@"name"];
        lProfile.roleName = [role isEqualToString:@""] ? @"Regular User" : role;
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PROFILE_AVATAR_DID_LOADED object:lProfile.avatarUrl];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }];
}

+ (NSArray *)parsePins:(NSDictionary *)dict {
    NSMutableArray *lMutablePins = [NSMutableArray new];
    NSArray *lPins = [dict arrayForKey:@"pins"];
    for (NSDictionary *pinDict in lPins) {
        Pin *lPin = [Pin pinWithDict:pinDict];
        [lMutablePins addObject:lPin];
    }
    return [NSArray arrayWithArray:lMutablePins];
}

+ (NSArray *)parseRoles:(NSDictionary *)dict {
    NSMutableArray *lMutableRoles = [NSMutableArray new];
    NSArray *lRoles = [dict arrayForKey:@"roles"];
    for (NSDictionary *roleDict in lRoles) {
        Role *lRole = [Role roleWithDict:roleDict];
        [lMutableRoles addObject:lRole];
    }
    return [NSArray arrayWithArray:lMutableRoles];
}

+ (NSDictionary *)parseReviewsWhithPagination:(NSDictionary *)dict {
    NSMutableArray *lMutableReviews = [NSMutableArray new];
    NSArray *lReviews = [dict arrayForKey:@"reviews"];
    for (NSDictionary *reviewDict in lReviews) {
        Review *lReview = [Review reviewWithDict:reviewDict];
        [lMutableReviews addObject:lReview];
    }
    Page *lPage = [Page pagewWithDict:[dict dictionaryForKey:@"pagination"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithArray:lMutableReviews], @"reviews",
                                                                                         lPage, @"page",
                                                                                                        nil];
}

+ (void) writeToFileImageWihtUrl:(NSString *) pImageUrl {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pImageUrl]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [data writeToFile:filePath atomically:YES];
}

+ (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}


@end