//
//  HistogramView.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeModel.h"

@interface HistogramView : UIView

#pragma mark - UI relative properties
@property (nonatomic, assign) CGFloat topBottomEmptyHeight;
@property (nonatomic, assign) CGFloat graphLineWidth;
@property (nonatomic, strong) UIColor *graphLineColor;

@property (nonatomic, assign) CGFloat rightContentWidth;


- (void)setSellArray:(NSMutableArray *)sellArray
            buyArray:(NSMutableArray *)buyArray
        currentPrice:(CGFloat)currentPrice;

@end
