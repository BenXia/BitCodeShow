//
//  PizzaView.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "PizzaView.h"

@interface PizzaView ()

@end

@implementation PizzaView

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

- (void)setRedRatio:(CGFloat)redRatio {
    _redRatio = redRatio;
    
    [self setNeedsDisplay];
}

- (void)setupDefaultProperty {
    [self setBackgroundColor:[UIColor clearColor]];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    CGRect allRect = self.bounds;
    float radius = allRect.size.width / 2;
    CGFloat redRatioAngle = self.redRatio * 2 * M_PI + 3 * (float)M_PI / 2;
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(allRect) + radius, CGRectGetMinY(allRect) + radius);
    CGContextAddLineToPoint(context, CGRectGetMinX(allRect) + radius, CGRectGetMinY(allRect));
    CGContextAddArc(context, CGRectGetMinX(allRect) + radius, CGRectGetMinY(allRect) + radius, radius, 3 * (float)M_PI / 2, redRatioAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(allRect) + radius, CGRectGetMinY(allRect) + radius);
    CGContextAddArc(context, CGRectGetMinX(allRect) + radius, CGRectGetMinY(allRect) + radius, radius, redRatioAngle, 7 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

@end
