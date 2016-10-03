//
//  Flags.m
//  RAC_pod
//
//  Created by Zhuge_Mac on 16/10/3.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "Flags.h"

@implementation Flags
+ (instancetype)flagWithDict:(NSDictionary *)dict
{
    Flags * flag = [[Flags alloc]init];
    [flag setValuesForKeysWithDictionary:dict];
    return flag;
}
@end
