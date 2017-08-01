//
//  PieView.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieView;
@protocol PieViewDelegate <NSObject>
- (void)lxmPieView:(PieView *)pieView didSelectSectionAtIndex:(NSInteger)index;
@end

@interface PieModel : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithColor:(UIColor *)color value:(CGFloat)value text:(NSString *)text;

@end

@interface PieView : UIView

@property (nonatomic, weak) id<PieViewDelegate> delegate;

- (void)setValuesArray:(NSArray<PieModel *> *)valueArray;

@end




