//
//  HomePageVC.m
//  BitCodeShow
//
//  Created by Ben on 16/4/6.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "HomePageVC.h"
#import "HomePageVM.h"
#import "SketchView.h"
#import "HistogramView.h"
#import "PizzaView.h"
#import "PieView.h"
#import "Pie3DView.h"
#import "RadarChartView.h"

@interface HomePageVC ()

@property (weak, nonatomic) IBOutlet HistogramView *tradingView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet SketchView *sketchView;
@property (weak, nonatomic) IBOutlet PizzaView *pizzaView;

@property (weak, nonatomic) IBOutlet Pie3DView *pie3DView;
@property (weak, nonatomic) IBOutlet RadarChartView *radarChartView;

@property (weak, nonatomic) IBOutlet PieView *pieView1;
@property (weak, nonatomic) IBOutlet PieView *pieView2;
@property (weak, nonatomic) IBOutlet PieView *pieView3;
@property (weak, nonatomic) IBOutlet PieView *pieView4;
@property (weak, nonatomic) IBOutlet PieView *pieView5;
@property (weak, nonatomic) IBOutlet PieView *pieView6;
@property (weak, nonatomic) IBOutlet PieView *pieView7;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel3;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel4;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel5;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel6;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel7;

@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewWidthConstraint;

@property (nonatomic, assign) CGFloat screenWidth;

@property (nonatomic, strong) HomePageVM *vm;

@end

@implementation HomePageVC

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUIRelated];
    [self bindViewModel];
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.sketchView.topBottomEmptyHeight = 30.0f;
    self.tradingView.topBottomEmptyHeight = 30.0f;
    
    [self requestCurrentPrice];
    [self requestCurrentTrade];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(requestCurrentPrice) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(requestCurrentTrade) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableArray *modelArray = [NSMutableArray arrayWithObjects:
                                  [[RadarChartModel alloc] initWithValue:1 imageName:@"sr_refresh" text:@"授课时长"],
                                  [[RadarChartModel alloc] initWithValue:0.5 imageName:@"sr_refresh" text:@"续课率"],
                                  [[RadarChartModel alloc] initWithValue:0 imageName:@"sr_refresh" text:@"服务"],
                                  [[RadarChartModel alloc] initWithValue:0.6 imageName:@"sr_refresh" text:@"效果"],
                                  [[RadarChartModel alloc] initWithValue:0.1 imageName:@"sr_refresh" text:@"学生数"],
                                  nil];
    [self.radarChartView setRadarChartModelsArray:modelArray];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)initUIRelated {
    self.currentPriceLabel.text = @"*";
    
    self.pie3DView.titleArr = [NSArray	arrayWithObjects:@"iphone", @"sybian", @"windowbile", @"mego",@"android",nil];
    self.pie3DView.valueArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:20],[NSNumber numberWithFloat:20],\
                   [NSNumber numberWithFloat:20],[NSNumber numberWithFloat:20],[NSNumber numberWithFloat:20],nil];
    self.pie3DView.colorArr = [NSArray arrayWithObjects:[UIColor yellowColor], [UIColor blueColor], [UIColor brownColor], [UIColor purpleColor] , [UIColor orangeColor],nil];
}

- (void)bindViewModel {
    self.vm = [[HomePageVM alloc] init];
}

- (void)requestCurrentPrice {
    [[self.vm.getCurrentPriceSignal deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSNumber *currentPrice) {
        [self refreshPriceInfoUIWithCurrentPrice:currentPrice];
    }];
}

- (void)requestCurrentTrade {
    [[self.vm.getCurrentTradeSignal deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id x) {
        [self refreshTradeInfoUI];
    }];
}

- (void)refreshPriceInfoUIWithCurrentPrice:(NSNumber *)currentPrice {
    self.currentPriceLabel.text = [NSString stringWithFormat:@"%.2f", [currentPrice floatValue]];
    
    CGFloat widthToSet = self.vm.priceArray.count * 2 + 50;
    if (widthToSet < _screenWidth) {
        widthToSet = _screenWidth;
    }
    self.scrollContentViewWidthConstraint.constant = widthToSet;
    self.scrollView.contentOffset = CGPointMake(widthToSet - _screenWidth, 0);
    
    self.sketchView.priceArray = self.vm.priceArray;
}

