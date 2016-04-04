//
//  UserDefalutManager.h
//  MetroSurround
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserDefalutManager : NSObject

+(UserDefalutManager *)sharedManager;
#define kIsTutorialAttention @"isTutorialAttention"
#define kIsGpsAttention @"isGpsAttention"


//チュートリアルをアテンションしたかどうか？（ユーザが拒否した際も確認したとみなす）
-(BOOL)getTutorialAttention;
-(void)setTutorialAttention:(BOOL)isView;

-(BOOL)getGpsAttention;
-(void)setGpsAttention:(BOOL)isView;

@end
