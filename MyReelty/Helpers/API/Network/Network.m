//
//  Network.m
//  MinMedecine
//
//  Created by Ihor on 11/16/15.
//  Copyright © 2015 Pavel Gubin. All rights reserved.
//

#import "Network.h"
#import "Network+Filter.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Blocks.h"
#import "Review.h"
#import "Parser.h"
#import "SearchFilter.h"
#import "Profile.h"
#import "NSDictionary+Accessors.h"

@implementation Network

#pragma mark - Manager methods

+ (AFHTTPRequestOperationManager *)manager {
    AFHTTPRequestOperationManager *manager = [self managerForBaseURL:mainURL];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"$2b$12$N6riZb6zUppbBieu0ISSZOKXXSbVbUr/nUp1P7AtBOw2H3sYecdMy"] forHTTPHeaderField:@"Authentication-Token"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authentication-Token"];
    
    //$2b$12$Pmr3WqAdD8UROU0JebijCu.1yedULgZoINYJAqekNWB
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token_dict_key"]) {
//        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token_dict_key"];
//        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
//    }
    return manager;
}

+ (AFHTTPRequestOperationManager *)managerForBaseURL:(NSString *)baseURL {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    return manager;
}

#pragma mark - Reviews

+ (void)reviewsWithFilter:(SearchFilter *)filter loadMore:(BOOL)loadMore completion:(ArrayCompletionBlock)completionBlock {
    NSDictionary *param = nil;

    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews%@", requestType];
    
    [[Network manager] GET:requestString parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        NSArray *lReviews = [Parser parseReviews:responseObject];
        
        if(completionBlock) {
            completionBlock(lReviews, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %@", error);
    }];
}

+ (void)accountReviewsLoadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock {
    
    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"/api/account/reviews%@", requestType];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *userReview = [Parser parseReviewsWhithPagination:responseObject];
        
        if(completionBlock) {
            completionBlock(userReview, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %@", [error localizedDescription]);
    }];
}

+ (void)userReviewsForUserID:(NSString *) Id loadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock {
    
    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [[NSString stringWithFormat:@"/api/users/%@/reviews", Id] stringByAppendingString:requestType];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *userReview = [Parser parseReviewsWhithPagination:responseObject];
        completionBlock(userReview, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
    
}

+ (void)listAllNearestReviewsWhithAddress: (NSString *)address andFilter:(SearchFilter *)filter loadMore:(BOOL) loadMore withCompletion:(ArrayCompletionBlock)completionBlock {
    //TODO: category for filters
    NSString *requestType = [NSString stringWithFormat:@"&page_size=%i", REVIEWS_PAGE_SIZE];
    static int pageNumber = 1;
    
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    if (!address) {
        return;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"api/reviews/nearest?address=%@%@", address, [Network getUrlParametersWhithFilters:filter]];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *lNearestReviews = [Parser parseReviews:responseObject];
        completionBlock(lNearestReviews, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
    }];
    
}

+ (void)listBookmarkedReviewsLoadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock)completionBlock {
    
    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"api/account/bookmarks%@", requestType];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *lBookmarkedReviews = [Parser parseBookmarkedReviews:responseObject];
        
        if(completionBlock) {
            completionBlock(lBookmarkedReviews, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %@", error);
    }];
}

