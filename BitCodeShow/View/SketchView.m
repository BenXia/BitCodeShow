//
//  SketchView.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "SketchView.h"

#define GAP_BETWEEN_RIGHT_LABEL 10
#define RIGHT_LABEL_HEIGHT  20

@interface SketchView ()

@property (nonatomic, assign) CGFloat currentPrice;

@property (nonatomic, strong) NSMutableArray *pointStructArray;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat stepX;
@property (nonatomic, assign) CGFloat stepY;

@property (nonatomic, strong) NSMutableArray *extremePointStructArray;

@end

@implementation SketchView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultProperty];
    }
    return self;
}

- (void)setupDefaultProperty {
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.topBottomEmptyHeight = 10.0f;
//    self.graphPointRadius = 3.5f;
    self.graphLineWidth = 1.0f;
    self.graphLineColor = [UIColor whiteColor];
    
    self.rightContentWidth = 50;
    
    _pointStructArray = [NSMutableArray array];
    _extremePointStructArray = [NSMutableArray array];
}

- (void)setPriceArray:(NSMutableArray *)priceArray {
    _priceArray = priceArray;
    _currentPrice = [((PriceModel *)[_priceArray lastObject]).last floatValue];
    
    _pointStructArray = [NSMutableArray array];
    
    CGRect viewFrame = self.bounds;
    CGRect graphFrame = viewFrame;
    graphFrame.size.width -= self.rightContentWidth;
    
    graphFrame.origin.y += self.topBottomEmptyHeight;
    graphFrame.size.height -= self.topBottomEmptyHeight * 2;
    
    
    //Calculate stepX
    _stepX = 2;
    
    //Calculate stepY
    NSInteger validCount = 0;
    _maxValue = -FLT_MAX;
    _minValue = FLT_MAX;
    
    for (NSInteger i = 0; i < [_priceArray count]; i++) {
        float valueInArray = [((PriceModel *)[_priceArray objectAtIndex:i]).last floatValue];
        if (valueInArray != FLT_MAX) {
            validCount++;
            if (valueInArray > _maxValue) {
                _maxValue = valueInArray;
            }
            
            if (valueInArray < _minValue) {
                _minValue = valueInArray;
            }
        }
    }
    
    if ((validCount <= 1) || (_maxValue == _minValue)) {
        _stepY = 0;
    } else {
        _stepY = graphFrame.size.height / (_maxValue - _minValue);
    }
    
    CGFloat originXInGraph = 0;
    CGFloat originYInGraph = 0;
    CGFloat middleYPointValue = (_maxValue + _minValue)/2;
    
    //Calculate originXInGraph
    originXInGraph = _stepX / 2;
    
    //Calculate originYInGraph
    originYInGraph = graphFrame.origin.y + graphFrame.size.height / 2;
    
    //Generate point array used to draw graph
    for (NSInteger i = 0 ; i < [_priceArray count]; i++) {
        float valueInArray = [((PriceModel *)[_priceArray objectAtIndex:i]).last floatValue];
        if (valueInArray != FLT_MAX) {
            CGPoint point;
            point.x = originXInGraph + _stepX * i;
            point.y = originYInGraph + _stepY * (middleYPointValue - valueInArray);
            [_pointStructArray addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)setExtremePriceArray:(NSMutableArray *)extremePriceArray {
    _extremePriceArray = extremePriceArray;
    
    _extremePointStructArray = [NSMutableArray array];
    
    CGRect viewFrame = self.bounds;
    CGRect graphFrame = viewFrame;
    graphFrame.size.width -= self.rightContentWidth;
    
    graphFrame.origin.y += self.topBottomEmptyHeight;
    graphFrame.size.height -= self.topBottomEmptyHeight * 2;
    
    CGFloat originXInGraph = 0;
    CGFloat originYInGraph = 0;
    CGFloat middleYPointValue = (_maxValue + _minValue)/2;
    
    //Calculate originXInGraph
    originXInGraph = _stepX / 2;
    
    //Calculate originYInGraph
    originYInGraph = graphFrame.origin.y + graphFrame.size.height / 2;
    
    //Generate point array used to draw graph
    for (NSInteger i = 0 ; i < [_extremePriceArray count]; i++) {
        float valueInArray = [[_extremePriceArray objectAtIndex:i] floatValue];
        CGPoint point;
        point.x = originXInGraph + _stepX * (i + _priceArray.count);
        point.y = originYInGraph + _stepY * (middleYPointValue - valueInArray);
        [_extremePointStructArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    [self setNeedsDisplay];
}

- (void)drawString:(NSString *)string inRect:(CGRect)rect {
    if (!string) {
        return;
    }
    
    [[[NSAttributedString alloc] initWithString:string
                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont fontWithName:@"Helvetica Neue" size:11], NSFontAttributeName,
                                                 [UIColor whiteColor], NSForegroundColorAttributeName, nil]]
     drawInRect:rect];
}

- (void)drawRect:(CGRect)rect {
    {
        //draw three mark line
        CGRect viewFrame = self.bounds;
        CGRect graphFrame = viewFrame;
        graphFrame.size.width -= self.rightContentWidth;
        graphFrame.origin.y += self.topBottomEmptyHeight;
        graphFrame.size.height -= self.topBottomEmptyHeight * 2;
        
        CGRect topLineRect = CGRectMake(0, floor(graphFrame.origin.y), graphFrame.size.width, 1);
        CGRect midLineRect = CGRectMake(0, floor(graphFrame.origin.y + graphFrame.size.height/2), graphFrame.size.width, 1);
        CGRect bottomLineRect = CGRectMake(0, floor(graphFrame.origin.y + graphFrame.size.height), graphFrame.size.width, 1);
        
        UIImage *lineImage = [UIImage imageNamed:@"progress_line"];
        [lineImage drawInRect:topLineRect];
        [lineImage drawInRect:midLineRect];
        [lineImage drawInRect:bottomLineRect];
        
        //draw three value text
        CGRect topTextRect = CGRectMake(CGRectGetMaxX(graphFrame) + GAP_BETWEEN_RIGHT_LABEL,
                                        graphFrame.origin.y - RIGHT_LABEL_HEIGHT/2,
                                        self.rightContentWidth - GAP_BETWEEN_RIGHT_LABEL,
                                        RIGHT_LABEL_HEIGHT);
        CGRect midTextRect = CGRectMake(CGRectGetMaxX(graphFrame) + GAP_BETWEEN_RIGHT_LABEL,
                                        graphFrame.origin.y + graphFrame.size.height/2 - RIGHT_LABEL_HEIGHT/2,
                                        self.rightContentWidth - GAP_BETWEEN_RIGHT_LABEL,
                                        RIGHT_LABEL_HEIGHT);
        CGRect bottomTextRect = CGRectMake(CGRectGetMaxX(graphFrame) + GAP_BETWEEN_RIGHT_LABEL,
                                           graphFrame.origin.y + graphFrame.size.height - RIGHT_LABEL_HEIGHT/2,
                                           self.rightContentWidth - GAP_BETWEEN_RIGHT_LABEL,
                                           RIGHT_LABEL_HEIGHT);
        
        NSString *maxStr = [NSString stringWithFormat:@"%.2f", _maxValue];
        NSString *midStr = [NSString stringWithFormat:@"%.2f", (_maxValue + _minValue)/2];
        NSString *minStr = [NSString stringWithFormat:@"%.2f", _minValue];
        
        if ((_maxValue != _minValue) && (_maxValue != -FLT_MAX) && (_minValue != FLT_MAX)) {
            if (![maxStr isEqualToString:minStr]) {
                [self drawString:maxStr inRect:topTextRect];
                [self drawString:minStr inRect:bottomTextRect];
                
                if (![midStr isEqualToString:maxStr] && ![midStr isEqualToString:minStr]) {
                    [self drawString:midStr inRect:midTextRect];
                }
            } else {
                [self drawString:maxStr inRect:midTextRect];
            }
        } else if ((_maxValue == _minValue) && (_maxValue != -FLT_MAX) && (_minValue != FLT_MAX)) {
            [self drawString:maxStr inRect:midTextRect];
        }
    }
    
    NSInteger pointCount = [_pointStructArray count];
    if (pointCount > 0) {
        if (pointCount > 1) {
            //connect these point with line
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            [path moveToPoint:[((NSValue *)[_pointStructArray objectAtIndex:0]) CGPointValue]];
            
            for (NSInteger i = 1; i < pointCount; i++) {
                [path addLineToPoint:[((NSValue *)[_pointStructArray objectAtIndex:i]) CGPointValue]];
            }
            
            [path setLineWidth:self.graphLineWidth];
            [self.graphLineColor set];
            [path stroke];
        }
        
//        //draw all points' circle
//        for (NSInteger i = 0; i < pointCount; i++) {
//            CGPoint point = [((NSValue *)[_pointStructArray objectAtIndex:i]) CGPointValue];
//            
//            CGRect circleRect = CGRectMake(point.x - self.graphPointRadius, point.y - self.graphPointRadius, self.graphPointRadius * 2, self.graphPointRadius *2);
//            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:self.graphPointRadius];
//            [path setLineWidth:1];
//            [[UIColor whiteColor] set];
//            [path fill];
//            
//            [self.graphLineColor set];
//            [path stroke];
//        }
    }
    
    NSInteger extremePointCount = [_extremePointStructArray count];
    if (extremePointCount > 0) {
        for (NSInteger i = 0; i < extremePointCount; i++) {
            UIBezierPath *path = [UIBezierPath bezierPath];

            CGFloat extremePrice = [[_extremePriceArray objectAtIndex:i] floatValue];
            CGPoint startPoint = [((NSValue *)[_extremePointStructArray objectAtIndex:i]) CGPointValue];
            CGPoint endPoint = startPoint;
            endPoint.x -= (i + 1) * 10;

            [path moveToPoint:startPoint];
            [path addLineToPoint:endPoint];
            [path setLineWidth:1];
            if (extremePrice > _currentPrice) {
                [[UIColor greenColor] set];
            } else {
                [[UIColor redColor] set];
            }
            [path stroke];
        }
    }
}

@end
