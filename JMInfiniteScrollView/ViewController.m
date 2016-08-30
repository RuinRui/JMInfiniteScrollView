//
//  ViewController.m
//  JMInfiniteScrollView
//
//  Created by FBI on 16/8/30.
//  Copyright © 2016年 君陌. All rights reserved.
//

#import "ViewController.h"

#import "YBInfiniteScrollView.h"
#import <YYKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YBInfiniteScrollView * scrollView = [YBInfiniteScrollView shareInstanceWithFrame:CGRectMake(0, 20, kScreenWidth, 300) delegate:self timeInterval:3.0];
    scrollView.imageArr = [NSMutableArray arrayWithArray:@[@"f1", @"f2", @"f3", @"f4", @"f5"]];
    [self.view addSubview:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