+ (void)getReviewForId:(NSString *)ID WithCompletion:(ObjectCompletionBlock)completionBlock {
    
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@", ID];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        Review *lReview = [Review reviewWithDict:[responseObject objectForKey:@"review"]];
        completionBlock(lReview, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

}

#pragma mark - Bookmarks

+ (void)createBookmarkForReviewID: (NSString *)Id WithCompletion:(ObjectCompletionBlock)complitionBlock {
     NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@/bookmark", Id];
    
    [[Network manager] POST:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        complitionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        complitionBlock(nil, error);
        
                NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

+ (void)deleteBookmarkForReviewID: (NSString *)Id WithCompletion:(ObjectCompletionBlock)complitionBlock {
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@/bookmark", Id];
    
    [[Network manager] DELETE:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSDictionary *likeDictionary = [responseObject objectForKey:@"like"];
        complitionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        complitionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
   
}

#pragma mark - Sign In methods

+ (void)signIn:(DBProfile *)profile WithCompletion: (DictCompletionBlock)completionBlock {
    
    NSDictionary *params = @{
                             @"session":
                                 @{
                                     @"email": profile.email,
                                     @"password": profile.password
                                     }
                             };
    [[Network manager] POST:@"/api/sign_in" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
    
}

+ (void)signUp:(DBProfile *)profile WhithCompletion: (ObjectCompletionBlock)completionBlock {
    
    NSDictionary *params = @{
                             @"account":
                                 @{
                                     @"email": profile.email,
                                     @"password": profile.password,
                                     @"name": profile.name
                                     }
                             };
    
    [[Network manager] POST:@"/api/sign_up" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];

}

+ (void)signInWhithFacebookToken:(id) token WithCompletion: (DictCompletionBlock)completionBlock {
    
    NSDictionary *params = @{
                             @"authentication":
                                 @{
                                     @"facebook_token": token
                                     }
                             };
    
    [[Network manager] POST:@"api/sign_in/facebook" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - Profile

+ (void)profileWithCompletion:(ObjectCompletionBlock)completionBlock {
    [[Network manager] GET:@"/api/account" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [Parser parseProfile:responseObject];
        if (completionBlock) {
            completionBlock([DBProfile main], nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

+ (void)profileForUserID:(NSString *) Id WithCompletion:(ObjectCompletionBlock)completionBlock {
     NSString *requestString = [NSString stringWithFormat:@"/api/users/%@", Id];
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        id profile = [Profile profileWithDict:responseObject];
        completionBlock(profile, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

}

#pragma mark - Comments

+ (void)createCommnetForReviewID: (NSString *) Id AndContent:(NSString *)contentString WithCompletion: (DictCompletionBlock)completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@/comments", Id];
    NSDictionary *params = @{@"comment":@{
                                     @"content": contentString
                                     }
                             };
    [[Network manager] POST:requestString parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *commentsResponseDictionary = [responseObject objectForKey:@"comment"];
        completionBlock(commentsResponseDictionary, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
//        NSLog(@"err: %@", );
    }];
}

+ (void)commentsListForReviewID:(NSString *) Id loadMore:(BOOL)loadMore WithCompletion:(DictCompletionBlock) completionBlock {
    
    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [[NSString stringWithFormat:@"/api/reviews/%@/comments", Id] stringByAppendingString:requestType];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSDictionary *commentsArray = [responseObject objectForKey:@"comments"];
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - Likes

+ (void)createLikeForReviewID: (NSString *) Id WithCompletion: (DictCompletionBlock)completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@/likes", Id];
    
    [[Network manager] POST:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *likeDictionary = [responseObject objectForKey:@"like"];
        completionBlock(likeDictionary, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSHTTPURLResponse  *response = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];

        NSLog(@"err: %li",[response statusCode]);
    }];
}

+ (void)deleteLikeForReviewID: (NSString *)Id WithCompletion: (DictCompletionBlock)completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%@/like", Id];
    
    [[Network manager] DELETE:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *likeDictionary = [responseObject objectForKey:@"like"];
        completionBlock(likeDictionary, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

+ (void)likesListForReviewID: (NSString *)Id loadMore:(BOOL)loadMore WithCompletion: (DictCompletionBlock)completionBlock {
    
    static int pageNumber = 1;
    
    NSString *requestType = [NSString stringWithFormat:@"?page_size=%i", REVIEWS_PAGE_SIZE];
    if(loadMore) {
        requestType = [requestType stringByAppendingString:[NSString stringWithFormat:@"&page=%i", ++pageNumber]];
    } else {
        pageNumber = 1;
    }
    
    NSString *requestString = [[NSString stringWithFormat:@"/api/reviews/%@/likes", Id] stringByAppendingString:requestType];
    
    [[Network manager] GET:requestString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}

+ (void)listMostVisitedReviewsWithCompletion:(ArrayCompletionBlock)completionBlock {
    NSDictionary *param = nil;

    [[Network manager] GET:@"api/reviews/most_visited" parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *lMostVisitedReviews = [Parser parseReviews:responseObject];
        
        if(completionBlock) {
            completionBlock(lMostVisitedReviews, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        NSLog(@"err: %lu", error.code);
    }];
}

+ (void)getLocationByNetworkProvider:(DictCompletionBlock)completion {
    

    [[Network managerForBaseURL:@"http://ip-api.com/"] GET:@"json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completion) {
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

#pragma mark - Pins list

+ (void)getPinsListWhithAddress: (NSString *)address andFilter:(SearchFilter *)filter WithCompletion:(ArrayCompletionBlock)completionBlock {
    
    NSDictionary *param = nil;
    
    if (!address) {
        return;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"api/reviews/pins?address=%@%@", address, [Network getUrlParametersWhithFilters:filter]];

    [[Network manager] GET:requestString parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        NSArray *lPins = [Parser parsePins:responseObject];
        
        if(completionBlock) {
            completionBlock(lPins, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
         NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
    
}
#pragma mark - ResetPassword

+ (void)sendMessageWithEmail: (NSString *) email WithCompletion: (DictCompletionBlock)completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"/api/account/forgot_password"];
    NSDictionary *params = @{@"account":@{
                                     @"email": email
                                     }
                             };
    [[Network manager] POST:requestString parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
   
}

+ (void) updateUserProfile:(NSDictionary *) pDictionary {
    NSString *requestString = [NSString stringWithFormat:@"/api/account"];
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"avatar.jpg"], 0.5);
    [Network postToUrl:@"" data:imageData withFilename:@"avatar.jpg"];

}

+ (NSString*) postToUrl:(NSString*)urlString data:(NSData*)dataToSend withFilename:(NSString*)filename
    {
        NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://myreelty.com/api/account"]];
        [request setHTTPMethod:@"PUT"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN_DICT_KEY];
        [request setValue:token forHTTPHeaderField:@"Authentication-Token"];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *postbody = [NSMutableData data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"account[avatar]\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:dataToSend]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postbody];
        
        NSError* error;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (returnData) {
            return [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        }
        else {
            return nil;
        }
    }

#pragma mark - Flag Video

+ (void)reportVideoWithRevievID:(NSInteger) reviewID reasonString:(NSString *) reason WithCompletion: (DictCompletionBlock)completionBlock {
    
    NSDictionary *params = @{
                             @"inappropriate":
                                 @{
                                     @"reason": reason,
                                     @"comment": @""
                                     }
                             };
    
    NSString *requestString = [NSString stringWithFormat:@"/api/reviews/%lu/inappropriates", (long) reviewID];
    
    [[Network manager] POST:requestString parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        completionBlock(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
        
        NSLog(@"err: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
    
}

@end