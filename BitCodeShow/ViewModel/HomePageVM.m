//
//  HomePageVM.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "HomePageVM.h"

@interface HomePageVM ()

@end

@implementation HomePageVM

- (HomePageVM *)init {
    if (self = [super init]) {
        self.priceArray = [NSMutableArray array];
        self.buyArray = [NSMutableArray array];
    }
    
    return self;
}

- (RACSignal *)getCurrentPriceSignal {
    if (!_getCurrentPriceSignal) {
        _getCurrentPriceSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.huobi.com/staticmarket/ticker_btc_json.js"]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                               timeoutInterval:10];
            request.HTTPMethod = @"GET";
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSError *parseError = nil;
                    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                    if (!parseError) {
                        //                ticker =     {
                        //                    buy = "2746.78";
                        //                    high = "2754.98";
                        //                    last = "2746.8";
                        //                    low = "2737.86";
                        //                    open = "2739.16";
                        //                    sell = "2746.8";
                        //                    symbol = btccny;
                        //                    vol = "554758.7012";
                        //                };
                        //                time = 1459914534;
                        
                        PriceModel *model = [[PriceModel alloc] init];
                        model.date = [[resultDict objectForKey:@"time"] longLongValue];
                        
                        if (self.lastPriceModel.date != model.date) {
                            NSDictionary *tickerDict = (NSDictionary *)[resultDict objectForKey:@"ticker"];
                            model.high = [tickerDict objectForKey:@"high"];
                            model.last = [tickerDict objectForKey:@"last"];
                            model.low = [tickerDict objectForKey:@"low"];
                            model.open = [tickerDict objectForKey:@"open"];
                            model.sell = [tickerDict objectForKey:@"sell"];
                            model.buy = [tickerDict objectForKey:@"buy"];
                            model.vol = [tickerDict objectForKey:@"vol"];
                            
                            if (self.priceArray.count >= 7200) {
                                [self.priceArray removeObjectsInRange:NSMakeRange(0, 1800)];
                            }
                            self.lastPriceModel = model;
                            [self.priceArray addObject:model];
                        }
                        
                        [subscriber sendNext:_lastPriceModel.last];
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:parseError];
                    }
                } else {
                    [subscriber sendError:error];
                }
            }];
            
            [task resume];
            
            return nil;
        }];
    }
    
    return _getCurrentPriceSignal;
}

- (RACSignal *)getCurrentTradeSignal {
    if (!_getCurrentTradeSignal) {
        _getCurrentTradeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.huobi.com/staticmarket/depth_btc_json.js"]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                               timeoutInterval:10];
            request.HTTPMethod = @"GET";
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSError *parseError = nil;
                    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                    if (!parseError) {
                        NSMutableArray *buyArray = [NSMutableArray array];
                        NSMutableArray *sellArray = [NSMutableArray array];
                        
                        NSMutableArray *bArr = [resultDict objectForKey:@"bids"];
                        NSMutableArray *sArr = [resultDict objectForKey:@"asks"];
                        
                        for (int i = 0; i < bArr.count; i++) {
                            NSArray *arr = [bArr objectAtIndex:i];
                            
                            TradeModel *m = [TradeModel new];
                            m.price = [arr objectAtIndex:0];
                            m.amount = [arr objectAtIndex:1];
                            
                            [buyArray addObject:m];
                        }
                        
                        for (int j = 0; j < sArr.count; j++) {
                            NSArray *arr = [sArr objectAtIndex:j];
                            
                            TradeModel *m = [TradeModel new];
                            m.price = [arr objectAtIndex:0];
                            m.amount = [arr objectAtIndex:1];
                            
                            [sellArray addObject:m];
                        }
                        
                        self.buyArray = buyArray;
                        self.sellArray = sellArray;
                        
                        [subscriber sendNext:@(YES)];
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:parseError];
                    }
                } else {
                    [subscriber sendError:error];
                }
            }];
            
            [task resume];
            
            return nil;
        }];
    }
    
    return _getCurrentTradeSignal;
}

- (void)getPrice {
//    [[SignalFromRequest signalFromJsonRequestWithApiPath:@"http://api.huobi.com/staticmarket/ticker_btc_json.js"
//                                              httpMethod:HTTP_GET
//                                                postBody:nil] subscribeNext:^(id x) {
//        NSError *error = nil;
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:x options:NSJSONReadingAllowFragments error:&error];
//        
//        if (!error) {
//            //1.实时行情数据接口
//            // http://api.huobi.com/staticmarket/ticker_btc_json.js
//            //            {
//            //                ticker =     {
//            //                    buy = "2746.78";
//            //                    high = "2754.98";
//            //                    last = "2746.8";
//            //                    low = "2737.86";
//            //                    open = "2739.16";
//            //                    sell = "2746.8";
//            //                    symbol = btccny;
//            //                    vol = "554758.7012";
//            //                };
//            //                time = 1459914534;
//            //            }
//            
//            //2.深度数据接口
//            // http://api.huobi.com/staticmarket/depth_btc_json.js
//            // 指定深度数据条数（1-150条）
//            // http://api.huobi.com/staticmarket/depth_btc_X.js
//            
//            
//            //3.分时行情数据接口（K线）
//            // http://api.huobi.com/staticmarket/btc_kline_[period]_json.js
//            // period 参数	说明
//            //            001	1分钟线
//            //            005	5分钟
//            //            015	15分钟
//            //            030	30分钟
//            //            060	60分钟
//            //            100	日线
//            //            200	周线
//            //            300	月线
//            //            400	年线
//            //            例如	http://api.huobi.com/staticmarket/btc_kline_005_json.js
//            
//            
//            //4.买卖盘实时成交数据
//            // http://api.huobi.com/staticmarket/detail_btc_json.js
//            // amount: 63165 //成交量
//            //            level: 86.999 //涨幅
//            //            buys: Array[10] //买10
//            //            p_high: 4410 //最高
//            //            p_last: 4275  //收盘价
//            //            p_low: 4250 //最低
//            //            p_new: 4362 //最新
//            //            p_open: 4275 //开盘
//            //            sells: Array[10] //卖10
//            //            top_buy: Array[5] //买5
//            //            top_sell: Object //卖5
//            //            total: 273542407.24361 //总量（人民币） 
//            //            trades: Array[15] //实时成交
//            
//            
//            NSLog (@"resultDict");
//        }
//    }];
}

@end
