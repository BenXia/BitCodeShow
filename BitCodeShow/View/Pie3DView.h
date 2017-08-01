//
//  Pie3DView.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Pie3DView : UIView 

@property(nonatomic, assign) float spaceHeight;  //高度
@property(nonatomic, assign) float scaleY;
@property(nonatomic, retain) NSArray *titleArr;  //文字
@property(nonatomic, retain) NSArray *valueArr;  //值
@property(nonatomic, retain) NSArray *colorArr;  //颜色

@end
