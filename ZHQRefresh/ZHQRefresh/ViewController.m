//
//  ViewController.m
//  ZHQRefresh
//
//  Created by wyzc on 16/1/18.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "ViewController.h"
#import "ZHQRefresh.h"//必须导入这个头文件
@interface ViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource=self;//设置代理
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];//关闭不需要的分割线
    //增加下拉刷新功能
    [self.tableView refreshWithTarget:self andWithAction:@selector(refresh)];
    //增加上拉加载功能
    [self.tableView loadWithTarget:self andWithAction:@selector(load)];
    self.tableView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    self.tableView.layer.cornerRadius=20;
    self.tableView.layer.masksToBounds=YES;
    //注意：refreshWithTarget loadWithTarget
    //endRefreshing endLoading必须在主线程调用，因为里面有ui操作
    NSLog(@"this is change!!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;//也可以用10或0去测试
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId=@"cell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%03ld",indexPath.row+1];
    return cell;
}
#pragma mark - 刷新和加载具体行为
-(void)refresh
{
    //在这进行你的刷新
    [NSThread sleepForTimeInterval:2];//模拟刷新用时2秒
    //结束刷新
    [self.tableView endRefreshing];//必须调用这个行为结束刷新
}
-(void)load
{
    //在这进行你的加载
    [NSThread sleepForTimeInterval:2];//模拟刷新用时2秒
    //结束刷新
    [self.tableView endLoading];//必须调用这个行为结束刷新
}
@end
