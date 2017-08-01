//
//  HistogramView.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "HistogramView.h"

#define GAP_BETWEEN_RIGHT_LABEL 10
#define RIGHT_LABEL_HEIGHT  20

@interface HistogramView ()

@property (nonatomic, strong) NSMutableArray *buyArray;
@property (nonatomic, strong) NSMutableArray *sellArray;
@property (nonatomic, assign) CGFloat currentPrice;

@property (nonatomic, strong) NSMutableArray *buyPointStructArray;
@property (nonatomic, strong) NSMutableArray *sellPointStructArray;
@property (nonatomic, strong) NSMutableArray *xPriceLevelPointStructArray;

@property (nonatomic, strong) NSMutableArray *bigAmountBuyPointStructArray;
@property (nonatomic, strong) NSMutableArray *bigAmountSellPointStructArray;
@property (nonatomic, strong) NSMutableArray *bigAmountBuyPriceArray;
@property (nonatomic, strong) NSMutableArray *bigAmountSellPriceArray;

@property (nonatomic, assign) CGFloat maxBuyAmountValue;
@property (nonatomic, assign) CGFloat maxBuyPriceValue;
@property (nonatomic, assign) CGPoint maxBuyPoint;
@property (nonatomic, assign) CGFloat maxSellAmountValue;
@property (nonatomic, assign) CGFloat maxSellPriceValue;
@property (nonatomic, assign) CGPoint maxSellPoint;

@property (nonatomic, assign) CGFloat minXValue;
@property (nonatomic, assign) CGFloat maxXValue;

@property (nonatomic, assign) CGFloat originYInGraph;

@end

@implementation HistogramView

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
    self.graphLineWidth = 2.0f;
    
    self.rightContentWidth = 50;
    
    _buyPointStructArray = [NSMutableArray array];
    _sellPointStructArray = [NSMutableArray array];
    _xPriceLevelPointStructArray = [NSMutableArray array];
    
    _bigAmountBuyPointStructArray = [NSMutableArray array];
    _bigAmountSellPointStructArray = [NSMutableArray array];
    _bigAmountBuyPriceArray = [NSMutableArray array];
    _bigAmountSellPriceArray = [NSMutableArray array];
}

