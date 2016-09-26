//
//  Network.h
//  MinMedecine
//
//  Created by Ihor on 11/16/15.
//  Copyright © 2015 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Blocks.h"
#import "Review.h"
#import "DBProfile.h"

#define REVIEWS_PAGE_SIZE 10

@class SearchFilter;
@interface Network : NSObject

+ (void)profileWithCompletion:(ObjectCompletionBlock)completionBlock;
+ (void)accountReviewsLoadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock;
+ (void)getReviewForId:(NSString *)ID WithCompletion:(ObjectCompletionBlock)completionBlock;

+ (void)profileForUserID:(NSString *) Id WithCompletion:(ObjectCompletionBlock)completionBlock;
+ (void)userReviewsForUserID:(NSString *) Id loadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock;

+ (void)reviewsWithFilter:(SearchFilter *)filter loadMore:(BOOL)loadMore completion:(ArrayCompletionBlock)completionBlock;

+ (void)createBookmarkForReviewID: (NSString *)Id WithCompletion:(ObjectCompletionBlock)complitionBlock;
+ (void)deleteBookmarkForReviewID: (NSString *)Id WithCompletion:(ObjectCompletionBlock)complitionBlock;
+ (void)listBookmarkedReviewsLoadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock;

+ (void)signIn:(DBProfile *)profile WithCompletion: (DictCompletionBlock)completionBlock;
+ (void)signUp:(DBProfile *)profile WhithCompletion: (ObjectCompletionBlock)completionBlock;
+ (void)signInWhithFacebookToken:(id) token WithCompletion: (DictCompletionBlock)completionBlock;

+ (void)createCommnetForReviewID: (NSString *) Id AndContent:(NSString *)contentString WithCompletion: (DictCompletionBlock)completionBlock;
+ (void)commentsListForReviewID: (NSString *)Id loadMore:(BOOL)loadMore WithCompletion: (DictCompletionBlock)completionBlock;

+ (void)createLikeForReviewID: (NSString *)Id WithCompletion: (DictCompletionBlock)completionBlock;
+ (void)deleteLikeForReviewID: (NSString *)Id WithCompletion: (DictCompletionBlock)completionBlock;
+ (void)likesListForReviewID: (NSString *)Id loadMore:(BOOL)loadMore WithCompletion: (DictCompletionBlock)completionBlock;

+ (void)listAllNearestReviewsWhithAddress: (NSString *)address withCompletion:(ArrayCompletionBlock)completionBlock;
+ (void)listAllNearestReviewsWhithAddress: (NSString *)address andFilter:(SearchFilter *)filter loadMore:(BOOL) loadMore withCompletion:(ArrayCompletionBlock)completionBlock;
+ (void)listMostVisitedReviewsWithCompletion:(ArrayCompletionBlock)completionBlock;

+ (void)getLocationByNetworkProvider:(DictCompletionBlock)completion;
+ (void)getPinsListWhithAddress:(NSString *)address andFilter:(SearchFilter *)filter WithCompletion:(ArrayCompletionBlock)completionBlock;

+ (void)sendMessageWithEmail:(NSString *) email WithCompletion: (DictCompletionBlock)completionBlock;


+ (void) updateUserProfileWithImageData:(NSData *)imageData
                            phoneNumber:(NSString *)phone
                             userRoleID:(NSInteger)roleID
                            description:(NSString *)description
                         withCompletion:(ObjectCompletionBlock)completionBlock;

+ (void)reportVideoWithRevievID:(NSInteger) reviewID reasonString:(NSString *) reason WithCompletion: (DictCompletionBlock)completionBlock;

+ (void)getPremiumReviewsWithConletion:(ArrayCompletionBlock)completionBlock;
+ (void)getCategoriesWithCompletion:(ArrayCompletionBlock)completionBlock;
+ (void)getSearchTilesWithCompletion:(ArrayCompletionBlock)completionBlock;
+ (void)getTotalReviesCountWithCompletion:(ObjectCompletionBlock)completionBlock;

+ (void)getRolesListWithCompletion:(ArrayCompletionBlock)completionBlock;
+ (void)claimUserWithName:(NSString *)name
                    phone:(NSString *)phone
                    email:(NSString *)email
                  message:(NSString *)message
            claimedUserID:(NSInteger)userID
           WithCompletion:(DictCompletionBlock)completionBlock;
+ (void)updateProfileWithImage:(UIImage *)image withCompletion:(DictCompletionBlock)completionBlock;

@end
