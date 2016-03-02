//
//  HomeViewController.m
//  类似网易新闻的频道切换
//
//  Created by wtw on 15/11/11.
//  Copyright © 2015年 jjl. All rights reserved.
//

static const int ChildCount = 10;

#import "HomeViewController.h"
#import "OneViewController.h"
#import "MyLabel.h"
#import "UIView+ViewExtention.h"

@interface HomeViewController ()<UIScrollViewDelegate>
/**
 *  顶部标题ScrollView
 */
@property (weak, nonatomic) IBOutlet UIScrollView *titlesScrollView;
/**
 *  底部的内容ScrollView
 */
@property (weak, nonatomic) IBOutlet UIScrollView *contentsScrollView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加所有的子控制器
    [self setupAllChildVces];
    
    //设置顶部的titlesScrollView
    [self setupTitlesSccrollView];
    
    //设置底部的contentsScrollView
    [self setupContentsScrollView];
    
    //默认的设置
    [self setupDefaultSetting];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}
/**
 *  默认的设置
 */
- (void)setupDefaultSetting {
    //显示第一个控制器
   UIView *firstView = [[self.childViewControllers firstObject] view];
    firstView.frame = self.contentsScrollView.bounds;
    [self.contentsScrollView addSubview:firstView];
    
    //取出第一个label
    MyLabel *firstlabel = [self.titlesScrollView.subviews firstObject];
    firstlabel.scale = 1.0;
}

/**
 *  添加子控制器
 */
- (void)setupAllChildVces {
    //模拟ChildCount个控制器
    for (int i = 0; i < ChildCount; i++) {
        OneViewController *oneVc = [[OneViewController alloc] init];
        oneVc.title = [NSString stringWithFormat:@"频道 - %d",i];
        [self addChildViewController:oneVc];
    }
    //设置内容的大小
    self.contentsScrollView.contentSize = CGSizeMake(ChildCount * [UIScreen mainScreen].bounds.size.width, 0);
}

/**
 * 设置顶部的titlesScrollView
 */
- (void)setupTitlesSccrollView {

    CGFloat labelW = 100;
    //添加所有的label
    for (int i = 0; i < ChildCount; i++) {
        MyLabel *label = [[MyLabel alloc] init];
        
        label.tag = i;
        
        label.text = [self.childViewControllers[i] title];
        
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
        
        label.y = 0;
        label.height = self.titlesScrollView.frame.size.height;
        label.x = i * labelW;
        label.width = labelW;
        [self.titlesScrollView addSubview:label];
    }
    //设置内容的尺寸
    self.titlesScrollView.contentSize = CGSizeMake(labelW * ChildCount, 0);
    self.titlesScrollView.showsHorizontalScrollIndicator = NO;
    self.titlesScrollView.showsVerticalScrollIndicator = NO;
}

/**
 *  监听顶部标题的点击
 */
- (void)labelClick:(UIGestureRecognizer *)tap {

    //获得被点击的label
    UIView *label = tap.view;
    
    //滚动contentsScrollView到当前显示的控制器
    CGFloat contentsOffsetX = label.tag * self.contentsScrollView.frame.size.width;
    CGPoint titlesOffset = CGPointMake(contentsOffsetX, self.contentsScrollView.contentOffset.y);
    [self.contentsScrollView setContentOffset:titlesOffset animated:YES];
}

/**
 *  设置底部的contentsScrollView
 */
- (void)setupContentsScrollView {
    self.contentsScrollView.pagingEnabled = YES;
    self.contentsScrollView.showsHorizontalScrollIndicator = NO;
    self.contentsScrollView.delegate = self;
}

#pragma mark -contentsScrollView代理方法
/**
 *  只要scrollView在滚动，就会调用（让标题只要稍微有一点滚动就会跟着滚动）
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //取ABS目的是为了当第一个或者最后一个在拖动的时候大小变小
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    
    //左边的索引
    int leftIndex = value;
    //右边的索引
    int rightIndex = leftIndex + 1;
    
    //右边的比例
    CGFloat rightScale = value - leftIndex;
    //左边的比例
    CGFloat leftScale = 1 - rightScale;
    
    MyLabel *leftLabel = self.titlesScrollView.subviews[leftIndex];
    leftLabel.scale = leftScale;
    
    if (rightIndex >= ChildCount) return;
    MyLabel *rightLabel = self.titlesScrollView.subviews[rightIndex];
    rightLabel.scale = rightScale;

    NSLog(@"%f  %f",leftScale,rightScale);
}

/**
 *  当scrollView停止滚动（减速完毕）就会调用（需要通过代码设置滚动才会实现）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:self.contentsScrollView];
}

/**
 *  手一松开就会调用,当scrollview减速完毕后调用(人为手动拖动的时候才会调用)
 *  通过这个方法内部来实现控制器的view 的懒加载
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //根据偏移量计算索引
    int index = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    //让顶部的scrollView跟随着滚动
    MyLabel *label = self.titlesScrollView.subviews[index];
    CGFloat titlesOffsetX = label.center.x - scrollView.frame.size.width * 0.5;
    //对顶部的scrollView做越界处理
    CGFloat maxTitlesOffsetX = self.titlesScrollView.contentSize.width - self.titlesScrollView.frame.size.width;
    if (titlesOffsetX < 0) {
        titlesOffsetX = 0;
    }else if(titlesOffsetX > maxTitlesOffsetX) {
        titlesOffsetX = maxTitlesOffsetX;
    }
    CGPoint titlesOffset = CGPointMake(titlesOffsetX, self.titlesScrollView.contentOffset.y);
    [self.titlesScrollView setContentOffset:titlesOffset animated:YES];
    
    //解决问题是如果点击第一个再点击最后一个的时候可能中间的label显示的会有问题
    //拿到其他的label,scale 值清零
    for (MyLabel *otherLabel in self.titlesScrollView.subviews) {
        if (label != otherLabel)   otherLabel.scale = 0.0;
    }
    
    //添加对应的控制器的view到屏幕上
    UIViewController *vc = self.childViewControllers[index];
    
    //如果vc的view已经加显示在屏幕上了，就不需要在进行添加了
    if (vc.view.superview) return;
    //添加子控制器的view
    vc.view.width = self.contentsScrollView.width;
    vc.view.height = self.contentsScrollView.height;
    vc.view.y = 0;
    vc.view.x = index * vc.view.width;
    [self.contentsScrollView addSubview:vc.view];
    NSLog(@"添加子控制器 - %d",index);
}

@end
