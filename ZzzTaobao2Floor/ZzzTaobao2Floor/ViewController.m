//
//  ViewController.m
//  ZzzTaobao2Floor
//
//  Created by zhouzezhou on 2018/4/17.
//  Copyright © 2018年 zhouzezhou. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

// 屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
// 屏幕的高度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
// 系统状态栏高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height


@interface ViewController () <UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *motionRecordTableview;
/** 填加的滑动视图*/
@property(nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic, strong) UIView *upstairsView; // 楼上

@property (nonatomic, assign) BOOL isUpStairs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isUpStairs = NO;
    
    [self configView];
    NSLog(@"viewDidLoad");
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Mothed

// test
//// 对需要进行签名的字段进行拼接（并进行ASCII排序）
//-(NSString *) getSortParam:(NSDictionary *) paramDic connector:(NSString *) connector
//{
//    NSString *result = [NSString string];
//    BOOL first = YES;
//
//    // 字符串数组排序
//    NSArray * paramKey = [paramDic allKeys];
//
//    //    NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch|NSNumericSearch|
//    //    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
//    NSStringCompareOptions comparisonOptions = NSNumericSearch|
//    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
//    NSComparator sort = ^(NSString *obj1, NSString *obj2){
//        NSRange range = NSMakeRange(0, obj1.length);
//        return [obj1 compare:obj2 options:comparisonOptions range:range];
//    };
//
//    NSArray *paramKeySorted = [paramKey sortedArrayUsingComparator:sort];
//    //    NSLog(@"字符串数组排序结果%@",paramKeySorted);
//
//    for(int i = 0; i < paramKeySorted.count; i++)
//    {
//        if(!first)
//        {
//            result = [result stringByAppendingString:@"&"];
//        }
//        first = NO;
//
//        result = [result stringByAppendingString: paramKeySorted[i]];
//        result = [result stringByAppendingString: @"="];
////        NSString *value = [paramDic objectForKey: paramKeySorted[i]];
////        if(value != nil && ![value isEqualToString:@""])
////        {
////            result = [result stringByAppendingString:value];
////        }
//
//        id value = [paramDic objectForKey: paramKeySorted[i]];
//        NSString *valueStr;
//        if([value isKindOfClass:[NSString class]])
//        {
//            valueStr = (NSString *)value;
//        }
//        else if([value isKindOfClass:[NSDictionary class]])
//        {
//            NSDictionary *valueDic = (NSDictionary *)value;
//
//            if([NSJSONSerialization isValidJSONObject:valueDic])
//            {
//                NSError* error;
//                NSData *str = [NSJSONSerialization dataWithJSONObject:valueDic
//                                                              options:kNilOptions error:&error];
//                NSString *jsonStr = [[NSString alloc] initWithData:str encoding:NSUTF8StringEncoding];
//                NSLog(@"end Result: %@",jsonStr);
//
//                valueStr = jsonStr;
//            }
//            else
//            {
//                NSLog(@"An error happened while serializing the JSON data.");
//            }
//        }
//
//        if(valueStr != nil && ![valueStr isEqualToString:@""])
//        {
//            result = [result stringByAppendingString:valueStr];
//        }
//
//    }
//
//    return result;
//}
//
//- (NSString *)md5Digest:(NSString *) oriStr
//{
//
//    const char *cStr = [oriStr UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
//    return [NSString stringWithFormat:
//            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
//            ];
//}

