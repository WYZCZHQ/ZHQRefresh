//
//  UIScrollView+pulling.m
//  下拉
//
//  Created by wyzc on 16/1/11.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "UIScrollView+pulling.h"
static BOOL isDragging=NO;
#define VIEWHEIGHT 60//刷新视图的高度
static UIEdgeInsets edgeInsets={0,0,0,0};//表视图边界

static UIView * refreshView=nil;
static UILabel * msgLabel=nil;//提示文本标签
static UIImageView * arrowImageView=nil;//箭头
static UIActivityIndicatorView * activityIndicatorView=nil;//指示器

static UIView * loadView=nil;
static UILabel * loadLabel=nil;//提示文本标签
static UIImageView * loadArrow=nil;//箭头
static UIActivityIndicatorView * loadActivityIndicatorView=nil;//指示器

static id refreshTarget=nil;
static SEL refreshAction=nil;
static id loadTarget=nil;
static SEL loadAction=nil;
static NSString * pullDownBeginText=@"下拉可以刷新";
static NSString * pullDownWillText=@"释放立即刷新";
static NSString * pullDownRefreshingText=@"正在刷新...";
static NSString * pullUpBeginText=@"上拉可以加载更多";
static NSString * pullUpWillText=@"释放立即加载";
static NSString * pullUpLoadingText=@"正在加载...";

static UIImage * upImage=nil;
static UIImage * downImage=nil;
@implementation UIScrollView (pulling)
-(void)headView
{
    if(refreshView==nil)
    {
        //上边刷新视图
        refreshView=[[UIView alloc]initWithFrame:CGRectMake(0, -VIEWHEIGHT, self.frame.size.width, VIEWHEIGHT)];
        //宽度自动适配
        refreshView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        //可以设定它的背景颜色
        refreshView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        //提示文本
        msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, VIEWHEIGHT)];
        msgLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        msgLabel.text=pullDownBeginText;
        msgLabel.textAlignment=NSTextAlignmentCenter;
        [refreshView addSubview:msgLabel];
        //箭头
        arrowImageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, (VIEWHEIGHT-40)/2, 40, 40)];
        upImage=[UIImage imageNamed:@"arrow.png"];
        arrowImageView.image=upImage;
        downImage=[UIImage imageWithCGImage:arrowImageView.image.CGImage scale:1.0 orientation:UIImageOrientationDown];
        [refreshView addSubview:arrowImageView];
        //指示器
        activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, (VIEWHEIGHT-40)/2, 40, 40)];
        activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        [refreshView addSubview:activityIndicatorView];
        [self addSubview:refreshView];
        //下边加载视图
        loadView=[[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, VIEWHEIGHT)];
        //宽度自动适配
        loadView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        //可以设定它的背景颜色
        loadView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        //提示文本
        loadLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, VIEWHEIGHT)];
        loadLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        loadLabel.text=pullDownBeginText;
        loadLabel.textAlignment=NSTextAlignmentCenter;
        [loadView addSubview:loadLabel];
        //箭头
        loadArrow=[[UIImageView alloc]initWithFrame:CGRectMake(50, (VIEWHEIGHT-40)/2, 40, 40)];
        loadArrow.image=downImage;
        [loadView addSubview:loadArrow];
        //指示器
        loadActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, (VIEWHEIGHT-40)/2, 40, 40)];
        loadActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        [loadView addSubview:loadActivityIndicatorView];
        [self addSubview:loadView];
        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dictChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}
