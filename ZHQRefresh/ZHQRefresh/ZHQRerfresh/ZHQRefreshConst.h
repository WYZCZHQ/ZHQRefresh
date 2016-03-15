//
//  ZHQRefreshConst.h
//  ZHQRefresh
//
//  Created by wyzc on 16/3/14.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 常量
//刷新视图的高度
UIKIT_EXTERN const CGFloat ZHQRefreshViewHeight;
//加载视图的高度
UIKIT_EXTERN const CGFloat ZHQLoadViewHeight;
//动画持续时间
UIKIT_EXTERN const CGFloat ZHQAnimationDuration;

//kvo监视属性变化的关键字
UIKIT_EXTERN NSString *const ZHQKeyPathContentOffset;
UIKIT_EXTERN NSString *const ZHQKeyPathContentSize;
UIKIT_EXTERN NSString *const ZHQKeyPathContentInset;
UIKIT_EXTERN NSString *const ZHQKeyPathPanState;

//刷新视图提示文本
UIKIT_EXTERN NSString *const ZHQRefreshViewIdleText;
UIKIT_EXTERN NSString *const ZHQRefreshViewPullingText;
UIKIT_EXTERN NSString *const ZHQRefreshViewfreshingText;

//加载视图提示文本
UIKIT_EXTERN NSString *const ZHQLoadViewIdleText;
UIKIT_EXTERN NSString *const ZHQLoadViewPullingText;
UIKIT_EXTERN NSString *const ZHQLoadViewLoadingText;
