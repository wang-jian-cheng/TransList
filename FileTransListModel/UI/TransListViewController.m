//
//  TransListViewController.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/22.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "TransListViewController.h"
#import "TransInfoManager.h"
#import "Define.h"
#import "LoadView.h"
typedef enum _TableViewShowMode
{
    TableViewShowModeDownload,
    TableViewShowModeUpload
    
    
}TableViewShowMode;


typedef enum _TableViewSectionForUpload
{
    TableViewSectionUploadOnGoing = 0,
    TableViewSectionUploadFinish
    
}TableViewSectionForUpload;




@interface TransListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat _cellHeight;
    TableViewShowMode showMode;
    
    UITableView *_mainTableView;
    UISegmentedControl *segCtl;
    NSTimer *timer;
    NSUInteger loadViewTag;
    
    
    BOOL transInfoNeeRead;
}

@property(nonatomic) NSMutableArray *loadViewsArr;
@property(nonatomic) NSMutableArray *transIdUploadPool;


@property(nonatomic) NSMutableArray *unFinishUploadArr;
@property(nonatomic) NSMutableArray *finishedUploadArr;
@end

@implementation TransListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    transInfoNeeRead = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 60, 30)];
    backBtn.backgroundColor = [UIColor redColor];
    
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [self initDatas];
    
    [self initViews];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reloadDatas];
}



