//
//  YBInfiniteScrollView.h
//  YuanBuy
//
//  Created by FBI、君陌 on 15/8/28.
//  Copyright (c) 2015年 君陌. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PageCtrlPosition){
    
    PageCtrlPositionLeft,       //左侧
    PageCtrlPositionMiddle,     //中间
    PageCtrlPositionRight,      //右侧
};

@class YBInfiniteScrollView;

/** 代理方法 */
@protocol YBInfiniteScrollViewDelegate <NSObject>

@optional
/** 返回点击的下标,选中的图片是第几张 */
- (void) infiniteScrollView:(YBInfiniteScrollView *) scrollView didSelectedItemAtIndex:(NSInteger) index;

@end

@interface YBInfiniteScrollView : UIView <UIScrollViewDelegate>{
    /** 一共多少张 */
    NSInteger _pageNum;
    /** 判断是否在拖拽中 */
    BOOL _isDrag;
}

/** 主视图ScrollView */
@property (nonatomic, retain, readonly) UIScrollView * scrollView;

/** UIPageControl 默认右侧*/
@property (nonatomic, retain, readonly) UIPageControl * pageCtrl;
/** pageCtrl位置 */
@property (nonatomic) PageCtrlPosition pagePosition;
/** pageCtrl颜色 */
@property (nonatomic, retain) UIColor * pageIndicatorColor;
/** 当前page颜色 */
@property (nonatomic, retain) UIColor * currentPageIndicatorColor;

/** 下方UILabel 默认隐藏 */
@property (nonatomic, retain) UILabel * label;
/** 下方label数组 */
@property (nonatomic, retain) NSMutableArray * labelArr;

/** 滚动时间间隔 */
@property (nonatomic) NSTimeInterval timeInterval;

/** 图片数组或者图片Url数组或者图片名数组 */
@property (nonatomic, retain) NSMutableArray * imageArr;

/** 代理 */
@property (nonatomic, weak) id <YBInfiniteScrollViewDelegate> delegate;


/** 初始化 */
+ (instancetype) shareInstanceWithFrame:(CGRect) frame delegate:(id <YBInfiniteScrollViewDelegate>) delegate timeInterval:(NSTimeInterval) timeInterval;

/** 开始自动滚动,默认自动开启 */
- (void) startAutoScroll;
/** 结束自动滚动 */
- (void) endAutoScroll;

@end
