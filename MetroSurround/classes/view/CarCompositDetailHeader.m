//
//  ;
//  MetroSurround
//
//  Created by as on 2015/06/08.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "CarCompositDetailHeader.h"

@implementation CarCompositDetailHeader

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"CarCompositDetailHeader" owner:self options:nil];
        self.customContentView.frame = self.contentView.bounds;
        self.customContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.customContentView];
    }

    return self;
}

@end
