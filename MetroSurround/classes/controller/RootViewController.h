//
//  RootViewController.h
//  MetroSurround
//
//  Created by as on 2015/05/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RootViewControllerDelegate <NSObject>

@optional
/**
 delegate Method
 */
-(void)didScrollViewController:(float)slideX curPageNum:(NSUInteger) curPageNum;


@end

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;


@property (nonatomic, weak) id<RootViewControllerDelegate> delegate;

@end

