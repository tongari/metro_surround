//
//  ModelController.h
//  MetroSurround
//
//  Created by as on 2015/05/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  プロトコル
 */
@protocol ModelControllerDelegate <NSObject>

@optional
/**
 delegate Method
 */
- (void)didChangeViewController:(NSUInteger) curPageNum;

@end

@class StationListViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (StationListViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(StationListViewController *)viewController;

@property (nonatomic, weak) id<ModelControllerDelegate> delegate;

@end

