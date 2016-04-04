//
//  InfoViewController.m
//  MetroSurround
//
//  Created by as on 2015/06/10.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *infoScrollArea;
@property (weak, nonatomic) IBOutlet UIView *infoScrollContent;

@property (weak, nonatomic) IBOutlet UILabel *howtoTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *step2TextLabel;
@property (weak, nonatomic) IBOutlet UILabel *cautionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *map1_1Label;
@property (weak, nonatomic) IBOutlet UILabel *map_1_2Label;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.infoScrollArea.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self labelSpacing:self.howtoTextLabel height:20.0f inText:self.howtoTextLabel.text];
    
    [self labelSpacing:self.step2TextLabel height:20.0f inText:self.step2TextLabel.text];
    
    [self labelSpacing:self.cautionTextLabel height:20.0f inText:self.cautionTextLabel.text];
    
    [self labelSpacing:self.map1_1Label height:20.0f inText:self.map1_1Label.text];
    
    [self labelSpacing:self.map_1_2Label height:20.0f inText:self.map_1_2Label.text];
}


// 複数行あるUILable の高さを変更
- (void)labelSpacing:(UILabel *)label height:(float)height inText:(NSString *)inText
{
    
    // パラグラフスタイルにlineHeightをセット
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    paragrahStyle.minimumLineHeight = height;
    paragrahStyle.maximumLineHeight = height;
    
    // NSAttributedStringを生成してパラグラフスタイルをセット
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:inText];
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:paragrahStyle
                           range:NSMakeRange(0, attributedText.length)];
    label.attributedText = attributedText;
}

#pragma mark UIScrollViewDelegate Method
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(0.0, origin.y)];
}


@end
