//
//  Blocks.h
//  MinMedecine
//
//  Created by Ihor on 2/3/16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#ifndef Blocks_h
#define Blocks_h

typedef void (^CompletionBlock)(NSError *error);

typedef void (^BooleanCompletionBlock)(BOOL result, NSError *error);

typedef void (^ObjectCompletionBlock)(id object, NSError *error);

typedef void (^ArrayCompletionBlock)(NSArray *array, NSError *error);

typedef void (^DictCompletionBlock)(NSDictionary *array, NSError *error);

#endif /* Blocks_h */