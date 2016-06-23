//
//  YXProjectContainerView.m
//  TrainApp
//
//  Created by niuzhaowang on 16/6/17.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXProjectContainerView.h"

static const NSUInteger kTagBase = 3333;

@interface YXProjectContainerView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@end

@implementation YXProjectContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    [self addSubview:self.topView];
    
    self.bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.topView.frame.origin.y+self.topView.frame.size.height, self.frame.size.width, self.frame.size.height-self.topView.frame.size.height)];
    self.bottomScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.bottomScrollView.pagingEnabled = YES;
    self.bottomScrollView.showsHorizontalScrollIndicator = NO;
    self.bottomScrollView.showsVerticalScrollIndicator = NO;
    self.bottomScrollView.directionalLockEnabled = YES;
    self.bottomScrollView.bounces = NO;
    self.bottomScrollView.delegate = self;
    [self addSubview:self.bottomScrollView];
    
    self.sliderView = [[UIView alloc]init];
    self.sliderView.backgroundColor = [UIColor colorWithHexString:@"0070c9"];
    self.sliderView.frame = CGRectMake(0, 0, 64, 2);
}

- (void)setViewControllers:(NSArray *)viewControllers{
    _viewControllers = viewControllers;
    // clear old views first
    for (UIView *v in self.topView.subviews) {
        [v removeFromSuperview];
    }
    for (UIView *v in self.bottomScrollView.subviews) {
        [v removeFromSuperview];
    }
    [self.sliderView removeFromSuperview];
    
    // set new views
    [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // bottom
        UIViewController *vc = (UIViewController *)obj;
        vc.view.frame = CGRectMake(self.bottomScrollView.frame.size.width*idx, 0, self.bottomScrollView.frame.size.width, self.bottomScrollView.frame.size.height);
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.bottomScrollView addSubview:vc.view];
        // top
        UIButton *b = [self buttonWithTitle:vc.title image:[UIImage yx_imageWithColor:[UIColor redColor] rect:CGRectMake(0, 0, 15, 15)]];
        CGFloat btnWidth = self.topView.frame.size.width/viewControllers.count;
        b.frame = CGRectMake(btnWidth*idx, 0, btnWidth, self.topView.frame.size.height);
        b.tag = kTagBase + idx;
        [self.topView addSubview:b];
        if (idx == 0) {
            b.selected = YES;
        }
    }];
    self.sliderView.center = CGPointMake(self.topView.frame.size.width/4/2, self.topView.frame.size.height-1);
    [self addSubview:self.sliderView];
}

- (UIButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image{
    UIButton *b = [[UIButton alloc]init];
    [b setTitle:title forState:UIControlStateNormal];
    [b setImage:image forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithHexString:@"bbc2c9"] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithHexString:@"0067be"] forState:UIControlStateSelected];
    b.titleLabel.font = [UIFont systemFontOfSize:13];
    b.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    b.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);
    [b addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)layoutSubviews{
    self.bottomScrollView.contentSize = CGSizeMake(self.bottomScrollView.frame.size.width*self.viewControllers.count, self.bottomScrollView.frame.size.height);
}

- (void)btnAction:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *b in self.topView.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            b.selected = NO;
        }
    }
    sender.selected = YES;
    NSInteger index = sender.tag - kTagBase;
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderView.center = CGPointMake(self.topView.frame.size.width/4/2*(1+index*2), self.sliderView.center.y);
    }];

    self.bottomScrollView.contentOffset = CGPointMake(self.bottomScrollView.frame.size.width*index, 0);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat sliderX = offsetX/scrollView.contentSize.width*self.topView.frame.size.width;
    self.sliderView.center = CGPointMake(self.topView.frame.size.width/4/2+sliderX, self.sliderView.center.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    for (UIButton *b in self.topView.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            b.selected = NO;
            if (b.tag-kTagBase == index) {
                b.selected = YES;
            }
        }
    }
}

@end