- (void)setSellArray:(NSMutableArray *)sellArray
            buyArray:(NSMutableArray *)buyArray
        currentPrice:(CGFloat)currentPrice {
    _sellArray = sellArray;
    _buyArray = buyArray;
    _currentPrice = currentPrice;
    
    _sellPointStructArray = [NSMutableArray array];
    _buyPointStructArray = [NSMutableArray array];
    _xPriceLevelPointStructArray = [NSMutableArray array];
    _bigAmountSellPointStructArray = [NSMutableArray array];
    _bigAmountBuyPointStructArray = [NSMutableArray array];
    _bigAmountSellPriceArray = [NSMutableArray array];
    _bigAmountBuyPriceArray = [NSMutableArray array];
    
    
    NSInteger sellArrayCount = [_sellArray count];
    NSInteger buyArrayCount = [_buyArray count];
    
    CGFloat stepX = 0;
    CGFloat stepY = 0;
    
    CGRect viewFrame = self.bounds;
    CGRect graphFrame = viewFrame;
    graphFrame.size.width -= self.rightContentWidth;
    
    graphFrame.origin.y += self.topBottomEmptyHeight;
    graphFrame.size.height -= self.topBottomEmptyHeight * 2;
    
    
    //Calculate stepX
    CGFloat minSellPrice = [((TradeModel *)[_sellArray firstObject]).price floatValue] - currentPrice;
    CGFloat maxSellPrice = [((TradeModel *)[_sellArray lastObject]).price floatValue] - currentPrice;
    CGFloat minBuyPrice = currentPrice - [((TradeModel *)[_buyArray firstObject]).price floatValue];
    CGFloat maxBuyPrice = currentPrice - [((TradeModel *)[_buyArray lastObject]).price floatValue];
    CGFloat minValue = MIN(minBuyPrice, minSellPrice);
    CGFloat maxValue = MAX(maxBuyPrice, maxSellPrice);
    if (currentPrice < minValue) {
        minValue = currentPrice;
    }
    
    CGFloat maxXGap = maxValue - minValue;
    if (maxXGap == 0) {
        maxXGap = 1;
    }
    stepX = (graphFrame.size.width - 30) / maxXGap;
    _minXValue = minValue;
    _maxXValue = minValue + maxXGap;
    
    //Calculate stepY
    NSInteger maxSellAmountIndex = 0;
    NSInteger maxBuyAmountIndex = 0;
    _maxSellAmountValue = -FLT_MAX;
    _maxBuyAmountValue = -FLT_MAX;
    
    for (NSInteger i = 0; i < sellArrayCount; i++) {
        float valueInArray = [((TradeModel *)[_sellArray objectAtIndex:i]).amount floatValue];
        if (valueInArray > _maxSellAmountValue) {
            _maxSellAmountValue = valueInArray;
            maxSellAmountIndex = i;
        }
    }
    
    for (NSInteger i = 0; i < buyArrayCount; i++) {
        float valueInArray = [((TradeModel *)[_buyArray objectAtIndex:i]).amount floatValue];
        if (valueInArray > _maxBuyAmountValue) {
            _maxBuyAmountValue = valueInArray;
            maxBuyAmountIndex = i;
        }
    }

    if (_maxSellAmountValue == -FLT_MAX) {
        _maxSellAmountValue = 1;
    }
    
    if (_maxBuyAmountValue == -FLT_MAX) {
        _maxBuyAmountValue = 1;
    }
    
    stepY = graphFrame.size.height / (_maxSellAmountValue + _maxBuyAmountValue);
    
    CGFloat originXInGraph = 0;
    CGFloat originYInGraph = 0;
    CGFloat originYPointValue = 0;
    
    //Calculate originXInGraph
    originXInGraph = stepX / 2;
    
    //Calculate originYInGraph
    originYInGraph = graphFrame.origin.y + graphFrame.size.height * _maxSellAmountValue / (_maxBuyAmountValue + _maxSellAmountValue);
    
    //Generate point array used to draw graph
    for (NSInteger i = 0 ; i < sellArrayCount; i++) {
        float priceValue = [((TradeModel *)[_sellArray objectAtIndex:i]).price floatValue];
        float amountValue = [((TradeModel *)[_sellArray objectAtIndex:i]).amount floatValue];
        
        CGPoint point;
        CGFloat xPriceValue = (priceValue - currentPrice - _minXValue);
        point.x = originXInGraph + stepX * xPriceValue;
        point.y = originYInGraph + stepY * (originYPointValue - amountValue);
        
        if (i == maxSellAmountIndex) {
            _maxSellPoint = point;
            _maxSellPriceValue = priceValue;
        }
        
        if ((xPriceValue < 2) && (amountValue > 20)) {
            [_bigAmountSellPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountSellPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        } else if ((xPriceValue < 5) && (amountValue > 50)) {
            [_bigAmountSellPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountSellPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        } else if (amountValue > 100) {
            [_bigAmountSellPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountSellPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        }
        
        [_sellPointStructArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    for (NSInteger i = 0 ; i < buyArrayCount; i++) {
        float priceValue = [((TradeModel *)[_buyArray objectAtIndex:i]).price floatValue];
        float amountValue = [((TradeModel *)[_buyArray objectAtIndex:i]).amount floatValue];
        
        CGPoint point;
        CGFloat xPriceValue = (currentPrice - priceValue - _minXValue);
        point.x = originXInGraph + stepX * xPriceValue;
        point.y = originYInGraph + stepY * (originYPointValue + amountValue);
        
        if (i == maxBuyAmountIndex) {
            _maxBuyPoint = point;
            _maxBuyPriceValue = priceValue;
        }
        
        if ((xPriceValue < 2) && (amountValue > 20)) {
            [_bigAmountBuyPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountBuyPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        } else if ((xPriceValue < 5) && (amountValue > 50)) {
            [_bigAmountBuyPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountBuyPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        } else if (amountValue > 100) {
            [_bigAmountBuyPointStructArray addObject:[NSValue valueWithCGPoint:point]];
            [_bigAmountBuyPriceArray addObject:[NSNumber numberWithFloat:priceValue]];
        }
        
        [_buyPointStructArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    for (NSInteger i = 0 ; i < 5; i++) {
        CGPoint point;
        point.x = originXInGraph + stepX * i;
        point.y = originYInGraph;
        [_xPriceLevelPointStructArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    _originYInGraph = originYInGraph;
    
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
    CGRect viewFrame = self.bounds;
    CGRect graphFrame = viewFrame;
    graphFrame.size.width -= self.rightContentWidth;
    graphFrame.origin.y += self.topBottomEmptyHeight;
    graphFrame.size.height -= self.topBottomEmptyHeight * 2;
    
    {
        //draw three mark line
        CGRect topLineRect = CGRectMake(0, floor(graphFrame.origin.y), graphFrame.size.width, 1);
        CGRect midLineRect = CGRectMake(0, floor(graphFrame.origin.y + graphFrame.size.height * _maxSellAmountValue / (_maxSellAmountValue + _maxBuyAmountValue)), graphFrame.size.width, 1);
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
                                        graphFrame.origin.y + graphFrame.size.height * _maxSellAmountValue / (_maxSellAmountValue + _maxBuyAmountValue) - RIGHT_LABEL_HEIGHT/2,
                                        self.rightContentWidth - GAP_BETWEEN_RIGHT_LABEL,
                                        RIGHT_LABEL_HEIGHT);
        CGRect bottomTextRect = CGRectMake(CGRectGetMaxX(graphFrame) + GAP_BETWEEN_RIGHT_LABEL,
                                           graphFrame.origin.y + graphFrame.size.height - RIGHT_LABEL_HEIGHT/2,
                                           self.rightContentWidth - GAP_BETWEEN_RIGHT_LABEL,
                                           RIGHT_LABEL_HEIGHT);
        
        CGRect originXPriceRect = CGRectMake(0,
                                             graphFrame.origin.y + graphFrame.size.height * _maxSellAmountValue / (_maxSellAmountValue + _maxBuyAmountValue) - RIGHT_LABEL_HEIGHT,
                                             100, 20);
        CGRect sellTextRect = CGRectMake(0, graphFrame.origin.y + graphFrame.size.height * _maxSellAmountValue / ((_maxSellAmountValue + _maxBuyAmountValue) * 2) - 10,
                                             100, 20);
        CGRect buyTextRect = CGRectMake(0, graphFrame.origin.y + graphFrame.size.height * (1 - _maxBuyAmountValue / ((_maxSellAmountValue + _maxBuyAmountValue) * 2)) - 10,
                                             100, 20);
        
        
        NSString *maxStr = [NSString stringWithFormat:@"%.2f", _maxSellAmountValue];
        NSString *midStr = @"  0.00";
        NSString *minStr = [NSString stringWithFormat:@"%.2f", _maxBuyAmountValue];
        
        NSString *minXStr = [NSString stringWithFormat:@"%.2f", _minXValue + _currentPrice];
        
        [self drawString:maxStr inRect:topTextRect];
        [self drawString:midStr inRect:midTextRect];
        [self drawString:minStr inRect:bottomTextRect];
        [self drawString:minXStr inRect:originXPriceRect];
        [self drawString:@"卖" inRect:sellTextRect];
        [self drawString:@"买" inRect:buyTextRect];
    }
    
    NSInteger sellPointCount = [_sellPointStructArray count];
    NSInteger buyPointCount = [_buyPointStructArray count];
    NSInteger priceLevelCount = [_xPriceLevelPointStructArray count];
    
    if (sellPointCount > 1) {
        //connect these point with line
        for (NSInteger i = 0; i < sellPointCount; i++) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint startPoint = [((NSValue *)[_sellPointStructArray objectAtIndex:i]) CGPointValue];
            CGPoint endPoint = startPoint;
            endPoint.y = _originYInGraph;
            
            [path moveToPoint:startPoint];
            [path addLineToPoint:endPoint];
            
            [path setLineWidth:self.graphLineWidth];
            [[UIColor greenColor] set];
            [path stroke];
        }
        
        NSInteger bigSellArrayCount = [_bigAmountSellPriceArray count];
        for (NSInteger j = 0; j < bigSellArrayCount; j++) {
            CGPoint bigSellPoint = [((NSValue *)[_bigAmountSellPointStructArray objectAtIndex:j]) CGPointValue];
            CGRect bigSellPriceRect = CGRectMake(bigSellPoint.x,
                                                 graphFrame.origin.y - self.topBottomEmptyHeight + j * 20,
                                                 100, 20);
            NSString *bigSellPriceStr = [NSString stringWithFormat:@"%.2f", [[_bigAmountSellPriceArray objectAtIndex:j] floatValue]];
            [self drawString:bigSellPriceStr inRect:bigSellPriceRect];
        }
        
        //        CGRect maxSellPriceRect = CGRectMake(_maxSellPoint.x,
        //                                             graphFrame.origin.y + graphFrame.size.height + _topBottomEmptyHeight - 20,
        //                                             100, 20);
        //        NSString *maxSellPriceStr = [NSString stringWithFormat:@"%.2f", _maxSellPriceValue];
        //        [self drawString:maxSellPriceStr inRect:maxSellPriceRect];
    }
    
    if (buyPointCount > 1) {
        //connect these point with line
        for (NSInteger i = 0; i < buyPointCount; i++) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint startPoint = [((NSValue *)[_buyPointStructArray objectAtIndex:i]) CGPointValue];
            CGPoint endPoint = startPoint;
            endPoint.y = _originYInGraph;
            
            [path moveToPoint:startPoint];
            [path addLineToPoint:endPoint];
            
            [path setLineWidth:self.graphLineWidth];
            [[UIColor redColor] set];
            [path stroke];
        }
        
        NSInteger bigBuyArrayCount = [_bigAmountBuyPriceArray count];
        for (NSInteger j = 0; j < bigBuyArrayCount; j++) {
            CGPoint bigBuyPoint = [((NSValue *)[_bigAmountBuyPointStructArray objectAtIndex:j]) CGPointValue];
            CGRect bigBuyPriceRect = CGRectMake(bigBuyPoint.x,
                                                graphFrame.origin.y + graphFrame.size.height + _topBottomEmptyHeight - 20 - j * 20 ,
                                                100, 20);
            NSString *bigBuyPriceStr = [NSString stringWithFormat:@"%.2f", [[_bigAmountBuyPriceArray objectAtIndex:j] floatValue]];
            [self drawString:bigBuyPriceStr inRect:bigBuyPriceRect];
        }
        
//        CGRect maxBuyPriceRect = CGRectMake(_maxBuyPoint.x,
//                                             graphFrame.origin.y - self.topBottomEmptyHeight,
//                                             100, 20);
//        NSString *maxBuyPriceStr = [NSString stringWithFormat:@"%.2f", _maxBuyPriceValue];
//        [self drawString:maxBuyPriceStr inRect:maxBuyPriceRect];
    }
    
    if (priceLevelCount > 1) {
        //draw all points' circle
        for (NSInteger i = 0; i < priceLevelCount; i++) {
            CGPoint point = [((NSValue *)[_xPriceLevelPointStructArray objectAtIndex:i]) CGPointValue];

            CGRect circleRect = CGRectMake(point.x - 2, point.y - 2, 4, 4);
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:2];
            [path setLineWidth:1];
            [[UIColor whiteColor] set];
            [path fill];
        }
    }
}

@end
