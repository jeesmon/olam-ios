//
//  DictDao.h
//  olam
//
//  Created by Jacob, Jeesmon on 10/14/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictDao : NSObject

- (NSString *) getDatabasePath: (NSString *) databaseName;
- (NSMutableArray *) fetchRows: (NSString *) databaseName withText: (NSString *) text andExactMatch: (bool) exact;
- (NSMutableArray *) fetchWords: (NSString *) databaseName withText: (NSString *) text;

@end
