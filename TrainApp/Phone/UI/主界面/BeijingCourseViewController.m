//
//  BeijingCourseViewController.m
//  TrainApp
//
//  Created by 郑小龙 on 16/12/2.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//
#import "YXCourseFilterView.h"
#import "BeijingCourseListFetcher.h"
#import "BeijingCourseListCell.h"
#import "YXCourseDetailViewController.h"
#import "YXCourseRecordViewController.h"
static  NSString *const trackPageName = @"课程列表页面";
#import "BeijingCourseViewController.h"

@interface BeijingCourseViewController ()<YXCourseFilterViewDelegate>
@property (nonatomic, strong) YXCourseFilterView *filterView;
@property (nonatomic, strong) YXCourseListFilterModel *filterModel;
@property (nonatomic, strong) BeijingCourseListRequest *request;
@property (nonatomic, assign) BOOL isWaitingForFilter;
@property (nonatomic, strong) YXErrorView *filterErrorView;
@property (nonatomic, assign) BOOL isNavBarHidden;
@property (nonatomic, assign) BOOL isRefreshStudys;
@property (nonatomic, assign) NSInteger lastChooseStudys;
@end

@implementation BeijingCourseViewController
- (void)dealloc{
    DDLogError(@"release====>%@",NSStringFromClass([self class]));
}
- (void)viewDidLoad {
    BeijingCourseListFetcher *fetcher = [[BeijingCourseListFetcher alloc]init];
    fetcher.pid = [YXTrainManager sharedInstance].currentProject.pid;
    fetcher.w = [YXTrainManager sharedInstance].currentProject.w;
    fetcher.stageid = self.stageID;
    WEAK_SELF
    fetcher.filterBlock = ^(YXCourseListFilterModel *model){
        STRONG_SELF
        self.filterModel = model;
        if (self.isRefreshStudys) {
            [self refreshDealWithFilterModel:self.filterModel];
        }else {
            if (self.filterView) {
                return;
            }
            [self dealWithFilterModel:self.filterModel];
        }
    };
    self.dataFetcher = fetcher;
    self.bIsGroupedTableViewStyle = YES;
    
    YXEmptyView *emptyView = [[YXEmptyView alloc]init];
    emptyView.title = @"没有符合条件的课程";
    emptyView.imageName = @"没有符合条件的课程";
    self.emptyView = emptyView;
    
    self.isWaitingForFilter = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"课程列表";
    [self setupRightWithTitle:@"看课记录"];
    [self setupObservers];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 104.0f;
    [self.tableView registerClass:[BeijingCourseListCell class] forCellReuseIdentifier:@"BeijingCourseListCell"];
    
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    if (self.isWaitingForFilter) {
        self.filterErrorView = [[YXErrorView alloc]initWithFrame:self.view.bounds];
        WEAK_SELF
        self.filterErrorView.retryBlock = ^{
            STRONG_SELF
            [self getFilters];
        };
        [self getFilters];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [YXDataStatisticsManger trackPage:trackPageName withStatus:YES];
    if (self.isNavBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [YXDataStatisticsManger trackPage:trackPageName withStatus:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableViewWillRefresh{
    CGFloat top = 0.f;
    if (self.filterView) {
        top = 44.f;
    }
    [self.errorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)getFilters{
    [self.request stopRequest];
    self.request = [[BeijingCourseListRequest alloc] init];
    self.request.pid = [YXTrainManager sharedInstance].currentProject.pid;
    self.request.pageno = @"1";
    self.request.pagesize = @"10";
    self.request.type = @"102";
    self.request.w = [YXTrainManager sharedInstance].currentProject.w;
    [self startLoading];
    WEAK_SELF
    [self.request startRequestWithRetClass:[YXCourseListRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self stopLoading];
        if (error) {
            self.filterErrorView.frame = self.view.bounds;
            [self.view addSubview:self.filterErrorView];
            return;
        }
        [self.filterErrorView removeFromSuperview];
        
        YXCourseListRequestItem *item = (YXCourseListRequestItem *)retItem;
        self.filterModel = [item beijingFilterModel];
        self.isWaitingForFilter = NO;
        BeijingCourseListFetcher *fetcher = (BeijingCourseListFetcher *)self.dataFetcher;
        fetcher.segid = [self firstRequestParameter:self.filterModel.groupArray.firstObject];
        fetcher.stageid = [self firstRequestParameter:self.filterModel.groupArray.lastObject];
        fetcher.studyid = @"0";
        [self firstPageFetch:YES];
    }];
}
- (NSString *)firstRequestParameter:(YXCourseFilterGroup *)stageGroup {
    YXCourseFilter *filter = stageGroup.filterArray.firstObject;
    return filter.filterID;
}
- (void)firstPageFetch:(BOOL)isShow{
    if (self.isWaitingForFilter) {
        return;
    }
    [super firstPageFetch:isShow];
}

- (void)dealWithFilterModel:(YXCourseListFilterModel *)model{
    YXCourseFilterView *filterView = [[YXCourseFilterView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.filterView = filterView;
    for (YXCourseFilterGroup *group in model.groupArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (YXCourseFilter *filter in group.filterArray) {
            [array addObject:filter.name];
        }
        [filterView addFilters:array forKey:group.name];
    }
    [self setupWithCurrentFilters];
    filterView.delegate = self;
    [self.view addSubview:filterView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(44);
    }];
}
- (void)refreshDealWithFilterModel:(YXCourseListFilterModel *)model {
    for (YXCourseFilterGroup *group in model.groupArray) {
        if ([group.name isEqualToString:@"学科"]) {
            NSMutableArray *array = [NSMutableArray array];
            for (YXCourseFilter *filter in group.filterArray) {
                [array addObject:filter.name];
            }
            [self.filterView refreshStudysFilters:array forKey:group.name];
        }
    }
}



- (void)setupWithCurrentFilters{
    if (self.stageID) {
        YXCourseFilterGroup *stageGroup = self.filterModel.groupArray.lastObject;
        __block NSInteger stageIndex = -1;
        [stageGroup.filterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXCourseFilter *filter = (YXCourseFilter *)obj;
            if ([self.stageID isEqualToString:filter.filterID]) {
                stageIndex = idx;
                *stop = YES;
            }
        }];
        if (stageIndex >= 0) {
            [self.filterView setCurrentIndex:stageIndex forKey:stageGroup.name];
        }
    }
}

- (void)setupObservers{
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kRecordReportSuccessNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        NSString *course_id = noti.userInfo.allKeys.firstObject;
        NSString *record = noti.userInfo[course_id];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXCourseListRequestItem_body_module_course *course = (YXCourseListRequestItem_body_module_course *)obj;
            if ([course.courses_id isEqualToString:course_id]) {
                course.record = record;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                *stop = YES;
            }
        }];
    }];
}

