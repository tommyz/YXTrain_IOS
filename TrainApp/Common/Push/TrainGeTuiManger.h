//
//  TrainGeTuiManger.h
//  TrainApp
//
//  Created by 郑小龙 on 2017/4/19.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainGeTuiManger : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void (^trainGeTuiMangerCompleteBlock)(void);

- (void)resume;
- (void)resetBadge;
- (void)registerGeTui;
- (void)loginSuccess;
- (void)logoutSuccess;
- (void)handleApnsContent:(NSDictionary *)dict isPush:(BOOL)isPush;
- (void)registerDeviceToken:(NSData *)deviceToken;
@end
