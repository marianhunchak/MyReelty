//
//  consts.h
//  MinMedecine
//
//  Copyright (c) 2013 NerdPeople. All rights reserved.
//

#ifndef Constants_consts_h
#define Constants_consts_h

#ifdef DEBUG
static NSString *mainURL = @"http://staging.myreelty.com";
#else 
static NSString *mainURL = @"http://myreelty.com";
#endif
static CGFloat koeficientForCellHeight = 3.f / 4.f;

#endif
