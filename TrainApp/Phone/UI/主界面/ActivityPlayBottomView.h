//
//  ActivityPlayBottomView.h
//  TrainApp
//
//  Created by 郑小龙 on 16/11/7.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivitySlideProgressView.h"
@interface ActivityPlayBottomView : UIView
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) ActivitySlideProgressView *slideProgressView;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, assign) BOOL isFullscreen;

@end
