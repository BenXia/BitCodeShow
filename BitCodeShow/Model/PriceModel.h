//
//  PriceModel.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PriceModel : NSObject

@property (nonatomic, strong) NSNumber* high;
@property (nonatomic, strong) NSNumber* last;
@property (nonatomic, strong) NSNumber* low;
@property (nonatomic, strong) NSNumber* open;
@property (nonatomic, strong) NSNumber* sell;
@property (nonatomic, strong) NSNumber* buy;
@property (nonatomic, strong) NSNumber* vol;
@property (nonatomic, assign) NSTimeInterval date;

@end
