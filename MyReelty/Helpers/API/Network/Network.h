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

#define REVIEWS_PAGE_SIZE 25

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
+ (void)listBookmarkedReviewsLoadMore:(BOOL)loadMore WithCompletion:(ArrayCompletionBlock)completionBlock;

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


+ (void) updateUserProfile:(NSDictionary *) pDictionary;
@end
