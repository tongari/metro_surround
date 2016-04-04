//
//  ViewController.m
//  MetroSurround
//
//  Created by as on 2015/05/28.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "ViewController.h"
#import "RootViewController.h"
#import "MetroRailwayMasterManager.h"
#import "GlobalNavBar.h"
#import "UserDefalutManager.h"



@interface ViewController ()<RootViewControllerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *globalMenuScroller;
@property (weak, nonatomic) IBOutlet UIView *globalMenu;

@property (strong,nonatomic) NSMutableArray *globalNavPosX;
@property (strong,nonatomic) NSMutableArray *childButtons;
@property (strong,nonatomic) NSMutableArray *globalNavColor;

@property(assign,nonatomic)BOOL isInit;



@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //コンテナー内のVCを参照
    RootViewController *vc = self.childViewControllers[0];
    vc.delegate = self;
    
    
    NSArray *masterData = [[MetroRailwayMasterManager sharedManager] getAllData];
    self.globalNavColor = [NSMutableArray array];
    
    for(int i = 0; i<masterData.count; i++){
        [self.globalNavColor addObject:masterData[i][@"Color"]];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.alpha = 0;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if(!self.isInit){
        self.isInit = YES;
        [self adjestGlobalNav];        
    }
    
    [self setCustomEventNotification];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self removeCustomEventNotification];
}


/**
 *  カスタムイベント通知の設定
 */
-(void)setCustomEventNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTapGlobalNavButton:)
                                                 name:@"onTapGlobalNavButton"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationDidBecomeActive)
                                                 name:@"applicationDidBecomeActive"
                                               object:nil];
}

-(void)removeCustomEventNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"onTapGlobalNavButton"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"applicationDidBecomeActive"
                                                  object:nil];
}


/**
 *  フォアグランド復帰イベントハンドラ
 */
-(void)onApplicationDidBecomeActive{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.alpha = 0;
}


/**
 *  グローバルナビゲーションタップのイベントハンドラ
 *
 *  @param notification
 */
-(void)onTapGlobalNavButton:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
    
    int pageId = [info[@"pageId"] intValue];
    
    
    [self doGlobalNavSlide:pageId];
    [self offHighlityeGLobalNav:pageId];
}


/**
 *  グローバルナビゲーションの調整
 */
-(void)adjestGlobalNav{
    self.globalNavPosX = [NSMutableArray array];
    
    NSUInteger len = self.globalMenu.subviews.count;
    self.childButtons = [NSMutableArray array];
    
    UIView *child;
    
    for(int i = 0; i<len; i++ ){
        
        child = self.globalMenu.subviews[i];
        
        if([child isKindOfClass:[UIButton class]]){
            [self.globalNavPosX addObject:[NSNumber numberWithFloat:child.frame.origin.x]];
            [self.childButtons addObject:child];
            
            if(i == 0){
                child.backgroundColor = [[MetroRailwayMasterManager sharedManager]getColorCode:0 alphaValue:1];
            } else {
                child.backgroundColor = [UIColor clearColor];
            }
            
        }
        else if([child isKindOfClass:[GlobalNavBar class]]) {
            
            NSDictionary *color = self.globalNavColor[child.tag];
            float r = [color[@"r"] floatValue ] / 255.0f;
            float g = [color[@"g"] floatValue ] / 255.0f;
            float b = [color[@"b"] floatValue ] / 255.0f;
            [child viewWithTag:child.tag].backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
        }
    }
    
    float marginWidth = 0;
    float lastPosX = [self.globalNavPosX[self.globalNavPosX.count-1] floatValue];
    UIButton *lastButton = self.childButtons[self.childButtons.count-1];
    float lastButtonWidth = lastButton.frame.size.width;
    
    float globalNavWidth = marginWidth + lastPosX + lastButtonWidth;
    
    self.globalMenu.frame = CGRectMake(self.globalMenu.frame.origin.x,
                                       self.globalMenu.frame.origin.y,
                                       globalNavWidth,
                                       self.globalMenu.frame.size.height);
}


