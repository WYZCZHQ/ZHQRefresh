//
//  UIScrollView+pulling.h
//  下拉
//
//  Created by wyzc on 16/1/11.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (pulling)
-(void)refreshWithTarget:(id)_target andWithAction:(SEL)_action;
-(void)loadWithTarget:(id)_target andWithAction:(SEL)_action;
-(void)endRefreshing;
-(void)endLoading;
@end
