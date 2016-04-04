//
//  MapCarCompositDetailHeader.m
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapCarCompositDetailHeader.h"

@implementation MapCarCompositDetailHeader

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"MapCarCompositDetailHeader" owner:self options:nil];
        self.customContentView.frame = self.contentView.bounds;
        self.customContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.customContentView];
    }
    
    return self;
}

@end
