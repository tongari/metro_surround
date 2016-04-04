//
//  RootViewController.m
//  MetroSurround
//
//  Created by as on 2015/05/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "RootViewController.h"
#import "ModelController.h"
#import "StationListViewController.h"


@interface RootViewController ()<ModelControllerDelegate,UIScrollViewDelegate>

@property (readonly, strong, nonatomic) ModelController *modelController;
@property(assign,nonatomic) NSUInteger curPageNum;


@property (nonatomic) UIScrollView *pageScrollView;

@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    
    self.curPageNum = 0;
    
    
    //ページビューコントローラーの生成
    self.pageViewController = [[UIPageViewController alloc]
                               //スライド式
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
//                               initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                               //水平に動く
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
    
    //委譲される
    self.pageViewController.delegate = self;
    
    //表示するVC
    StationListViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // 管理クラスを設定
    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    // ジェスチャー設定
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    //委譲先を自分に
    self.modelController.delegate = self;
    
    [self syncScrollView];
    
    [self setCustomEventNotification];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)syncScrollView {
    
    for (UIView* view in self.pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

//%%% method is called when any of the pages moves.
//It extracts the xcoordinate from the center point and instructs the selection bar to move accordingly
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.delegate didScrollViewController:scrollView.contentOffset.x curPageNum:self.curPageNum];
}


- (ModelController *)modelController {
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}


#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}


#pragma mark - ModelController delegate methods

-(void)didChangeViewController:(NSUInteger)curPageNum{

    self.curPageNum = curPageNum;
}


/**
 *  カスタムイベント通知の設定
 */
-(void)setCustomEventNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTapGlobalNavButton:)
                                                 name:@"onTapGlobalNavButton"
                                               object:nil];
}

-(void)onTapGlobalNavButton:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
    
    int pageId = [info[@"pageId"] intValue];
    
    
    StationListViewController *viewController = [self.modelController viewControllerAtIndex:pageId storyboard:self.storyboard];
    NSArray *viewControllers = @[viewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}




@end