/**
 *  グローバルナビゲーションをスライド
 *
 *  @param curPageId
 */
-(void)doGlobalNavSlide:(int)curPageId{
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    float targetX = [self.globalNavPosX[curPageId] intValue];
    
    float lastNavPosX = self.globalMenu.frame.size.width - self.globalMenuScroller.frame.size.width;
    
    UIButton *tapedButton = self.childButtons[curPageId];
    float firstNavPosX = self.globalMenuScroller.frame.size.width - tapedButton.frame.size.width;
    
    if(targetX >= lastNavPosX){
        
        targetX = lastNavPosX;
    }
    else if(targetX < firstNavPosX){
        targetX = 0;
    }
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.globalMenuScroller setContentOffset:CGPointMake(targetX, 0.0f) animated:NO];
    } completion:nil];
    
}

/**
 *  グローバルナビのハイライトをオフにする
 *
 *  @param pageId
 */
-(void)offHighlityeGLobalNav:(int) pageId{
    
    
    UIButton *button;
    
    for(int i = 0; i<self.childButtons.count; i++){
        if(i != pageId){
            button = self.childButtons[i];
            button.backgroundColor = [UIColor clearColor];
        }
        
        
    }
}


#pragma mark - RootViewControllerDelegate method

-(void)didScrollViewController:(float)slideX curPageNum:(NSUInteger) curPageNum{
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float diffX = screenWidth - slideX;
    
    if(diffX == 0){        
        return;
    }
    
    
    NSUInteger addCountCoefficient = 1;
    
    //前のページに戻る場合
    if(diffX > 0){
        addCountCoefficient = -1;
    }
    
    NSInteger nextIndex = curPageNum + addCountCoefficient;

    
    if(nextIndex < 0){
        nextIndex = 0;
    }
    else if(nextIndex == self.globalNavPosX.count){
        nextIndex = self.globalNavPosX.count - 1;
    }

    
    float nextGlobalNavPosX = [self.globalNavPosX[nextIndex] floatValue];
    float curGlobalNavPosX = [self.globalNavPosX[curPageNum] floatValue];
    
    float globalMenuMargin =  nextGlobalNavPosX - curGlobalNavPosX;
    
    float coefficient = fabs(globalMenuMargin / screenWidth);
    
    float calcX = -1 * diffX * coefficient + curGlobalNavPosX;
    
    float firstNavPosX = [self.globalNavPosX[0] floatValue];
    
    float lastNavPosX = self.globalMenu.frame.size.width - self.globalMenuScroller.frame.size.width;
    
    float targetX = calcX;
    
    
    if( calcX > lastNavPosX ){
        targetX = lastNavPosX;
    }
    else if(calcX < firstNavPosX){
        targetX = firstNavPosX;
    }
    
    float alphaCoefficient = fabs(diffX/screenWidth);
    
    
    UIButton *nextButton = self.childButtons[nextIndex];
    UIButton *curButton = self.childButtons[curPageNum];
    
    NSDictionary *nextColor = self.globalNavColor[nextIndex];
    NSDictionary *curColor = self.globalNavColor[curPageNum];
    
    
    [self offHighlityeGLobalNav:(int)curPageNum];
    
    
    nextButton.backgroundColor = [UIColor colorWithRed:[nextColor[@"r"] floatValue]/255.0f
                                                 green:[nextColor[@"g"] floatValue]/255.0f
                                                  blue:[nextColor[@"b"] floatValue]/255.0f
                                                 alpha:alphaCoefficient];
    
    
    curButton.backgroundColor = [UIColor colorWithRed:[curColor[@"r"] floatValue]/255.0f
                                                green:[curColor[@"g"] floatValue]/255.0f
                                                 blue:[curColor[@"b"] floatValue]/255.0f
                                                alpha:1-alphaCoefficient];
    
    
    [self.globalMenuScroller setContentOffset:CGPointMake(targetX , 0.0f) animated:NO];
}

@end
