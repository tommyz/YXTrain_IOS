//
//  YXCategoryListRequest.m
//  TrainApp
//
//  Created by 郑小龙 on 16/8/4.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXCategoryListRequest.h"
@implementation YXCategoryListRequestItem_Data

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"categoryId":@"id",
                                                       }];
}
@end

@implementation YXCategoryListRequestItem



@end
@implementation YXCategoryListRequest
- (instancetype)init
{
    if (self = [super init]) {
        self.urlHead = [[LSTSharedInstance sharedInstance].configManager.server stringByAppendingString:@"meizi/category/listc2"];
    }
    return self;
}
@end
