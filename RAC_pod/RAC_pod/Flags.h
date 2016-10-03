//
//  Flags.h
//  RAC_pod
//
//  Created by Zhuge_Mac on 16/10/3.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flags : NSObject
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * icon;
+ (instancetype)flagWithDict:(NSDictionary *)dict;
@end
