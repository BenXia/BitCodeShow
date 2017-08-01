//
//  RadarChartView.m
//  QQingCommon
//
//  Created by Ben on 16/4/22.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "RadarChartView.h"

static const CGFloat kRadarCornerRadiusGap = 40;
static const CGFloat kTextCornerRadiusGap = 15;
static const CGFloat kInsideOriginCornerRaius = 2;
static const CGFloat kRadarImageWidthHeight = 22;
static const CGFloat kVerticalGapBetweenImageAndTitle = 4;

@implementation RadarChartModel

- (instancetype)initWithValue:(CGFloat)value imageName:(NSString *)imageName text:(NSString *)text {
    if (self = [super init]) {
        self.value = value;
        self.imageName = imageName;
        self.text = text;
    }
    return self;
}

@end


@interface RadarChartView ()

@property (nonatomic, strong) NSArray<RadarChartModel *> *modelsArray;

@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, strong) NSMutableArray *imagePointStructArray;
@property (nonatomic, strong) NSMutableArray *outsidePointStructArray;
@property (nonatomic, strong) NSMutableArray *insidePointStructArray;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *chartFillColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

@end

@implementation RadarChartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultConfiguration];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultConfiguration];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)setRadarChartModelsArray:(NSArray<RadarChartModel *> *)modelsArray {
    _modelsArray = modelsArray;
    
    _imagePointStructArray = [NSMutableArray array];
    _outsidePointStructArray = [NSMutableArray array];
    _insidePointStructArray = [NSMutableArray array];
    
    if (_modelsArray.count == 0) {
        assert(false);
        return;
    }
    
    CGRect viewFrame = self.bounds;
    CGFloat maxCornerRadius = MIN(viewFrame.size.width, viewFrame.size.height) / 2;
    CGFloat polygonCornerRadius = maxCornerRadius - kRadarCornerRadiusGap;
    CGFloat insidePolygonCornerRadius = maxCornerRadius - kRadarCornerRadiusGap - kInsideOriginCornerRaius;
    CGFloat textCornerRadius = maxCornerRadius - kTextCornerRadiusGap;
    self.centerPoint = self.center;
    
    if (polygonCornerRadius < 10) {
        assert(false);
        return;
    }
    
    CGFloat angleStep = 2 * M_PI / [_modelsArray count];
    CGFloat startAngle = - M_PI_2;
    
    // Generate point array used to draw graph
    for (NSInteger i = 0 ; i < [_modelsArray count]; i++) {
        CGPoint textPoint = CGPointMake(self.centerPoint.x + cos(startAngle) * textCornerRadius,
                                        self.centerPoint.y + sin(startAngle) * textCornerRadius);
        [_imagePointStructArray addObject:[NSValue valueWithCGPoint:textPoint]];
        
        CGPoint outsidePoint = CGPointMake(self.centerPoint.x + cos(startAngle) * polygonCornerRadius,
                                           self.centerPoint.y + sin(startAngle) * polygonCornerRadius);
        [_outsidePointStructArray addObject:[NSValue valueWithCGPoint:outsidePoint]];
        
        
        float valueInArray = ((RadarChartModel *)[_modelsArray objectAtIndex:i]).value;
        CGPoint insidePoint = CGPointMake(self.centerPoint.x + cos(startAngle) * (kInsideOriginCornerRaius + insidePolygonCornerRadius * valueInArray),
                                          self.centerPoint.y + sin(startAngle) * (kInsideOriginCornerRaius + insidePolygonCornerRadius * valueInArray));
            
        [_insidePointStructArray addObject:[NSValue valueWithCGPoint:insidePoint]];
        
        startAngle += angleStep;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Private methods

- (void)setupDefaultConfiguration {
    self.backgroundColor = [UIColor clearColor];
    
    self.lineColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:0.7];
    self.lineWidth = 1;
    self.chartFillColor = [UIColor colorWithRed:61.0/255 green:204.0/255 blue:119.0/255 alpha:0.7];
    self.textColor = [UIColor whiteColor];
    self.textFont = [UIFont fontWithName:@"Helvetica Neue" size:11];
    
    _imagePointStructArray = [NSMutableArray array];
    _outsidePointStructArray = [NSMutableArray array];
    _insidePointStructArray = [NSMutableArray array];
}

- (void)drawString:(NSString *)string inRect:(CGRect)rect {
    if (!string) {
        return;
    }
    
    [[[NSAttributedString alloc] initWithString:string
                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 self.textFont, NSFontAttributeName,
                                                 self.textColor, NSForegroundColorAttributeName, nil]]
     drawInRect:rect];
}

#pragma mark - Overridden methods

- (void)drawRect:(CGRect)rect {
    NSInteger pointCount = [_imagePointStructArray count];
    for (NSInteger i = 0; i < pointCount; i++) {
        RadarChartModel *subModel = [_modelsArray objectAtIndex:i];
        
        CGPoint imagePoint = [((NSValue *)[_imagePointStructArray objectAtIndex:i]) CGPointValue];
        CGRect imageRect = CGRectMake(imagePoint.x - kRadarImageWidthHeight / 2, imagePoint.y - kRadarImageWidthHeight / 2, kRadarImageWidthHeight, kRadarImageWidthHeight);
        [[UIImage imageNamed:subModel.imageName] drawInRect:imageRect];
        
        CGSize textSize = [subModel.text textSizeForOneLineWithFont:self.textFont];
        CGRect titleRect = CGRectMake(imagePoint.x - textSize.width / 2, imagePoint.y + kRadarImageWidthHeight / 2 + kVerticalGapBetweenImageAndTitle, textSize.width, textSize.height);
        [self drawString:subModel.text inRect:titleRect];
    }
    
    pointCount = [_outsidePointStructArray count];
    if (pointCount > 0) {
        if (pointCount > 1) {
            //connect these point with line
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            [path moveToPoint:[((NSValue *)[_outsidePointStructArray objectAtIndex:0]) CGPointValue]];
            
            for (NSInteger i = 1; i < pointCount; i++) {
                [path addLineToPoint:[((NSValue *)[_outsidePointStructArray objectAtIndex:i]) CGPointValue]];
            }
            
            [path closePath];
            
            [path setLineWidth:self.lineWidth];
            [self.lineColor set];
            [path stroke];
        }
        
        for (NSInteger j = 0; j < pointCount; j++) {
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            [linePath moveToPoint:self.centerPoint];
            [linePath addLineToPoint:[((NSValue *)[_outsidePointStructArray objectAtIndex:j]) CGPointValue]];
            [linePath setLineWidth:self.lineWidth];
            [self.lineColor set];
            [linePath stroke];
        }
    }
    
    pointCount = [_insidePointStructArray count];
    if (pointCount > 0) {
        if (pointCount > 1) {
            //connect these point with line
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            [path moveToPoint:[((NSValue *)[_insidePointStructArray objectAtIndex:0]) CGPointValue]];
            
            for (NSInteger i = 1; i < pointCount; i++) {
                [path addLineToPoint:[((NSValue *)[_insidePointStructArray objectAtIndex:i]) CGPointValue]];
            }
            
            [path closePath];
            
            [path setLineWidth:self.lineWidth];
            [self.chartFillColor set];
            [path fill];
        }
    }
}

@end


