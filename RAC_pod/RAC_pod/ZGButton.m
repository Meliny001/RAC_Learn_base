//
//  ZGButton.m
//  RAC_pod
//
//  Created by Zhuge_Mac on 16/10/3.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ZGButton.h"
NSString * const ZGbuttonKey = @"ZGButtonClicked";

@implementation ZGButton

- (RACSubject *)subject
{
    if (!_subject) {
        _subject = [RACSubject subject];
    }
    return _subject;
}

- (void)initSet
{

    self.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonClicked)];
    [self addGestureRecognizer:tap];

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initSet];
    
}

- (void)buttonClicked
{
    [self.subject sendNext:@"buttonClicked"];
    [[NSNotificationCenter defaultCenter]postNotificationName:ZGbuttonKey object:nil];
}

@end
