//
//  WebsocketRedRightView.m
//  TrainApp
//
//  Created by 郑小龙 on 17/1/3.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "WebsocketRedRightView.h"

@implementation WebsocketRedRightView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInterface];
    }
    return self;
}
#pragma mark - setup
- (void)setupInterface {
    [self.button setImage:[UIImage imageNamed:@"消息动态icon-正常态A"] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"消息动态icon点击态-正常态-拷贝"] forState:UIControlStateHighlighted];
    self.button.frame = CGRectMake(0, 0, 32.0f, 32.0f);
    self.pointView.frame = CGRectMake(27.0f, 5.0f, 5.0f, 5.0f);
}
- (void)webSocketReceiveMessage:(NSNotification *)aNotification{
    NSInteger integer = [aNotification.object integerValue];
    if (integer == 3) {
      self.pointView.hidden = NO;
    }
}
@end
