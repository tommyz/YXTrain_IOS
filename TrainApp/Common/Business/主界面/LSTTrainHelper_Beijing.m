//
//  LSTTrainHelper_Beijing.m
//  TrainApp
//
//  Created by 郑小龙 on 16/12/12.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "LSTTrainHelper_Beijing.h"
#import "YXTrackPageDataProtocol.h"
#import "YXHomeworkInfoViewController.h"
@interface LSTTrainHelper_Beijing ()
{
    NSString *_requireId;
    NSString *_homeworkid;
}
@end
@implementation LSTTrainHelper_Beijing
#pragma mark - get
- (NSString *)workshopListTitle {
    return @"我的班级";
}
- (NSString *)workshopDetailTitle {
    return @"班级详情";
}
- (NSString *)workshopDetailName {
    return @"辅导教师";
}
- (NSString *)activityStageName {
    return  @"类别";
}
#pragma mark - show project
- (UIViewController<YXTrackPageDataProtocol> *)showExamProject {
    return [[NSClassFromString(@"BeijingExamViewController") alloc] init];
}
- (void)courseInterfaceSkip:(UIViewController *)viewController {
    UIViewController *VC = [[NSClassFromString(@"BeijingCourseViewController") alloc] init];
    [viewController.navigationController pushViewController:VC animated:YES];
    [super courseInterfaceSkip:viewController];
    [YXDataStatisticsManger trackEvent:@"课程列表" label:@"任务跳转" parameters:nil];

}
- (void)workshopInterfaceSkip:(UIViewController *)viewController {
    YXHomeworkInfoViewController *VC = [[YXHomeworkInfoViewController alloc] init];
    YXHomeworkInfoRequestItem_Body *itemBody = [[YXHomeworkInfoRequestItem_Body alloc] init];
    itemBody.type = @"4";
    itemBody.requireId = self.requireId;
    itemBody.homeworkid = self.homeworkid;
    itemBody.pid = [YXTrainManager sharedInstance].currentProject.pid;
    VC.itemBody = itemBody;
    [viewController.navigationController pushViewController:VC animated:YES];
}
- (void)activityInterfaceSkip:(UIViewController *)viewController {
    UIViewController *VC = [[NSClassFromString(@"BeijingActivityListViewController") alloc] init];
    [viewController.navigationController pushViewController:VC animated:YES];
}
@end
