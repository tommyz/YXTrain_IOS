//
//  YXTrainListRequest.m
//  TrainApp
//
//  Created by niuzhaowang on 16/6/27.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXTrainListRequest.h"

@implementation YXTrainListRequestItem_body_train
- (NSString<Optional> *)role {
    if (_role) {
        return _role;
    }else {
        NSArray *array = [self.roles componentsSeparatedByString:@","];
        for (NSString *r in array) {
            if ([r isEqualToString:@"99"]) {
                return @"99";
            }
        }
        return @"9";
    }
}
- (NSString<Optional> *)doubel {
    BOOL isMaster = NO;
    BOOL isStudent = NO;
    NSArray *array = [self.roles componentsSeparatedByString:@","];
    for (NSString *r in array) {
        if ([r isEqualToString:@"99"]) {
            isMaster = YES;
        }
        if ([r isEqualToString:@"9"]) {
            isStudent = YES;
        }
    }
    if (isStudent && isMaster) {
        return @"2";
    }else {
        return @"1";
    }
}
@end

@implementation YXTrainListRequestItem_body

@end

@implementation YXTrainListRequestItem

@end

@implementation YXTrainListRequest
- (instancetype)init
{
    if (self = [super init]) {
        self.urlHead = [[YXConfigManager sharedInstance].server stringByAppendingString:@"guopei/trainlist"];
    }
    return self;
}
@end
