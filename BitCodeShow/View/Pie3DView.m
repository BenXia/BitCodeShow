//
//  Pie3DView.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "Pie3DView.h"

#define K_PI 3.1415
#define KDGREED(x) ((x)  * K_PI * 2)

@implementation Pie3DView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupDefaultProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupDefaultProperty];
    }
    return self;
}

- (void)setupDefaultProperty {
    self.backgroundColor = [UIColor clearColor];
    
    _spaceHeight = 10;
    _scaleY = 0.4;
}

- (void)drawRect:(CGRect)rect  {
    CGRect boundsRect = self.bounds;
    CGFloat circleRadius = boundsRect.size.width / 2.0;
    CGPoint circleCenterPoint = CGPointMake(CGRectGetMidX(boundsRect), (CGRectGetMidY(boundsRect)));
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//抗锯齿
	CGContextSetAllowsAntialiasing(context, TRUE);

	float sum = 0;
	
	for (int j = 0; j < [_valueArr count]; j++) {
		sum	 += [[_valueArr objectAtIndex:j] floatValue];
	}
	
	CGContextMoveToPoint(context, circleCenterPoint.x, circleCenterPoint.y);
	
	float currentangel = 0;
	
	//饼图
	CGContextSaveGState(context);
	CGContextScaleCTM(context, 1.0, _scaleY);

	currentangel = 0;
	
	for (int i = 0; i < [_valueArr count]; i++) {

		float startAngle = KDGREED(currentangel);
		
		currentangel += [[_valueArr objectAtIndex:i] floatValue] / sum;
		
		float endAngle = KDGREED(currentangel);
		
		//绘制上面的扇形
		CGContextMoveToPoint(context, circleCenterPoint.x, circleCenterPoint.y);
		
		[[_colorArr objectAtIndex:i %  [_valueArr count]] setFill];
		
		[[UIColor colorWithWhite:1.0 alpha:0.8] setStroke];
		
		CGContextAddArc(context, circleCenterPoint.x, circleCenterPoint.y, circleRadius, startAngle, endAngle, 0);
		
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFill);
		

		//绘制侧面
		float starx = cos(startAngle) * circleRadius + circleCenterPoint.x;
		float stary = sin(startAngle) * circleRadius + circleCenterPoint.y;
		
		float endx = cos(endAngle) * circleRadius + circleCenterPoint.x;
		float endy = sin(endAngle) * circleRadius + circleCenterPoint.y;
		
		//float starty1 = stary + _spaceHeight;
		float endy1 = endy + _spaceHeight;
		
		
		if (endAngle < K_PI) {
		} else if (startAngle < K_PI) {
            //只有弧度< 3.14 的才会画前面的厚度
			endAngle = K_PI;
			endx = 0;
			endy1 = circleCenterPoint.y + _spaceHeight;
        } else {
			continue;
        }
		
		//绘制厚度
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, nil, starx, stary);
		CGPathAddArc(path, nil, circleCenterPoint.x, circleCenterPoint.y, circleRadius, startAngle, endAngle, 0);
		CGPathAddLineToPoint(path, nil, endx, endy1);
		
		CGPathAddArc(path, nil, circleCenterPoint.x, circleCenterPoint.y + _spaceHeight, circleRadius, endAngle, startAngle, 1);
		CGContextAddPath(context, path);
		
		[[_colorArr objectAtIndex:i %  [_valueArr count]] setFill];
		[[UIColor colorWithWhite:0.9 alpha:1.0] setStroke];
		
		CGContextDrawPath(context, kCGPathFill);
		
		[[UIColor colorWithWhite:0.1 alpha:0.4] setFill];
		CGContextAddPath(context, path);
		CGContextDrawPath(context, kCGPathFill);
	}
	
	//整体渐变
	CGFloat componets [] = {0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.1};
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, componets, nil, 2);
	CGContextDrawRadialGradient(context, gradient, circleCenterPoint, 0, circleCenterPoint, circleRadius, 0 );
	
	CFRelease(colorspace);
	CGGradientRelease(gradient);
	
	
	CGContextRestoreGState(context);
	
//	//绘制文字
//	for (int i = 0; i < [_valueArr count]; i++) {
//		float origionx = 50 ;
//		float origiony = i * 30 + 200;
//		
//		[[_colorArr objectAtIndex:i %  [_valueArr count]] setFill];
//		
//		CGContextFillRect(context, CGRectMake(origionx, origiony, 20, 20));
//		CGContextDrawPath(context, kCGPathFill);
//		
//		
//		if (i < [_titleArr count]) {
//			NSString *title = [ _titleArr objectAtIndex:i];
//            [title drawAtPoint:CGPointMake(origionx + 50, origiony) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//		}
//	}
}

@end