-(void) configView
{
    [self.view setBackgroundColor: [UIColor cyanColor]];
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenWidth / 2, kScreenWidth, kScreenHeight /2 )];
    [scrollview setBackgroundColor:[UIColor blueColor]];
    [scrollview setContentSize:CGSizeMake(kScreenWidth, (kScreenHeight / 2) + 1.f )];
    [scrollview setScrollEnabled:YES];
    scrollview.userInteractionEnabled = YES;
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 50.f)];
    [testLabel setBackgroundColor:[UIColor redColor]];
    [scrollview addSubview:testLabel];
    [testLabel setTextAlignment:NSTextAlignmentCenter];
    [testLabel setText:@"我是一楼 Zzz"];
    
    _motionRecordTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenHeight / 4, kScreenWidth, kScreenHeight / 4) style:UITableViewStyleGrouped];
    //    _motionRecordTableview.delegate = self;
    _motionRecordTableview.dataSource = self;
    _motionRecordTableview.estimatedRowHeight = 0;
    _motionRecordTableview.estimatedSectionHeaderHeight = 0;
    _motionRecordTableview.estimatedSectionFooterHeight = 0;
    [_motionRecordTableview setBackgroundColor:[UIColor grayColor]];
    [_motionRecordTableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [scrollview addSubview:_motionRecordTableview];
    
    [_motionRecordTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(testLabel.mas_bottom).with.offset(30.f);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kScreenHeight / 4);
        
    }];
    
    //    self.scrollView = _motionRecordTableview;
    //    self.scrollView.delegate = self;
    
    _upstairsView = [[UIView alloc] initWithFrame:CGRectMake(0, - (kScreenHeight /2) , kScreenWidth,( kScreenHeight /2 ) + 60.f)];
    [self.view addSubview:_upstairsView];
    [_upstairsView setBackgroundColor:[UIColor orangeColor]];
    
    UILabel *secondFloorLabel = [[UILabel alloc] init];
    [secondFloorLabel setText:@"我是二楼"];
    [secondFloorLabel setTextAlignment:NSTextAlignmentCenter];
    [_upstairsView addSubview:secondFloorLabel];
    
    [secondFloorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.upstairsView.mas_bottom).with.offset(-5.f);
        make.left.mas_equalTo(self.upstairsView);
        make.right.mas_equalTo(self.upstairsView);
    }];
    
    // test
    
    //    [UIView animateWithDuration:5.f animations:^{
    //        float newY = 60.f;
    //        NSLog(@"new y is: %f", newY);
    //        CGRect newRect = CGRectMake(0, newY,  kScreenWidth,( kScreenHeight /2 ) + 60.f);
    //        self.upstairsView.frame = newRect;
    //    }];
    
}

#pragma mark - Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"sadfsdaf"];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    [cell setBackgroundColor:[UIColor purpleColor]];
    
    return cell;
}


#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    CGFloat offsetY = MAX(-(scrollView.contentOffset.y+scrollView.contentInset.top), 0.);
    //    CGPoint newPoi = CGPointMake(0, _upstairsView.frame.origin.y + scrollView.contentOffset.y);
    
    // CGRectMake(0, - (kScreenHeight /2) , kScreenWidth,( kScreenHeight /2 ) + 60.f)
    
    float newY = - (kScreenHeight /2) - scrollView.contentOffset.y;
    NSLog(@"new y is: %f", newY);
    CGRect newRect = CGRectMake(0, newY,  kScreenWidth,( kScreenHeight /2 ) + 60.f);
    _upstairsView.frame = newRect;
    
    //    NSLog(@"scrollView.contentOffset.y: %f",scrollView.contentOffset.y);
    
    if(scrollView.contentOffset.y < -60.f)
    {
        NSLog(@"second floor start .");
        _isUpStairs = YES;
        
        // 停用滑动，但已被滑动的视图会瞬间回到原点
        [scrollView setScrollEnabled:NO];
        
        // 让所有视图定位到结束滑动时的位置，为了和下面的下滑动画产生顺滑的视觉
        float newY = - (kScreenHeight /2) + 60;
        NSLog(@"new y is: %f", newY);
        CGRect newRect = CGRectMake(0, newY,  kScreenWidth,( kScreenHeight /2 ) + 60.f);
        _upstairsView.frame = newRect;
        
        // CGRectMake(0, kScreenWidth / 2, kScreenWidth, kScreenHeight /2 )
        float newY_scrollview = kScreenWidth / 2 + 60.f;
        //            NSLog(@"new y is: %f", newY);
        CGRect newRect_scrollview = CGRectMake(0, newY_scrollview, kScreenWidth, kScreenHeight /2);
        scrollView.frame = newRect_scrollview;
        
        
        // 下滑动画
        [UIView animateWithDuration:5.f animations:^{
            // 二楼滑下来
            float newY = 60.f;
            //            NSLog(@"new y is: %f", newY);
            CGRect newRect = CGRectMake(0, newY,  kScreenWidth,( kScreenHeight /2 ) + 60.f);
            self.upstairsView.frame = newRect;
            
            // 一楼向下滑的动画
            // CGRectMake(0, kScreenWidth / 2, kScreenWidth, kScreenHeight /2 )
            float newY_scrollview = kScreenWidth / 2 - ( - (kScreenHeight /2) + 60.f);
            //            NSLog(@"new y is: %f", newY);
            CGRect newRect_scrollview = CGRectMake(0, newY_scrollview, kScreenWidth, kScreenHeight /2);
            scrollView.frame = newRect_scrollview;
            
        }];
    }
    
    //    NSLog(@"scrollView.contentInset.top: %f",scrollView.contentInset.top);
    
    
    //    _progress       = MIN(MAX(offsetY / self.frame.size.height, 0.), 1.);
    //    if (!self.isRefreshing) {
    //        [self redrawFromProgress:self.progress];
    //    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    NSLog(@"scrollViewWillEndDragging");
    
    //    if (!self.isRefreshing && self.progress >= 1.) {
    //        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewDidRefresh:)]) {
    //            [self.delegate refreshViewDidRefresh:self];
    //            [self beginRefreshing];
    //        }
    //    }
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
// called on finger up as we are moving
{
    NSLog(@"scrollViewWillBeginDecelerating");
    
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollViewDidEndDecelerating");
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewShouldScrollToTop");
    return YES;
}
// return a yes if you want to scroll to the top. if not defined, assumes YES

