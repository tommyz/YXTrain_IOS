//
//  StudentsLearnSwipeCell.h
//  TrainApp
//
//  Created by 郑小龙 on 17/2/13.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "SwipeTableViewCell.h"
#import "MasterLearningInfoListRequest.h"
@interface StudentsLearnSwipeCell : SwipeTableViewCell
@property (nonatomic, strong) MasterLearningInfoListRequestItem_Body_LearningInfoList *learningInfo;
@end
