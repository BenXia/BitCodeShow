//
//  HomePageVM.h
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceModel.h"
#import "TradeModel.h"

@interface HomePageVM : NSObject

// 最近的价格列表，按时间排序后的
@property (nonatomic, strong) PriceModel *lastPriceModel;
@property (nonatomic, strong) NSMutableArray *priceArray;
@property (nonatomic, strong) RACSignal *getCurrentPriceSignal;

// 最近的实时交易列表
@property (nonatomic, strong) NSMutableArray *buyArray;
@property (nonatomic, strong) NSMutableArray *sellArray;
@property (nonatomic, strong) RACSignal *getCurrentTradeSignal;

@end