-(void)dictChange
{
    refreshView.frame=CGRectMake(0, -VIEWHEIGHT, self.frame.size.width, VIEWHEIGHT);
    loadView.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, VIEWHEIGHT);
    if(self.contentSize.height>self.frame.size.height)
    {
        loadView.frame=CGRectMake(0, self.contentSize.height, self.frame.size.width, VIEWHEIGHT);
    }
}
-(void)loadWithTarget:(id)_target andWithAction:(SEL)_action
{
    loadTarget=_target;
    loadAction=_action;
    //头视图
    [self headView];
}
-(void)refreshWithTarget:(id)_target andWithAction:(SEL)_action
{
    refreshTarget=_target;
    refreshAction=_action;
    //头视图
    [self headView];
}
-(void)endRefreshing
{
    //停靠
    [UIView animateWithDuration:0.3 animations:^{
        self.contentInset=edgeInsets;
    }];
    self.userInteractionEnabled=YES;
    //隐藏指示器
    [activityIndicatorView stopAnimating];
    //显示箭头
    arrowImageView.transform=CGAffineTransformIdentity;
    arrowImageView.hidden=NO;
    //提示
    msgLabel.text=pullDownBeginText;
}
-(void)endLoading
{
    //停靠
    [UIView animateWithDuration:0.3 animations:^{
        self.contentInset=edgeInsets;
    }];
    self.userInteractionEnabled=YES;
    //隐藏指示器
    [loadActivityIndicatorView stopAnimating];
    //显示箭头
    loadArrow.transform=CGAffineTransformIdentity;
    loadArrow.hidden=NO;
    //提示
    loadLabel.text=pullDownBeginText;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:self];
    }
    if([keyPath isEqualToString:@"state"])
    {
        if(self.panGestureRecognizer.state==UIGestureRecognizerStateBegan)
        {
            [self scrollViewWillBeginDragging:self];
        }
        if(self.panGestureRecognizer.state==UIGestureRecognizerStateEnded)
        {
            if(self.contentOffset.y<-VIEWHEIGHT-edgeInsets.top)
            {
                isDragging=NO;
                //封锁表视图
                self.userInteractionEnabled=NO;
                //隐藏箭头
                arrowImageView.hidden=YES;
                //显示指示器
                [activityIndicatorView startAnimating];
                //提示正在刷新
                msgLabel.text=pullDownRefreshingText;
                //停靠
                self.contentInset=UIEdgeInsetsMake(VIEWHEIGHT+edgeInsets.top, 0, 0, 0);
                //调用刷新行为
                [refreshTarget performSelector:refreshAction withObject:nil afterDelay:0.0];
            }
            else if(self.contentOffset.y+self.frame.size.height>self.contentSize.height+VIEWHEIGHT+edgeInsets.bottom)
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
                    loadLabel.text=pullUpLoadingText;
                    //停靠
                    self.contentInset=UIEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom+VIEWHEIGHT, edgeInsets.right);
                    //调用刷新行为
                    [loadTarget performSelector:loadAction withObject:nil afterDelay:0.0];
                }
                else
                {
                    if (self.contentOffset.y>VIEWHEIGHT-edgeInsets.top)
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
                        loadLabel.text=pullUpLoadingText;
                        //停靠
                        self.contentInset=UIEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom+VIEWHEIGHT, edgeInsets.right);
                        self.contentInset=UIEdgeInsetsMake(edgeInsets.top-VIEWHEIGHT, edgeInsets.left, edgeInsets.bottom+VIEWHEIGHT, edgeInsets.right);
                        //调用刷新行为
                        [loadTarget performSelector:loadAction withObject:nil afterDelay:0.0];
                    }
                }
            }
        }
    }
}
#pragma  mark - scrollview
//正在滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(isDragging)
    {
        if(scrollView.contentOffset.y<-edgeInsets.top)
        {
            msgLabel.text=pullDownBeginText;
            arrowImageView.image=upImage;
            if(scrollView.contentOffset.y<-VIEWHEIGHT-edgeInsets.top)
            {
                msgLabel.text=pullDownWillText;
                [UIView animateWithDuration:0.3 animations:^{
                    arrowImageView.transform=CGAffineTransformMakeRotation(180*M_PI/180);
                }];
            }
            else
            {
                msgLabel.text=pullDownBeginText;
                [UIView animateWithDuration:0.3 animations:^{
                    arrowImageView.transform=CGAffineTransformIdentity;
                }];
            }
        }
        else
        {
            if (scrollView.contentOffset.y+scrollView.frame.size.height>scrollView.contentSize.height)
            {
                
                if(scrollView.contentSize.height>scrollView.frame.size.height)
                {
                    loadLabel.text=pullUpBeginText;
                    if(scrollView.contentOffset.y+self.frame.size.height>scrollView.contentSize.height+VIEWHEIGHT+edgeInsets.bottom)
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
                    if(scrollView.contentOffset.y>VIEWHEIGHT-edgeInsets.top)
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
-(void)willPullUp
{
    loadLabel.text=pullUpWillText;
    [UIView animateWithDuration:0.3 animations:^{
        loadArrow.transform=CGAffineTransformMakeRotation(180*M_PI/180);
    }];
}
-(void)resetPullUp
{
    loadLabel.text=pullUpBeginText;
    [UIView animateWithDuration:0.3 animations:^{
        loadArrow.transform=CGAffineTransformIdentity;
    }];
}
//拖拽开始
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging=YES;
    edgeInsets=scrollView.contentInset;
    if(scrollView.contentSize.height<scrollView.frame.size.height)
    {
        loadView.frame=CGRectMake(0, scrollView.frame.size.height-edgeInsets.top-edgeInsets.bottom, self.frame.size.width, VIEWHEIGHT);
    }
}
@end
