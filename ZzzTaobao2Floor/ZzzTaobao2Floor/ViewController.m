//
//  ViewController.m
//  ZzzTaobao2Floor
//
//  Created by zhouzezhou on 2018/4/17.
//  Copyright © 2018年 zhouzezhou. All rights reserved.
//

// 模仿淘宝二楼的开启方式的实现
// @author:Zzz
// @site:zhouzezhou.com
// @time:2018年 4月18日 星期三 22时12分00秒 CST

#import "ViewController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width      // 屏幕的宽度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height    // 屏幕的高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height // 系统状态栏高度

#define floor1Height kScreenHeight  // 一楼的高度
#define floor2Height kScreenHeight  // 二楼的高度
#define animationInterval   0.8       // 动画速度/完成时间(s)
#define enter2FloorOffset   160      // 进入二楼时一楼视图的偏移量

@interface ViewController () <UITableViewDataSource, UIScrollViewDelegate>

// 一楼显示的TableView,UITableView继承自UIScollView,使用TabvlewView是为了方便展示在ScrollView上加载ScrollView的情形
@property (nonatomic, strong) UITableView *motionRecordTableview;

@property (nonatomic, strong) UIScrollView *backgroudScrollView1Floor;    // 一楼滑动视图,接收滑动手势
@property (nonatomic, strong) UIView *upstairsView;     // 二楼视图，可以在上面加载任何二楼所需的内容

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Mothed

-(void) configView
{
    [self.view setBackgroundColor: [UIColor cyanColor]];
    
    // 关于StatusBar的背景色的设置请自行百度,此处就不设置了
    
    // 1楼
    _backgroudScrollView1Floor = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, floor1Height)];
    [_backgroudScrollView1Floor setBackgroundColor:[UIColor blueColor]];
    // contentSize设置得比视图本身大才能进行滑动
    [_backgroudScrollView1Floor setContentSize:CGSizeMake(kScreenWidth, floor1Height + 1.f )];
    [_backgroudScrollView1Floor setScrollEnabled:YES];
    _backgroudScrollView1Floor.userInteractionEnabled = YES;
    _backgroudScrollView1Floor.delegate = self;
    [self.view addSubview:_backgroudScrollView1Floor];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 50.f)];
    [testLabel setBackgroundColor:[UIColor redColor]];
    [_backgroudScrollView1Floor addSubview:testLabel];
    [testLabel setTextAlignment:NSTextAlignmentCenter];
    [testLabel setText:@"Zzz在一楼，向下滑动试试"];
    
    UITableView *testTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, floor1Height - 150) style:UITableViewStyleGrouped];
    //    testTableview.delegate = self;
    testTableview.dataSource = self;
    testTableview.estimatedRowHeight = 0;
    testTableview.estimatedSectionHeaderHeight = 0;
    testTableview.estimatedSectionFooterHeight = 0;
    [testTableview setBackgroundColor:[UIColor grayColor]];
    [testTableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [_backgroudScrollView1Floor addSubview:testTableview];
    
    // 2楼
    _upstairsView = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenHeight , kScreenWidth, floor2Height)];
    [self.view addSubview:_upstairsView];
    [_upstairsView setBackgroundColor:[UIColor orangeColor]];
    
    UILabel *secondFloorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, floor2Height - 50 - kStatusBarHeight, kScreenWidth, 50)];
    [secondFloorLabel setText:@"Zzz在二楼,点击返回按钮回到一楼"];
    [secondFloorLabel setTextAlignment:NSTextAlignmentCenter];
    [_upstairsView addSubview:secondFloorLabel];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10 + kStatusBarHeight, 50, 50)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor lightGrayColor]];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_upstairsView addSubview:backBtn];
}

// 回到1楼的动画
-(void) startBack1FloorAnimation
{
    [self.backgroudScrollView1Floor setScrollEnabled:YES];
    
    [UIView animateWithDuration:animationInterval animations:^{
        // 二楼滑上去,滑出屏幕
        float endPointY2FloorView = -floor2Height;
        CGRect endRect2Floor = CGRectMake(0, endPointY2FloorView,  kScreenWidth, floor2Height);
        self.upstairsView.frame = endRect2Floor;
        
        // 一楼向上滑,回到原始位置
        float endPointY1FloorView = 0;
        CGRect endRect1Floor = CGRectMake(0, endPointY1FloorView, kScreenWidth, floor1Height);
        self.backgroudScrollView1Floor.frame = endRect1Floor;
    }];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ZzzTaobao2FloorReuseIdentifier"];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld %@", (long)indexPath.row + 1, @"我是TableView,滑动我或者上面的UILabel试试"]];
    [cell setBackgroundColor:[UIColor purpleColor]];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //test
    NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
    
    // 这个判断防止快速滑动的时候产生的偏移过多界面消失
    if([scrollView isScrollEnabled])
    {
        // 未达到开启二楼时的Offset(偏移量)时一楼跟着往下滑动
        // 探究为何:scrollview初始化的时候会调用一次scrollViewDidScroll方法，会在y轴负方向产生一个StatusBar的偏移量,所以在下面的计算方式中减去一个StatusBar的高度 Zzz 2018年 4月27日 星期五 21时17分40秒 CST
        float newPointY2FloorView = - floor2Height - scrollView.contentOffset.y - kStatusBarHeight;
        //    NSLog(@"newPointY2FloorView is: %f", newPointY2FloorView);
        CGRect newRect2Floor = CGRectMake(0, newPointY2FloorView,  kScreenWidth, floor2Height);
        _upstairsView.frame = newRect2Floor;
    }
    
    
    // 达到开启二楼时的Offset，启动进入二楼时的动画效果
    if(scrollView.contentOffset.y < - enter2FloorOffset && [scrollView isScrollEnabled])
    {
        NSLog(@"进入二楼");
        
        // 停用滑动，但已被滑动的视图会瞬间回到原点
        [scrollView setScrollEnabled:NO];
        
        // 让所有视图定位到结束滑动时的位置，为了和下面的下滑动画产生顺滑的视觉
        // 2楼
        float newPointY2FloorView = - floor2Height + enter2FloorOffset;
        CGRect newRect2Floor = CGRectMake(0, newPointY2FloorView, kScreenWidth, floor2Height);
        _upstairsView.frame = newRect2Floor;
        
        // 1楼
        float newPointY1FloorView = 0 + enter2FloorOffset;
        CGRect newRect1Floor = CGRectMake(0, newPointY1FloorView, kScreenWidth, floor1Height);
        scrollView.frame = newRect1Floor;
        
        // 下滑动画
        [UIView animateWithDuration:animationInterval animations:^{
            // 二楼滑下来
            float endPointY2FloorView = 0;
            CGRect endRect2Floor = CGRectMake(0, endPointY2FloorView,  kScreenWidth, floor2Height);
            self.upstairsView.frame = endRect2Floor;
            
            // 一楼继续向下滑,滑出屏幕
            float endPointY1FloorView = kScreenHeight;
            CGRect endRect1Floor = CGRectMake(0, endPointY1FloorView, kScreenWidth, floor1Height);
            scrollView.frame = endRect1Floor;
        }];
    }
}

// 以下方法可以监听更多ScrollView的事件
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"scrollViewWillEndDragging");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewShouldScrollToTop");
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop");
}

#pragma mark - Button Respond
-(void) backBtnClick:(UIButton *) sender
{
    // 返回一楼
    [self startBack1FloorAnimation];
}

@end
