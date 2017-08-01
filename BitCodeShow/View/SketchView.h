//
//  SketchView.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceModel.h"

@interface SketchView : UIView

@property (nonatomic, strong) NSMutableArray *priceArray;
@property (nonatomic, strong) NSMutableArray *extremePriceArray;

#pragma mark - UI relative properties
@property (nonatomic, assign) CGFloat topBottomEmptyHeight;
//@property (nonatomic, assign) CGFloat graphPointRadius;
@property (nonatomic, assign) CGFloat graphLineWidth;
@property (nonatomic, strong) UIColor *graphLineColor;

@property (nonatomic, assign) CGFloat rightContentWidth;

@end