// called when scrolling animation finished. may be called immediately if already at top
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop");
}




//// MARK: animate the Refresh View
//- (void)beginRefreshing {
//    self.refreshing = YES;
//    [UIView animateWithDuration:.3 animations:^{
//        UIEdgeInsets newInsets       = self.scrollView.contentInset;
//        newInsets.top               += self.frame.size.height;
//        self.scrollView.contentInset = newInsets;
//    }];
//
//    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
//    strokeStartAnimation.fromValue         = @-.5;
//    strokeStartAnimation.toValue           = @1.;
//
//    CABasicAnimation *strokeEndAnimation   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    strokeEndAnimation.fromValue           = @0.;
//    strokeEndAnimation.toValue             = @1.;
//
//    CAAnimationGroup *strokeAniamtionGroup = [CAAnimationGroup animation];
//    strokeAniamtionGroup.duration          = 1.5;
//    strokeAniamtionGroup.repeatDuration    = 5.;
//    strokeAniamtionGroup.animations        = @[strokeStartAnimation,strokeEndAnimation];
//    [self.ovalShapeLayer addAnimation:strokeAniamtionGroup forKey:nil];
//
//    //飞机动画
//    CAKeyframeAnimation *flightAnimation   = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    flightAnimation.path                   = self.ovalShapeLayer.path;
//    flightAnimation.calculationMode        = kCAAnimationPaced;
//    //旋转
//    CABasicAnimation    *airplanOrientationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    airplanOrientationAnimation.fromValue  = @0.;
//    airplanOrientationAnimation.toValue    = @(M_PI *2);
//
//    CAAnimationGroup *flightAnimationGroup = [CAAnimationGroup animation];
//    flightAnimationGroup.duration          = 1.5;
//    flightAnimationGroup.repeatDuration    = 5.;
//    flightAnimationGroup.animations        = @[flightAnimation,airplanOrientationAnimation];
//    [self.airplaneLayer addAnimation:flightAnimationGroup forKey:nil];
//}
//
//- (void)endRefreshing {
//    self.refreshing   = NO;
//
//    [UIView animateWithDuration:.3 delay:0. options:(UIViewAnimationOptionCurveEaseOut) animations:^{
//        UIEdgeInsets newInsets       = self.scrollView.contentInset;
//        newInsets.top               -= self.frame.size.height;
//        self.scrollView.contentInset = newInsets;
//    } completion:^(BOOL finished) {
//
//    }];
//}


@end
