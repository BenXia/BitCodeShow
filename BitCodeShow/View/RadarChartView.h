//
//  RadarChartView.h
//  QQingCommon
//
//  Created by Ben on 16/4/22.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadarChartModel : NSObject

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *text;

- (instancetype)initWithValue:(CGFloat)value imageName:(NSString *)imageName text:(NSString *)text;

@end

@interface RadarChartView : UIView

- (void)setRadarChartModelsArray:(NSArray<RadarChartModel *> *)modelsArray;

@end


