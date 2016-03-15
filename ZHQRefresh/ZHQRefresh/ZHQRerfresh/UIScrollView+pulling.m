//
//  UIScrollView+pulling.m
//  下拉
//
//  Created by wyzc on 16/1/11.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "UIScrollView+pulling.h"
static BOOL isDragging=NO;//yes拖拽中
static UIEdgeInsets edgeInsets={0,0,0,0};//停靠位置
static UIView * refreshView=nil;//刷新视图
static UIView * loadView=nil;//加载视图
static UILabel * msgLabel=nil,* loadLabel=nil;//提示文本标签
static UIImageView * arrowImageView=nil,* loadArrow=nil;//箭头
static UIActivityIndicatorView * activityIndicatorView=nil,* loadActivityIndicatorView=nil;//指示器
static id refreshTarget=nil,loadTarget=nil;//目标对象
static SEL refreshAction,loadAction;//行为
static UIImage * upImage=nil;//刷新视图上的图片
static UIImage * downImage=nil;//加载视图上的图片

@implementation UIScrollView (pulling)
-(void)buildView
{
    if(refreshView==nil)
    {
        //上边刷新视图
        refreshView=[[UIView alloc]initWithFrame:CGRectMake(0, -ZHQRefreshViewHeight,self.frame.size.width, ZHQRefreshViewHeight)];
        //宽度自动适配
        refreshView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        //可以设定它的背景颜色
        refreshView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        //提示文本
        msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, ZHQRefreshViewHeight)];
        msgLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        msgLabel.text=ZHQRefreshViewIdleText;
        msgLabel.textAlignment=NSTextAlignmentCenter;
        [refreshView addSubview:msgLabel];
        //箭头
        arrowImageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, (ZHQRefreshViewHeight-40)/2, 40, 40)];
        upImage=[UIImage imageNamed:@"arrow.png"];
        arrowImageView.image=upImage;
        downImage=[UIImage imageWithCGImage:arrowImageView.image.CGImage scale:1.0 orientation:UIImageOrientationDown];
        [refreshView addSubview:arrowImageView];
        //指示器
        activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, (ZHQRefreshViewHeight-40)/2, 40, 40)];
        activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        [refreshView addSubview:activityIndicatorView];
        [self addSubview:refreshView];
        
        //下边加载视图
        loadView=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height,self.frame.size.width, ZHQLoadViewHeight)];
        //宽度自动适配
        loadView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        //可以设定它的背景颜色
        loadView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        //提示文本
        loadLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, ZHQLoadViewHeight)];
        loadLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        loadLabel.text=ZHQLoadViewIdleText;
        loadLabel.textAlignment=NSTextAlignmentCenter;
        [loadView addSubview:loadLabel];
        //箭头
        loadArrow=[[UIImageView alloc]initWithFrame:CGRectMake(50, (ZHQLoadViewHeight-40)/2, 40, 40)];
        loadArrow.image=downImage;
        [loadView addSubview:loadArrow];
        //指示器
        loadActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, (ZHQLoadViewHeight-40)/2, 40, 40)];
        loadActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        [loadView addSubview:loadActivityIndicatorView];
        [self addSubview:loadView];
        
        [self addObserver:self forKeyPath:ZHQKeyPathContentOffset options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.panGestureRecognizer addObserver:self forKeyPath:ZHQKeyPathPanState options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dictChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}
