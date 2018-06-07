//
//  LookyLooCountryHandler.h
//  LookyLoo
//
//  Created by Sarthak Gupta on 03/09/15.
//  Copyright (c) 2015 LookyLoo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define TTELocationDB_NAME @"LookyLooCountryList.sqlite" // Name of databse


@interface LookyLooCountryHandler : NSObject

-(void)prepareDataBace;
- (NSMutableArray *)fetchCityListData:(NSString *)queryString;
- (NSMutableArray *)FetchCountry;
- (NSMutableArray *)fetchCityStateCountryZipListData:(NSString *)queryString;

@end
