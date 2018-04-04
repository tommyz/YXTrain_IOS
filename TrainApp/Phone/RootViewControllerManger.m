//
//  RootViewControllerManger.m
//  TrainApp
//
//  Created by 郑小龙 on 2017/11/14.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "RootViewControllerManger.h"
#import "RootViewControllerManger_16.h"
#import "RootViewControllerManger_17.h"
#import "YXNavigationController.h"
#import "YXTabBarViewController_17.h"
#import "YXDrawerViewController.h"
#import "YXWebViewController.h"
#import "NoticeAndBriefDetailViewController.h"
#import "YXHomeworkInfoViewController.h"
#import "MasterHomeworkViewController_17.h"
#import "MasterHomeworkSetListViewController_17.h"
#import "MasterTabBarViewController_17.h"
@implementation RootViewControllerManger
+ (instancetype)alloc{
    if ([self class] == [RootViewControllerManger class]) {
        if ([LSTSharedInstance sharedInstance].trainManager.trainStatus == LSTTrainProjectStatus_2016) {
           return [RootViewControllerManger_16 alloc];
        }else {
           return [RootViewControllerManger_17 alloc];
        }
    }
    return [super alloc];
}
- (void)showDynamicViewController:(UIWindow *)window {
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel == nil) {
        return;
    }
    YXNavigationController *projectNavi = nil;
    if ([LSTSharedInstance sharedInstance].trainManager.trainStatus == LSTTrainProjectStatus_2016) {
        if ([window.rootViewController isKindOfClass:[YXDrawerViewController class]]) {
            YXDrawerViewController *drawerVC  = (YXDrawerViewController *)window.rootViewController;
            if (drawerVC.paneViewController.presentedViewController) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYXTrainPushNotification object:nil];
            }
            projectNavi = (YXNavigationController *)drawerVC.paneViewController;
        }else {
            return;
        }

    }else if ([LSTSharedInstance sharedInstance].trainManager.trainStatus == LSTTrainProjectStatus_2017 && [LSTSharedInstance sharedInstance].trainManager.currentProject.role.integerValue == 9) {
        if ([window.rootViewController isKindOfClass:[YXTabBarViewController_17 class]]) {
            YXTabBarViewController_17 *tabVC  = (YXTabBarViewController_17 *)window.rootViewController;
            if (tabVC.selectedViewController.presentedViewController) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYXTrainPushNotification object:nil];
            }
            projectNavi = (YXNavigationController *)tabVC.selectedViewController;
        }else {
            return;
        }
    }else if ([LSTSharedInstance sharedInstance].trainManager.trainStatus == LSTTrainProjectStatus_2017 && [LSTSharedInstance sharedInstance].trainManager.currentProject.role.integerValue == 99){
        if ([window.rootViewController isKindOfClass:[MasterTabBarViewController_17 class]]) {
            MasterTabBarViewController_17 *tabVC  = (MasterTabBarViewController_17 *)window.rootViewController;
            if (tabVC.selectedViewController.presentedViewController) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYXTrainPushNotification object:nil];
            }
            projectNavi = (YXNavigationController *)tabVC.selectedViewController;
        }else {
            return;
        }
    }
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.extendInfo.baseUrl.length > 0){
        if ([projectNavi.viewControllers.lastObject isKindOfClass:[NSClassFromString(@"YXWebViewController") class]]){
            return ;
        }
        YXWebViewController *webView = [[YXWebViewController alloc] init];
        webView.urlString = [NSString stringWithFormat:@"%@/%@",[LSTSharedInstance sharedInstance].geTuiManger.pushModel.extendInfo.baseUrl,[LSTSharedInstance sharedInstance].userManger.userModel.uid];
        webView.titleString =  [LSTSharedInstance sharedInstance].geTuiManger.pushModel.title;
        webView.isUpdatTitle = YES;
        [projectNavi pushViewController:webView animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        [YXDataStatisticsManger trackPage:@"元旦贺卡" withStatus:YES];
        WEAK_SELF
        [webView setBackBlock:^{
            STRONG_SELF
            [YXDataStatisticsManger trackPage:@"元旦贺卡" withStatus:NO];
        }];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 1) {
        NoticeAndBriefDetailViewController *VC = [[NoticeAndBriefDetailViewController alloc] init];
        VC.nbIdString = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.objectId;
        VC.titleString = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.title;
        VC.detailFlag =  NoticeAndBriefFlag_Notice;
        WEAK_SELF
        VC.requestSuccessBlock = ^{
            STRONG_SELF
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
            [LSTSharedInstance sharedInstance].redPointManger.dynamicInteger = [UIApplication sharedApplication].applicationIconBadgeNumber;
        };
        [projectNavi pushViewController:VC animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 2) {
        NoticeAndBriefDetailViewController *VC = [[NoticeAndBriefDetailViewController alloc] init];
        VC.nbIdString = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.objectId;
        VC.titleString = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.title;
        VC.detailFlag = NoticeAndBriefFlag_Brief;
        WEAK_SELF
        VC.requestSuccessBlock = ^{
            STRONG_SELF
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
            [LSTSharedInstance sharedInstance].redPointManger.dynamicInteger = [UIApplication sharedApplication].applicationIconBadgeNumber;
        };
        [projectNavi pushViewController:VC animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 3 || [LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 4) {
        YXHomeworkInfoRequestItem_Body *itemBody = [[YXHomeworkInfoRequestItem_Body alloc] init];
        itemBody.type = @"4";
        itemBody.requireId = @"";
        itemBody.homeworkid = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.objectId;
        itemBody.title = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.title;
        itemBody.pid = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.projectId;
        YXHomeworkInfoViewController *VC = [[YXHomeworkInfoViewController alloc] init];
        VC.itemBody = itemBody;
        WEAK_SELF
        VC.requestSuccessBlock = ^{
            STRONG_SELF
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
            [LSTSharedInstance sharedInstance].redPointManger.dynamicInteger = [UIApplication sharedApplication].applicationIconBadgeNumber;
        };
        [projectNavi pushViewController:VC animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 34) {
        MasterHomeworkViewController_17 *VC = [[MasterHomeworkViewController_17 alloc] init];
        VC.pid = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.projectId;
        WEAK_SELF
        VC.requestSuccessBlock = ^{
            STRONG_SELF
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
            [LSTSharedInstance sharedInstance].redPointManger.dynamicInteger = [UIApplication sharedApplication].applicationIconBadgeNumber;
        };
        [projectNavi pushViewController:VC animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    if ([LSTSharedInstance sharedInstance].geTuiManger.pushModel.type.integerValue == 35) {
        MasterHomeworkSetListViewController_17 *VC = [[MasterHomeworkSetListViewController_17 alloc] init];
        VC.pid = [LSTSharedInstance sharedInstance].geTuiManger.pushModel.projectId;
        WEAK_SELF
        VC.requestSuccessBlock = ^{
            STRONG_SELF
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
            [LSTSharedInstance sharedInstance].redPointManger.dynamicInteger = [UIApplication sharedApplication].applicationIconBadgeNumber;
        };
        [projectNavi pushViewController:VC animated:YES];
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return;
    }
    if ([projectNavi.viewControllers.lastObject isKindOfClass:[NSClassFromString(@"YXDynamicViewController") class]]){
        [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
        return ;
    }
    UIViewController *VC = [[NSClassFromString(@"YXDynamicViewController") alloc] init];
    [projectNavi pushViewController:VC animated:YES];
    [LSTSharedInstance sharedInstance].geTuiManger.pushModel = nil;
}
- (UIViewController *)rootViewController {
    return nil;
}
@end
