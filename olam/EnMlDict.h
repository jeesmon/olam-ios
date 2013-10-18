//
//  EnMlDict.h
//  olam
//
//  Created by Jacob, Jeesmon on 10/14/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnMlDict : NSObject

@property(nonatomic) int olamId;
@property(nonatomic, retain) NSString *en;
@property(nonatomic, retain) NSString *parts;
@property(nonatomic, retain) NSString *ml;

@end
