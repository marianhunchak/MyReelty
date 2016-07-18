//
//  Page.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/12/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Page.h"
#import "NSDictionary+Accessors.h"

@implementation Page

+ (instancetype)pagewWithDict:(NSDictionary *)dict {
    Page *lPage = [Page new];
    lPage.total_pages = [dict unsignedIntegerForKey:@"total_pages"];
    lPage.total_entries = [dict unsignedIntegerForKey:@"total_entries"];
    lPage.page_size = [dict unsignedIntegerForKey:@"page_size"];
    lPage.page_number = [dict unsignedIntegerForKey:@"page_number"];
    
    return lPage;
}

@end