-(void)loadWithTarget:(id)_target andWithAction:(SEL)_action
{
    loadTarget=_target;
    loadAction=_action;
    [self buildView];
}
-(void)refreshWithTarget:(id)_target andWithAction:(SEL)_action
{
    refreshTarget=_target;
    refreshAction=_action;
    [self buildView];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])//滚动中
    {
        if(isDragging)
        {
            if(self.contentOffset.y<-edgeInsets.top)//下拉
            {
                if(self.contentOffset.y<-ZHQRefreshViewHeight-edgeInsets.top)//拉到超过刷新视图了
                {
                    msgLabel.text=ZHQRefreshViewPullingText;
                    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
                        arrowImageView.transform=CGAffineTransformMakeRotation(180*M_PI/180);
                    }];
                }
                else
                {
                    msgLabel.text=ZHQRefreshViewIdleText;
                    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
                        arrowImageView.transform=CGAffineTransformIdentity;
                    }];
                }
            }
            else//上拉
            {
                if (self.contentOffset.y+self.frame.size.height>self.contentSize.height)
                {
                    //内容超过屏幕
                    if(self.contentSize.height>self.frame.size.height)
                    {
                        if(self.contentOffset.y+self.frame.size.height>self.contentSize.height+ZHQLoadViewHeight+edgeInsets.bottom)
                        {
                            [self willPullUp];
                        }
                        else
                        {
                            [self resetPullUp];
                        }
                    }
                    else
                    {
                        if(self.contentOffset.y>ZHQLoadViewHeight-edgeInsets.top)
                        {
                            [self willPullUp];
                        }
                        else
                        {
                            [self resetPullUp];
                        }
                    }
                }
            }
        }
    }
    else if([keyPath isEqualToString:@"state"])//状态有变化
    {
        if(self.panGestureRecognizer.state==UIGestureRecognizerStateBegan)//拖拽开始
        {
            isDragging=YES;//改标记
            edgeInsets=self.contentInset;//记住停靠位置
            if(self.contentSize.height+edgeInsets.top+edgeInsets.bottom<self.frame.size.height)//内容没有超过屏幕
            {
                loadView.frame=CGRectMake(0, self.frame.size.height-edgeInsets.top-edgeInsets.bottom, self.frame.size.width, ZHQLoadViewHeight);
            }
            else
            {
                loadView.frame=CGRectMake(0, self.contentSize.height, self.frame.size.width, ZHQLoadViewHeight);
            }
        }
        else if(self.panGestureRecognizer.state==UIGestureRecognizerStateEnded)//拖拽结束，松手了
        {
            if(self.contentOffset.y<-ZHQRefreshViewHeight-edgeInsets.top)
            {
                isDragging=NO;
                //封锁表视图
                self.userInteractionEnabled=NO;
                //隐藏箭头
                arrowImageView.hidden=YES;
                //显示指示器
                [activityIndicatorView startAnimating];
                //提示正在刷新
                msgLabel.text=ZHQRefreshViewfreshingText;
                //停靠
                self.contentInset=UIEdgeInsetsMake(ZHQRefreshViewHeight+edgeInsets.top, 0, 0, 0);
                //调用刷新行为
                [refreshTarget performSelector:refreshAction withObject:nil afterDelay:0.0];
            }
            else if(self.contentOffset.y+self.frame.size.height>self.contentSize.height+ZHQLoadViewHeight+edgeInsets.bottom)
            {
                if(self.contentSize.height>self.frame.size.height)
                {
                    //封锁表视图
                    self.userInteractionEnabled=NO;
                    isDragging=NO;
                    //隐藏箭头
                    loadArrow.hidden=YES;
                    //显示指示器
                    [loadActivityIndicatorView startAnimating];
                    //提示正在刷新
                    loadLabel.text=ZHQLoadViewLoadingText;
                    //停靠
                    self.contentInset=UIEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom+ZHQLoadViewHeight, edgeInsets.right);
                    //调用刷新行为
                    [loadTarget performSelector:loadAction withObject:nil afterDelay:0.0];
                }
                else
                {
                    if (self.contentOffset.y>ZHQLoadViewHeight-edgeInsets.top)
                    {
                        //封锁表视图
                        self.userInteractionEnabled=NO;
                        //封锁表视图
                        self.userInteractionEnabled=NO;
                        isDragging=NO;
                        //隐藏箭头
                        loadArrow.hidden=YES;
                        //显示指示器
                        [loadActivityIndicatorView startAnimating];
                        //提示正在刷新
                        loadLabel.text=ZHQLoadViewLoadingText;
                        //停靠
                        self.contentInset=UIEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom+ZHQLoadViewHeight, edgeInsets.right);
                        self.contentInset=UIEdgeInsetsMake(edgeInsets.top-ZHQLoadViewHeight, edgeInsets.left, edgeInsets.bottom+ZHQLoadViewHeight, edgeInsets.right);
                        //调用刷新行为
                        [loadTarget performSelector:loadAction withObject:nil afterDelay:0.0];
                    }
                }
            }
        }
    }
}
-(void)willPullUp
{
    loadLabel.text=ZHQLoadViewPullingText;
    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
        loadArrow.transform=CGAffineTransformMakeRotation(180*M_PI/180);
    }];
}
-(void)resetPullUp
{
    loadLabel.text=ZHQLoadViewIdleText;
    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
        loadArrow.transform=CGAffineTransformIdentity;
    }];
}
-(void)endRefreshing
{
    //停靠
    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
        self.contentInset=edgeInsets;
    }];
    self.userInteractionEnabled=YES;
    //隐藏指示器
    [activityIndicatorView stopAnimating];
    //显示箭头
    arrowImageView.transform=CGAffineTransformIdentity;
    arrowImageView.hidden=NO;
    //提示
    msgLabel.text=ZHQRefreshViewIdleText;
}
-(void)endLoading
{
    //停靠
    [UIView animateWithDuration:ZHQAnimationDuration animations:^{
        self.contentInset=edgeInsets;
    }];
    self.userInteractionEnabled=YES;
    //隐藏指示器
    [loadActivityIndicatorView stopAnimating];
    //显示箭头
    loadArrow.transform=CGAffineTransformIdentity;
    loadArrow.hidden=NO;
    //提示
    loadLabel.text=ZHQLoadViewIdleText;
}

-(void)dictChange
{
    refreshView.frame=CGRectMake(0, -ZHQRefreshViewHeight, self.frame.size.width, ZHQRefreshViewHeight);
    loadView.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, ZHQLoadViewHeight);
    if(self.contentSize.height>self.frame.size.height)
    {
        loadView.frame=CGRectMake(0, self.contentSize.height, self.frame.size.width, ZHQLoadViewHeight);
    }
}
@end
