//
//  YXWriteHomeworkInfoMenuView.h
//  TrainApp
//
//  Created by 郑小龙 on 16/8/12.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChapterListRequest.h"
@interface YXWriteHomeworkInfoMenuView : UITableViewHeaderFooterView
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, strong)YXChapterListRequestItem *item;
@property (nonatomic, copy) void (^chapterIdHandler)(NSString *chapterId, NSString *chapterName);
@property (nonatomic, copy) void (^errorHandler)(void);
@property (nonatomic, assign) BOOL isError;
@end
