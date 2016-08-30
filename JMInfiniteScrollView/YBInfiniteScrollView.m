//
//  YBAutoScrollView.m
//  YuanBuy
//
//  Created by FBI、君陌 on 15/8/28.
//  Copyright (c) 2015年 君陌. All rights reserved.
//

#import "YBInfiniteScrollView.h"

#import "UIImageView+YYWebImage.h"
#import "UIView+YYAdd.h"

#define Label_Hieght       26                       //下方label的高度

#define ScrollView_Width   self.frame.size.width    //scrollView的宽度
#define ScrollView_Height  self.frame.size.height   //scrollView的高度

#define kScreen_W          [UIScreen mainScreen].bounds.size.width
#define kScreen_H          [UIScreen mainScreen].bounds.size.height

@implementation YBInfiniteScrollView{
    CADisplayLink * _playLink;
}

+ (instancetype) shareInstanceWithFrame:(CGRect) frame delegate:(id <YBInfiniteScrollViewDelegate>) delegate timeInterval:(NSTimeInterval)timeInterval{
    
    YBInfiniteScrollView * scrollView = [[YBInfiniteScrollView alloc] initWithFrame:frame delegate:delegate timeInterval:timeInterval];
    
    return scrollView;
}

- (instancetype) initWithFrame:(CGRect) frame delegate:(id <YBInfiniteScrollViewDelegate>) delegate timeInterval:(NSTimeInterval)timeInterval{
    
    if (self = [super initWithFrame: frame]) {
        
        //配置 成员变量
        _delegate = delegate;
        _timeInterval = timeInterval;
        
        _playLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startScroll)];
        [_playLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _playLink.paused = YES;
        _playLink.frameInterval = _timeInterval * 60;
        
        //配置UI
        [self configureUI];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void) configureUI{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scrollView.top = 0;
    _scrollView.left = 0;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(ScrollView_Width - 100, ScrollView_Height - Label_Hieght, 100, Label_Hieght)];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, ScrollView_Height - Label_Hieght, ScrollView_Width, Label_Hieght)];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:14];
    _label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _label.hidden = YES;
    
    [self addSubview:_scrollView];
    [self addSubview:_label];
    [self addSubview:_pageCtrl];
}

#pragma mark - 配置滚动图片
- (void) setImageArr:(NSMutableArray *)imageArr{
    
    BOOL isTheSame = YES;
    //判断两次传入的数据是否一致,若一致则不需要重新创建ImageView
    if (imageArr.count != _imageArr.count) {
        isTheSame = NO;
    } else {
        for (NSInteger i = 0; i < imageArr.count; i ++) {
            if (![imageArr[i] isEqualToString:_imageArr[i]]) {
                isTheSame = NO;
            }
        }
    }
    
    if (isTheSame) {
        return;
    }
    
    _imageArr = imageArr;
    
    if (_imageArr.count) {
        _pageNum = _imageArr.count;
        _pageCtrl.numberOfPages = _pageNum;
        _scrollView.contentSize = CGSizeMake(kScreen_W * (_pageNum + 2), 0);
        
        for (id anything in _scrollView.subviews) {
            //防止在cell中复用会重复加载UI
            [anything removeFromSuperview];
        }
        
        for (NSInteger i = 0; i < _pageNum + 2; i ++) {
            NSInteger j = i;
            
            if (i == 0) {
                j = _pageNum - 1;
            } else if (i == _pageNum + 1) {
                j = 0;
            } else {
                j = i - 1;
            }
            [_scrollView addSubview:[self configureImageView:i index:j]];
        }
        _scrollView.contentOffset = CGPointMake(ScrollView_Width, 0);
        
        [self bringSubviewToFront:_label];
        [self bringSubviewToFront:_pageCtrl];
        [self startAutoScroll];
    }
}

#pragma mark - 配置ImageView
- (UIImageView *) configureImageView:(NSInteger) actualIndex index:(NSInteger) practicalIndex{
    //判断传入的数组是图片0 还是NSURL 1还是本地字符串 2
    NSInteger anythingType = 0;
    id anything = _imageArr[practicalIndex];
    if ([anything isKindOfClass:[NSString class]]) {
        if ([anything hasPrefix:@"http"]) {
            anythingType = 1;
        } else {
            anythingType = 2;
        }
    } else if([anything isKindOfClass:[UIImage class]]){
        anythingType = 0;
    } else {
        anythingType = 4;
    }
    //加载ImageView
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:(CGRect){{actualIndex * ScrollView_Width, 0}, self.frame.size}];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.tag = actualIndex;
    
    if (anythingType == 0) {
        imgView.image = _imageArr[practicalIndex];
    } else if(anythingType == 1){
        [imgView setImageWithURL:[NSURL URLWithString:_imageArr[practicalIndex]] placeholder:[UIImage imageNamed:@"homeScroll_default"]];
    } else if (anythingType == 2){
        imgView.image = [UIImage imageNamed:_imageArr[practicalIndex]];
    }
    
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
    [imgView addGestureRecognizer:tapGes];
    imgView.userInteractionEnabled = YES;
    
    return imgView;
}

