//
//  CarCompositHeader.m
//  MetroSurround
//
//  Created by as on 2015/06/07.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "CarCompositHeader.h"

@implementation CarCompositHeader


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"CarCompositHeader" owner:self options:nil];
        self.customContentView.frame = self.contentView.bounds;
        self.customContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.customContentView];
    }
    
    return self;
}

@end