- (void)naviRightAction{
    YXCourseRecordViewController *vc = [[YXCourseRecordViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BeijingCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeijingCourseListCell"];
    cell.course = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"BeijingCourseListCell" configuration:^(BeijingCourseListCell *cell) {
        cell.course = self.dataArray[indexPath.row];
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YXCourseListRequestItem_body_module_course *course = self.dataArray[indexPath.row];
    YXCourseDetailViewController *vc = [[YXCourseDetailViewController alloc]init];
    vc.course = course;
    vc.isFromRecord = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - YXCourseFilterViewDelegate
- (void)filterChanged:(NSArray *)filterArray{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    // 学段
    NSNumber *num0 = filterArray[0];
    YXCourseFilterGroup *group0 = self.filterModel.groupArray[0];
    YXCourseFilter *segmentItem = group0.filterArray[num0.integerValue];
    if (self.lastChooseStudys != num0.integerValue) {
        self.isRefreshStudys = YES;
    }else {
        self.isRefreshStudys = NO;
    }
    self.lastChooseStudys = num0.integerValue;
    
    // 学科
    NSNumber *num1 = filterArray[1];
    YXCourseFilterGroup *group1 = self.filterModel.groupArray[1];
    YXCourseFilter *studyItem = group1.filterArray[num1.integerValue];
    // 阶段
    NSNumber *num2 = filterArray[2];
    YXCourseFilterGroup *group2 = self.filterModel.groupArray[2];
    YXCourseFilter *stageItem = group2.filterArray[num2.integerValue];
    BeijingCourseListFetcher *fetcher = (BeijingCourseListFetcher *)self.dataFetcher;
    fetcher.studyid = studyItem.filterID;
    if (self.isRefreshStudys) {
       fetcher.studyid = @"0";
    }
    fetcher.segid = segmentItem.filterID;
    fetcher.stageid = stageItem.filterID;
    [self firstPageFetch:YES];
}
#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height >= kScreenHeight -  44 + 10.0f){
        CGPoint point = scrollView.contentOffset;
        if (point.y >= 21 && !self.isNavBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.filterView.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
            [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(64);
            }];
            DDLogDebug(@"隐藏");
            self.isNavBarHidden = YES;
        }else if (point.y < 5 && self.isNavBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.filterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
            [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(44);
            }];
            DDLogDebug(@"显示");
            self.isNavBarHidden = NO;
        }
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.filterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(44);
        }];
        self.isNavBarHidden = NO;
    }
}

@end