#pragma mark - 配置文本
- (void) setLabelArr:(NSMutableArray *)labelArr{
    _labelArr = labelArr;
    
    if (_labelArr.count) {
        _label.text = [NSString stringWithFormat:@"    %@", _labelArr[0]];
        _label.hidden = NO;
    }
}

#pragma mark - 配置页标相关
- (void) setPagePosition:(PageCtrlPosition)pagePosition{
    
    if (pagePosition == PageCtrlPositionLeft) {
        _pageCtrl.left = 0;
        _label.hidden = YES;
    } else if (pagePosition == PageCtrlPositionRight) {
        _pageCtrl.left = ScrollView_Width - 100;
    } else {
        _pageCtrl.centerX = self.centerX;
        _label.hidden = YES;
    }
}
#pragma mark - 页标颜色
- (void) setPageIndicatorColor:(UIColor *)pageIndicatorColor{
    _pageIndicatorColor = pageIndicatorColor;
    _pageCtrl.pageIndicatorTintColor = pageIndicatorColor;
}
#pragma mark - 当前页标颜色
- (void) setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor{
    _currentPageIndicatorColor = currentPageIndicatorColor;
    _pageCtrl.currentPageIndicatorTintColor = currentPageIndicatorColor;
}

#pragma mark - 图片被点击
- (void) clickImageView:(UITapGestureRecognizer *) tapGes{
    NSLog(@"tapGes.tag == %ld", tapGes.view.tag);
    if ([_delegate respondsToSelector:@selector(infiniteScrollView:didSelectedItemAtIndex:)]) {
        [_delegate infiniteScrollView:self didSelectedItemAtIndex:tapGes.view.tag];//从1 ~ 图片的数量
    }
}

#pragma mark - 手动启动开始自动滚动
- (void) startAutoScroll{
    
    _playLink.paused = NO;
}

- (void) startScroll{
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + ScrollView_Width, 0) animated:YES];
}

- (void) endAutoScroll{
    //结束自动滚动只需要清空 runloop里的延时 操作
    _playLink.paused = YES;
}

#pragma mark - ScrollView Delegate
#pragma mark -
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //自动滚动动画停止的时候开始自动滚动
    [self autoScrollPicture];
}

#pragma mark - 开始自动滚动图片
- (void) autoScrollPicture{
    
    if (!_isDrag) {
        //NSLog(@"contentOff.x == %f", _scrollView.contentOffset.x);
        if (_scrollView.contentOffset.x == (_pageNum + 1) * ScrollView_Width) {
            _scrollView.contentOffset = CGPointMake(ScrollView_Width, 0);
        } else if (_scrollView.contentOffset.x == 0){
            _scrollView.contentOffset = CGPointMake(ScrollView_Width * _pageNum, 0);
        }
        
        _playLink.paused = NO;
    }
}

#pragma mark - 向前滚动
- (void) startForwardScroll{
    
    NSInteger num = _scrollView.contentOffset.x / ScrollView_Width;
    [_scrollView setContentOffset:CGPointMake((num + 1) * ScrollView_Width, 0) animated:YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
        
    if (_isDrag) {//如果在拖拽中而不是自动滚动的时候 拖拽到第二张图片和倒数第二张图片时瞬间重置offset
        if (scrollView.contentOffset.x >= (_pageNum + 1) * ScrollView_Width - 2 && scrollView.contentOffset.x <= (_pageNum + 1) * ScrollView_Width) {
            scrollView.contentOffset = CGPointMake(ScrollView_Width, 0);
        } if (scrollView.contentOffset.x <= 2 && scrollView.contentOffset.x >= 0) {
            scrollView.contentOffset = CGPointMake(_pageNum * ScrollView_Width, 0);
        }
    }
    
    NSInteger num = _scrollView.contentOffset.x / kScreen_W - 1;
    if (num == - 1)  num = _pageNum;
    
    _pageCtrl.currentPage = num;
    
    //设置label的文字
    if (_labelArr.count) {
        _label.text = [NSString stringWithFormat:@"    %@", _labelArr[_pageCtrl.currentPage]];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //开始拖拽 清空 runloop里的延时 操作
    _playLink.paused = YES;
    
    if (_scrollView.contentOffset.x >= (_pageNum + 1) * kScreen_W - 2 && scrollView.contentOffset.x <= (_pageNum + 1) * kScreen_W) {
        _scrollView.contentOffset = CGPointMake(kScreen_W, 0);
    } if (_scrollView.contentOffset.x <= 2 && scrollView.contentOffset.x >=0) {
        _scrollView.contentOffset = CGPointMake(_pageNum * kScreen_W, 0);
    }

    _isDrag = YES;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //结束拖拽
    _isDrag = NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //手动拖动滚动停止的时候自动滚动图片
    [self autoScrollPicture];
}
- (void)dealloc
{
    NSLog(@"==%@轮播图被销毁了==",[self class]);
}

@end
