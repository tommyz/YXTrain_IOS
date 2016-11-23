//
//  DownloadResourceViewController.m
//  TrainApp
//
//  Created by ZLL on 2016/11/22.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "DownloadResourceViewController.h"
#import "ActivityListRequest.h"
#import "ResourceMessageView.h"
#import "DownloadResourceRequest.h"
@interface DownloadResourceViewController ()
@property (nonatomic, strong) DownloadResourceRequestItem *requestItem;
@property (nonatomic, strong) DownloadResourceRequest *request;
@property (nonatomic, strong) YXDatumCellModel *dataModel;
@property (nonatomic, strong) ResourceMessageView *resourceMessageView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation DownloadResourceViewController

- (void)viewDidLoad {
    YXEmptyView *emptyView = [[YXEmptyView alloc]init];
    emptyView.imageName = @"暂无资源";
    emptyView.title = @"没有符合条件的资源";
    self.emptyView = emptyView;
    
    [super viewDidLoad];
    self.title = @"资源下载";
    self.dataModel = [self cachedItem];
    [self setupUI];
    [self requestResource];
}
- (void)setupUI {
    WEAK_SELF
    self.errorView = [[YXErrorView alloc]initWithFrame:self.view.bounds];
    self.errorView.retryBlock = ^{
        STRONG_SELF
        [self requestResource];
    };
    self.emptyView = [[YXEmptyView alloc]initWithFrame:self.view.bounds];
    self.dataErrorView = [[DataErrorView alloc]initWithFrame:self.view.bounds];
    self.dataErrorView.refreshBlock = ^{
        STRONG_SELF
        [self requestResource];
    };
    self.view.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    self.resourceMessageView = [[ResourceMessageView alloc]initWithFrame:CGRectMake((kScreenWidth - kScreenWidthScale(345.0f)) *  0.5,(kScreenHeight - 144 - 201) * 0.5,kScreenWidthScale(345.0f), 201)];
    [self.view addSubview:self.resourceMessageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.resourceMessageView addGestureRecognizer:tapGesture];
    if (self.dataModel) {
        self.resourceMessageView.data = self.dataModel;
    }
    [self setupBottomView];
}
- (void)setupBottomView {
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor colorWithHexString:@"f2f4f7"];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor colorWithHexString:@"d0d2d5"];
    [self.bottomView addSubview:lineView];
    
    UIButton *viewCommentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    viewCommentsButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [viewCommentsButton setTitle:@"查看评论" forState:UIControlStateNormal];
    [viewCommentsButton setTitleColor:[UIColor colorWithHexString:@"0067be"] forState:UIControlStateNormal];
    viewCommentsButton.layer.cornerRadius = 2.0f;
    viewCommentsButton.layer.borderColor = [UIColor colorWithHexString:@"0070c9"].CGColor;
    viewCommentsButton.layer.borderWidth = 1;
    viewCommentsButton.layer.masksToBounds = YES;
    [viewCommentsButton addTarget:self action:@selector(viewCommentsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewCommentsButton addTarget:self action:@selector(changeViewCommentsButtonAction:) forControlEvents:UIControlEventTouchDown];
    [self.bottomView addSubview:viewCommentsButton];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.bottomView);
        make.height.mas_equalTo(1/[UIScreen mainScreen].scale);
    }];
    [viewCommentsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.size.mas_equalTo(CGSizeMake(170, 32));
    }];
}
- (void)requestResource {
    [self.request stopRequest];
    [self startLoading];
    self.request = [[DownloadResourceRequest alloc] init];
    self.request.aid = self.tool.aid;
    self.request.toolId = self.tool.toolid;
    self.request.w = [YXTrainManager sharedInstance].currentProject.w;
    WEAK_SELF
    [self.request startRequestWithRetClass:[DownloadResourceRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self stopLoading];
        if (error) {
            if (error.code == -2) {
                self.dataErrorView.frame = self.view.bounds;
                [self.view addSubview:self.dataErrorView];
            }
            else{
                self.errorView.frame = self.view.bounds;
                [self.view addSubview:self.errorView];
            }
            return;
        }
        if (!retItem) {
            self.emptyView.frame = self.view.bounds;
            [self.view addSubview:self.emptyView];
            return;
        }
        [self.errorView removeFromSuperview];
        [self.emptyView removeFromSuperview];
        [self.dataErrorView removeFromSuperview];
        DownloadResourceRequestItem *item = retItem;
        self.requestItem = item;
        [self saveToCache];
        YXDatumCellModel *model = [YXDatumCellModel modelFromDownloadResourceRequestItemBodyResource:item.body.resource];
        self.dataModel = model;
        self.resourceMessageView.data = self.dataModel;
    }];
}
#pragma mark - CommentsButtonAction
- (void)viewCommentsButtonAction:(UIButton *)sender {
    sender.backgroundColor = [UIColor clearColor];
    [sender setTitleColor:[UIColor colorWithHexString:@"0067be"] forState:UIControlStateNormal];
    [self goToViewComments:self.tool];
    
}
- (void)goToViewComments:(ActivityListRequestItem_Body_Activity_Steps_Tools *)tool {
    DDLogDebug(@"查看评论");
}
- (void)changeViewCommentsButtonAction:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHexString:@"0070c9"];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
#pragma mark - tapGesture
-(void)tapGesture:(UITapGestureRecognizer *)sender {
    YXFileVideoItem *item = [[YXFileVideoItem alloc]init];
    item.name = self.dataModel.title;
    item.url = self.dataModel.previewUrl;
    item.type = [YXAttachmentTypeHelper fileTypeWithTypeName:self.dataModel.type];
    if(item.type == YXFileTypeUnknown) {
        [self showToast:@"暂不支持该格式文件预览"];
        return;
    }
    if (!self.dataModel.isFavor) {
        [[YXFileBrowseManager sharedManager]addFavorWithData:self.dataModel completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YXFavorSuccessNotification object:self.dataModel userInfo:nil];
            [self reloadData];
        }];
    }
    [YXFileBrowseManager sharedManager].fileItem = item;
    [YXFileBrowseManager sharedManager].baseViewController = self;
    [[YXFileBrowseManager sharedManager] browseFile];
}
- (void)reloadData {
    self.resourceMessageView.data = self.dataModel;
}
#pragma mark - Cache
- (void)saveToCache {
    NSString *cachedJson = [self.requestItem toJSONString];
    NSString *cashedSign = [NSString stringWithFormat:@"%@%@",self.request.aid,self.request.toolId];
    NSDictionary *dict = @{cashedSign:cachedJson};
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"资源下载 cache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (YXDatumCellModel *)cachedItem {
    NSString *cashedSign = [NSString stringWithFormat:@"%@%@",self.tool.aid,self.tool.toolid];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"资源下载 cache"];
    NSString *cachedJson = dict[cashedSign];
    DownloadResourceRequestItem *item = [[DownloadResourceRequestItem alloc] initWithString:cachedJson error:nil];
    if (!item) {
        return nil;
    }
    self.requestItem = item;
    YXDatumCellModel *model = [YXDatumCellModel modelFromDownloadResourceRequestItemBodyResource:item.body.resource];
    return model;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