-(void)initDatas
{
    
    [self loadData];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadDatas) userInfo:nil repeats:YES];
    
    /*如果文件被更新，会受到通知，弱没有收到文件被修改的通知则不去重新载入数据*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transInfoChanged:) name:TRANS_INFO_MANAGER_WRITE_NOTICE object:nil];
}



-(void)loadData
{
    [self.transIdUploadPool addObjectsFromArray:[TransInfoManager getTransIdPoolWithType:TRANS_ID_UPLOAD_POOL]];
    
    for (NSString *transid in self.transIdUploadPool) {
        
        TransInfoModel *tempModel = [TransInfoManager getTransInfo:transid];
        
        if ([tempModel.transStatus isEqualToString:TransStatusOnGoing] || [tempModel.transStatus isEqualToString:TransStatusUnStart]) {
            
            [self.unFinishUploadArr addObject:tempModel];
            
        }
        else if([tempModel.transStatus isEqualToString:TransStatusFinish] || [tempModel.transStatus isEqualToString:TransStatusFailed])
        {
            [self.finishedUploadArr addObject:tempModel];
        }
    }
}

-(void)reloadDatas
{
    
    if (transInfoNeeRead == NO) {
        return;//如果文件未被更新则不去读取，减少读取文件的次数
    }

    [self.transIdUploadPool removeAllObjects];
    [self.unFinishUploadArr removeAllObjects];
    [self.finishedUploadArr removeAllObjects];
    [self loadData];
    [_mainTableView reloadData];
    transInfoNeeRead = NO;
}

-(void)initViews
{
    segCtl = [[UISegmentedControl alloc] initWithItems:@[@"下载列表",@"上传列表"]];
    segCtl.selectedSegmentIndex = 0;
    segCtl.center = CGPointMake(SCREEN_WIDTH/2, 64+10);
    
    [segCtl addTarget:self action:@selector(segSelectAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segCtl];

    [self initTableView];
    
}

-(void)initTableView
{
    _cellHeight = 50;
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, segCtl.frame.size.height + segCtl.frame.origin.y + 20,
                                                                   SCREEN_WIDTH,
                                                                   SCREEN_HEIGHT - (segCtl.frame.size.height + segCtl.frame.origin.y + 20))];
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.separatorColor =  [UIColor grayColor];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    
    
    //设置cell分割线从最左边开始
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0 )
    {
        if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_mainTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        }
        
        if ([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_mainTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        }
    }
    
    
    [self.view addSubview:_mainTableView];
}

-(void)segSelectAction:(UISegmentedControl *)sender
{
    DLog(@"select index %ld",sender.selectedSegmentIndex);
    showMode = (TableViewShowMode)(sender.selectedSegmentIndex);
    
    [_mainTableView reloadData];
}

#pragma mark - Click actions


-(void)transInfoChanged:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    DLog(@"%@",dict);
    
    transInfoNeeRead = YES;
    
//    [self reloadDatas];

}

-(void)backBtnClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadBtnClick:(UIButton *)sender
{
    LoadView *tempView = self.loadViewsArr[sender.tag];
    
   
    double num = (tempView.pieCapacity/360.0) * 100.0;
    num += 10;
    
    if (num >= 100) {
        return;
    }
    tempView.pieCapacity = 360*(num/100.0);
    //重绘view
    [tempView setNeedsDisplay];
}

#pragma mark - tools

-(LoadView *)getloadViewWithCurrent:(double)current andTotal:(double)total
{
    CGFloat arcWidth = 6;
    if(current == 0)
    {
        current =1;
    }
    
    LoadView *loadView = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, _cellHeight - 10, _cellHeight - 10) arcWidth:arcWidth current:current total:total];
    loadView.backgroundColor = [UIColor whiteColor];
    loadView.center = CGPointMake(SCREEN_WIDTH - _cellHeight , _cellHeight/2);
    loadView.tag = loadViewTag++;
    
    
    CGFloat radius = loadView.frame.size.width/2;
    UIButton *tempBtn = [[UIButton alloc] initWithFrame:CGRectMake(((1-sinf(M_PI_4))*radius),
                                                                   ((1-sinf(M_PI_4))*radius),
                                                                   radius*sinf(M_PI_4)*2,
                                                                   radius*sinf(M_PI_4)*2)];
    tempBtn.tag = loadView.tag;
    [tempBtn addTarget:self action:@selector(loadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [loadView addSubview:tempBtn];
    
    return loadView;
}


#pragma mark - self property

-(NSMutableArray *)finishedUploadArr
{
    if (_finishedUploadArr == nil) {
        _finishedUploadArr = [NSMutableArray array];
    }
    
    return _finishedUploadArr;
}

-(NSMutableArray *)unFinishUploadArr
{
    if (_unFinishUploadArr == nil) {
        _unFinishUploadArr = [NSMutableArray array];
    }
    
    return _unFinishUploadArr;
}

-(NSMutableArray *)transIdUploadPool
{
    if (_transIdUploadPool == nil) {
        _transIdUploadPool = [NSMutableArray array];
    }
    
    return _transIdUploadPool;
}

-(NSMutableArray *)loadViewsArr
{
    if(_loadViewsArr ==nil)
    {
        _loadViewsArr = [NSMutableArray array];
    }
    
    return _loadViewsArr;
}

#pragma mark -  tableview  Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    switch(showMode)
    {
        case TableViewShowModeUpload:
        {
            if(section == TableViewSectionUploadOnGoing)
            {
                return self.unFinishUploadArr.count;
            }
            else if(section == TableViewSectionUploadFinish)
            {
                return self.finishedUploadArr.count;
            }
        }
            break;
        case TableViewShowModeDownload:
            return 1;
            
    }
    
    return 1;
    
}

#pragma mark - setting for cell

//设置每行调用的cell

#define _CELL cell.contentView


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _cellHeight)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    switch (showMode) {
        case TableViewShowModeUpload:
        {
            
            cell.backgroundColor = [UIColor greenColor];
            if (indexPath.section == TableViewSectionUploadOnGoing) {
                
                TransInfoModel *tempModel = self.unFinishUploadArr[indexPath.row];
                LoadView *loadView = [self getloadViewWithCurrent:[tempModel.transBytes intValue] andTotal:[tempModel.allBytes intValue]];
                [self.loadViewsArr addObject:loadView];
                [_CELL addSubview:loadView];
                
                
            }
            else if(indexPath.section == TableViewSectionUploadFinish)
            {
                
                TransInfoModel *tempModel = self.finishedUploadArr[indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ 上传完成",tempModel.fileName];
            
            }
        }
            break;
         
            
            
        default:
        {
            LoadView *loadView = [self getloadViewWithCurrent:1 andTotal:100];
            [self.loadViewsArr addObject:loadView];
            [_CELL addSubview:loadView];
        }
            break;
    }
    
    
    
    
    
    
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0 )
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
    
}

//设置cell每行间隔的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return _cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    DLog(@"click cell section : %ld row : %ld",(long)indexPath.section,(long)indexPath.row);
   
}


//设置划动cell是否出现del按钮，可供删除数据里进行处理

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"删除";
}

//设置选中的行所执行的动作

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return indexPath;
    
}

#pragma mark - setting for section
//设置section的header view

#define SectionHeight  30

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SectionHeight)];
    tempView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 10, SectionHeight)];
    titleLab.font = [UIFont systemFontOfSize:12];
    [tempView addSubview:titleLab];
    
    switch (showMode) {
        case TableViewShowModeDownload:
        {
            if (section == 0) {
                titleLab.text = @"正在下载";
            }
            else if(section == 1)
            {
                titleLab.text = @"下载完成";
            }
            
        }
            break;
        case TableViewShowModeUpload:
        {
            if (section == 0) {
                titleLab.text = @"正在上传";
            }
            else if(section == 1)
            {
                titleLab.text = @"上传完成";
            }
        }
            break;
            
        default:
            break;
    }
    
    return tempView;
}

//设置section header 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SectionHeight;
}

//设置section footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
