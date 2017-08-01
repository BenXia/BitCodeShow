//
//  PieView.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "PieView.h"

@implementation PieModel

- (instancetype)initWithColor:(UIColor *)color value:(CGFloat)value text:(NSString *)text {
    self = [super init];
    if (self) {
        self.color = color;
        self.value = value;
        self.text = text;
    }
    return self;
}

@end

@interface PieView ()

@property (nonatomic, strong) NSArray<PieModel *> *valueArray;

@property (nonatomic, strong) CAShapeLayer *animationLayer;//用来显示动画的layer
@property (nonatomic, assign) CGFloat pieRadius;
@property (nonatomic, assign) CGPoint layerCenter;

@property (nonatomic, strong) NSArray *percentArray;//每个value所占总体的比例
@property (nonatomic, strong) NSArray *startAngleArray;//每个value对应的startAngle
@property (nonatomic, strong) NSArray *endAngleArray;//每个value对应的endAngle
@property (nonatomic, strong) NSArray *subLayerArray;

@end

@implementation PieView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)setValuesArray:(NSArray<PieModel *> *)valueArray {
    for (CALayer *layer in self.subLayerArray) {
        [layer removeFromSuperlayer];
    }
    self.subLayerArray = nil;
    
    NSArray *labelsArray = [self subviews];
    for (UIView *subview in labelsArray) {
        [subview removeFromSuperview];
    }
    
    _valueArray = valueArray;
    
    [self commonInit];
}

#pragma mark - Private methods

- (void)commonInit {
    [self setupDefault];
    [self createLayers];
    [self createDescriptionLabels];
//    [self createAnimationLayer];
//    [self startAnimation];
}

- (void)setupDefault {
    self.backgroundColor = [UIColor clearColor];
    
    self.pieRadius = CGRectGetWidth(self.bounds) / 2;
    self.layerCenter = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
    CGFloat total = [[self.valueArray valueForKeyPath:@"@sum.value"] floatValue];
    NSMutableArray *startAngleArray = [NSMutableArray array];
    NSMutableArray *endAngleArray = [NSMutableArray array];
    NSMutableArray *percentArray = [NSMutableArray array];
    CGFloat currentSum = 0;
    for (PieModel *model in self.valueArray) {
        CGFloat value = model.value;
        NSNumber *tempStartAngle = @(currentSum / total * 2 * M_PI - 0.5 *M_PI);
        [startAngleArray addObject:tempStartAngle];
        currentSum = currentSum + value;
        NSNumber *tempEndAngle = @(currentSum / total * 2 * M_PI - 0.5 *M_PI);
        [endAngleArray addObject:tempEndAngle];
        NSNumber *percent = @(value / total);
        [percentArray addObject:percent];
    }
    self.startAngleArray = startAngleArray;
    self.endAngleArray = endAngleArray;
    self.percentArray = percentArray;
}

- (void)createLayers {
    NSMutableArray *subLayerArray = [NSMutableArray array];
    for (int i = 0; i < self.valueArray.count; i++) {
        CAShapeLayer *subLayer = [self subPieLayerWithIndex:i];
        [self.layer addSublayer:subLayer];
        [subLayerArray addObject:subLayer];
    }
    self.subLayerArray = subLayerArray;
}

- (CAShapeLayer *)subPieLayerWithIndex:(NSInteger)index {
    CGFloat startAngle = [self.startAngleArray[index] floatValue];
    CGFloat endAngle = [self.endAngleArray[index] floatValue];
    PieModel *model = self.valueArray[index];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = 0;
    shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    shapeLayer.fillColor = model.color.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.layerCenter];
    [path addArcWithCenter:self.layerCenter radius:self.pieRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path addLineToPoint:self.layerCenter];
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

- (void)createDescriptionLabels {
    NSMutableArray *descriptionLabelArray = [NSMutableArray array];
    for (int i = 0; i < self.valueArray.count; i++) {
        UILabel *label = [self descriptionLabelWithIndex:i];
        [self addSubview:label];
        [descriptionLabelArray addObject:label];
    }
}

- (UILabel *)descriptionLabelWithIndex:(NSInteger)index {
    CGFloat centerAngle = ([self.startAngleArray[index] floatValue]+ [self.endAngleArray[index] floatValue]) / 2;//某个扇形的中心的角度
    CGFloat centerX = self.pieRadius + cos(centerAngle) * self.pieRadius / 2;
    CGFloat centerY = self.pieRadius + sin(centerAngle) * self.pieRadius / 2;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    PieModel *model = [self.valueArray objectAtIndex:index];
    if (model.text) {
        label.text = model.text;
    } else {
        label.text = [NSString stringWithFormat:@"%.2f%%", [self.percentArray[index] floatValue] * 100];
    }
    label.font = [UIFont systemFontOfSize:8];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.center = CGPointMake(centerX, centerY);
    return label;
}

- (void)createAnimationLayer {
    CAShapeLayer *animationLayer = [CAShapeLayer layer];
    animationLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.layerCenter radius:self.pieRadius / 2 startAngle:-0.5 *M_PI endAngle:1.5 * M_PI clockwise:YES];
    animationLayer.path = path.CGPath;
    animationLayer.lineWidth = self.pieRadius;
    animationLayer.strokeColor = [UIColor greenColor].CGColor;
    animationLayer.fillColor = [UIColor clearColor].CGColor;
    animationLayer.strokeEnd = 0;
    self.layer.mask = animationLayer;
    self.animationLayer = animationLayer;
}

- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1;
    [self.animationLayer addAnimation:animation forKey:@"kClockAnimation"];
}

#pragma mark - buttonAction 

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:sender.view];
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    NSInteger index = -1;
    
    for (int i = 0; i < self.subLayerArray.count; i ++) {
        CAShapeLayer *shapeLayer = self.subLayerArray[i];
        if (CGPathContainsPoint(shapeLayer.path, &transform, location, 0)) {
            index = i;
            break;
        }
    }
    if ([self.delegate respondsToSelector:@selector(lxmPieView:didSelectSectionAtIndex:)]
        && index >= 0) {
        [self.delegate lxmPieView:self didSelectSectionAtIndex:index];
    }
}

@end