- (void)refreshTradeInfoUI {
    CGFloat currentPrice = [self.vm.lastPriceModel.last floatValue];
    
    CGFloat model1RedAmount = 0.01;
    CGFloat model1GreenAmount = 0.01;
    CGFloat model1RedPrice = 0;
    CGFloat model1GreenPrice = 0;
    CGFloat model1ExtremePrice = 0;
    
    CGFloat model2RedAmount = 0.01;
    CGFloat model2GreenAmount = 0.01;
    CGFloat model2RedPrice = 0;
    CGFloat model2GreenPrice = 0;
    CGFloat model2ExtremePrice = 0;
    
    CGFloat model3RedAmount = 0.01;
    CGFloat model3GreenAmount = 0.01;
    CGFloat model3RedPrice = 0;
    CGFloat model3GreenPrice = 0;
    CGFloat model3ExtremePrice = 0;
    
    CGFloat model4RedAmount = 0.01;
    CGFloat model4GreenAmount = 0.01;
    CGFloat model4RedPrice = 0;
    CGFloat model4GreenPrice = 0;
    CGFloat model4ExtremePrice = 0;
    
    CGFloat model5RedAmount = 0.01;
    CGFloat model5GreenAmount = 0.01;
    CGFloat model5RedPrice = 0;
    CGFloat model5GreenPrice = 0;
    CGFloat model5ExtremePrice = 0;
    
    CGFloat model6RedAmount = 0.01;
    CGFloat model6GreenAmount = 0.01;
    CGFloat model6RedPrice = 0;
    CGFloat model6GreenPrice = 0;
    CGFloat model6ExtremePrice = 0;
    
    CGFloat model7RedAmount = 0.01;
    CGFloat model7GreenAmount = 0.01;
    CGFloat model7RedPrice = 0;
    CGFloat model7GreenPrice = 0;
    CGFloat model7ExtremePrice = 0;
    
    for (TradeModel *m in self.vm.buyArray) {
        CGFloat mPrice = [m.price floatValue];
        CGFloat price = currentPrice - mPrice;
        CGFloat priceMultiAmount = (mPrice * [m.amount floatValue]);
        if (price < 1) {
            model1RedAmount += [m.amount floatValue];
            model1RedPrice += priceMultiAmount;
            model2RedAmount += [m.amount floatValue];
            model2RedPrice += priceMultiAmount;
            model3RedAmount += [m.amount floatValue];
            model3RedPrice += priceMultiAmount;
            model4RedAmount += [m.amount floatValue];
            model4RedPrice += priceMultiAmount;
            model5RedAmount += [m.amount floatValue];
            model5RedPrice += priceMultiAmount;
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else if (price < 2) {
            model2RedAmount += [m.amount floatValue];
            model2RedPrice += priceMultiAmount;
            model3RedAmount += [m.amount floatValue];
            model3RedPrice += priceMultiAmount;
            model4RedAmount += [m.amount floatValue];
            model4RedPrice += priceMultiAmount;
            model5RedAmount += [m.amount floatValue];
            model5RedPrice += priceMultiAmount;
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else if (price < 3) {
            model3RedAmount += [m.amount floatValue];
            model3RedPrice += priceMultiAmount;
            model4RedAmount += [m.amount floatValue];
            model4RedPrice += priceMultiAmount;
            model5RedAmount += [m.amount floatValue];
            model5RedPrice += priceMultiAmount;
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else if (price < 4) {
            model4RedAmount += [m.amount floatValue];
            model4RedPrice += priceMultiAmount;
            model5RedAmount += [m.amount floatValue];
            model5RedPrice += priceMultiAmount;
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else if (price < 5) {
            model5RedAmount += [m.amount floatValue];
            model5RedPrice += priceMultiAmount;
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else if (price < 6) {
            model6RedAmount += [m.amount floatValue];
            model6RedPrice += priceMultiAmount;
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        } else {
            model7RedAmount += [m.amount floatValue];
            model7RedPrice += priceMultiAmount;
        }
    }
    
    for (TradeModel *m in self.vm.sellArray) {
        CGFloat mPrice = [m.price floatValue];
        CGFloat price = mPrice - currentPrice;
        CGFloat priceMultiAmount = (mPrice * [m.amount floatValue]);
        if (price < 1) {
            model1GreenAmount += [m.amount floatValue];
            model1GreenPrice += priceMultiAmount;
            model2GreenAmount += [m.amount floatValue];
            model2GreenPrice += priceMultiAmount;
            model3GreenAmount += [m.amount floatValue];
            model3GreenPrice += priceMultiAmount;
            model4GreenAmount += [m.amount floatValue];
            model4GreenPrice += priceMultiAmount;
            model5GreenAmount += [m.amount floatValue];
            model5GreenPrice += priceMultiAmount;
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else if (price < 2) {
            model2GreenAmount += [m.amount floatValue];
            model2GreenPrice += priceMultiAmount;
            model3GreenAmount += [m.amount floatValue];
            model3GreenPrice += priceMultiAmount;
            model4GreenAmount += [m.amount floatValue];
            model4GreenPrice += priceMultiAmount;
            model5GreenAmount += [m.amount floatValue];
            model5GreenPrice += priceMultiAmount;
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else if (price < 3) {
            model3GreenAmount += [m.amount floatValue];
            model3GreenPrice += priceMultiAmount;
            model4GreenAmount += [m.amount floatValue];
            model4GreenPrice += priceMultiAmount;
            model5GreenAmount += [m.amount floatValue];
            model5GreenPrice += priceMultiAmount;
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else if (price < 4) {
            model4GreenAmount += [m.amount floatValue];
            model4GreenPrice += priceMultiAmount;
            model5GreenAmount += [m.amount floatValue];
            model5GreenPrice += priceMultiAmount;
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else if (price < 5) {
            model5GreenAmount += [m.amount floatValue];
            model5GreenPrice += priceMultiAmount;
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else if (price < 6) {
            model6GreenAmount += [m.amount floatValue];
            model6GreenPrice += priceMultiAmount;
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        } else {
            model7GreenAmount += [m.amount floatValue];
            model7GreenPrice += priceMultiAmount;
        }
    }
    
    UIColor *redColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
    UIColor *greenColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    
    NSMutableArray *model1Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model1RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model1GreenAmount text:@"卖"], nil];
    NSMutableArray *model2Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model2RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model2GreenAmount text:@"卖"], nil];
    NSMutableArray *model3Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model3RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model3GreenAmount text:@"卖"], nil];
    NSMutableArray *model4Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model4RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model4GreenAmount text:@"卖"], nil];
    NSMutableArray *model5Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model5RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model5GreenAmount text:@"卖"], nil];
    NSMutableArray *model6Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model6RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model6GreenAmount text:@"卖"], nil];
    NSMutableArray *model7Array = [NSMutableArray arrayWithObjects:
                                   [[PieModel alloc] initWithColor:redColor value:model7RedAmount text:@"买"],
                                   [[PieModel alloc] initWithColor:greenColor value:model7GreenAmount text:@"卖"], nil];
    
    [self.pieView1 setValuesArray:model1Array];
    [self.pieView2 setValuesArray:model2Array];
    [self.pieView3 setValuesArray:model3Array];
    [self.pieView4 setValuesArray:model4Array];
    [self.pieView5 setValuesArray:model5Array];
    [self.pieView6 setValuesArray:model6Array];
    [self.pieView7 setValuesArray:model7Array];
    
    model1ExtremePrice = (model1RedPrice + model1GreenPrice) / (model1RedAmount + model1GreenAmount);
    model2ExtremePrice = (model2RedPrice + model2GreenPrice) / (model2RedAmount + model2GreenAmount);
    model3ExtremePrice = (model3RedPrice + model3GreenPrice) / (model3RedAmount + model3GreenAmount);
    model4ExtremePrice = (model4RedPrice + model4GreenPrice) / (model4RedAmount + model4GreenAmount);
    model5ExtremePrice = (model5RedPrice + model5GreenPrice) / (model5RedAmount + model5GreenAmount);
    model6ExtremePrice = (model6RedPrice + model6GreenPrice) / (model6RedAmount + model6GreenAmount);
    model7ExtremePrice = (model7RedPrice + model7GreenPrice) / (model7RedAmount + model7GreenAmount);
    
    self.priceLabel1.text = [NSString stringWithFormat:@"%.2f", model1ExtremePrice];
    if (model1ExtremePrice > currentPrice) {
        self.priceLabel1.textColor = [UIColor greenColor];
    } else {
        self.priceLabel1.textColor = [UIColor redColor];
    }
    self.priceLabel2.text = [NSString stringWithFormat:@"%.2f", model2ExtremePrice];
    if (model2ExtremePrice > currentPrice) {
        self.priceLabel2.textColor = [UIColor greenColor];
    } else {
        self.priceLabel2.textColor = [UIColor redColor];
    }
    self.priceLabel3.text = [NSString stringWithFormat:@"%.2f", model3ExtremePrice];
    if (model3ExtremePrice > currentPrice) {
        self.priceLabel3.textColor = [UIColor greenColor];
    } else {
        self.priceLabel3.textColor = [UIColor redColor];
    }
    self.priceLabel4.text = [NSString stringWithFormat:@"%.2f", model4ExtremePrice];
    if (model4ExtremePrice > currentPrice) {
        self.priceLabel4.textColor = [UIColor greenColor];
    } else {
        self.priceLabel4.textColor = [UIColor redColor];
    }
    self.priceLabel5.text = [NSString stringWithFormat:@"%.2f", model5ExtremePrice];
    if (model5ExtremePrice > currentPrice) {
        self.priceLabel5.textColor = [UIColor greenColor];
    } else {
        self.priceLabel5.textColor = [UIColor redColor];
    }
    self.priceLabel6.text = [NSString stringWithFormat:@"%.2f", model6ExtremePrice];
    if (model6ExtremePrice > currentPrice) {
        self.priceLabel6.textColor = [UIColor greenColor];
    } else {
        self.priceLabel6.textColor = [UIColor redColor];
    }
    self.priceLabel7.text = [NSString stringWithFormat:@"%.2f", model7ExtremePrice];
    if (model7ExtremePrice > currentPrice) {
        self.priceLabel7.textColor = [UIColor greenColor];
    } else {
        self.priceLabel7.textColor = [UIColor redColor];
    }
    
    [self.pizzaView setRedRatio:model2RedAmount / (model2RedAmount + model2GreenAmount)];
    
    [self.tradingView setSellArray:self.vm.sellArray
                          buyArray:self.vm.buyArray
                      currentPrice:currentPrice];
    self.sketchView.extremePriceArray = [NSMutableArray arrayWithObjects:@(model1ExtremePrice),
                                                                         @(model2ExtremePrice),
                                                                         @(model3ExtremePrice),
                                                                         @(model4ExtremePrice),
                                                                         @(model5ExtremePrice),
                                                                         @(model6ExtremePrice),
                                                                         @(model7ExtremePrice), nil];
}

@end
