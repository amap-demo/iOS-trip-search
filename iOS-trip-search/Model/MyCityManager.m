//
//  MyCityManager.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyCityManager.h"

@interface MyCityManager ()
{
    NSArray *_hotCityName;
    
    NSMutableArray<MyCity *> *_hotCities;
    NSMutableArray<MyCity *> *_allCities;
    NSMutableDictionary<NSString*, NSMutableArray<MyCity *> *> *_citiesByInitial;
}
@end

@implementation MyCityManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _hotCityName = @[@"北京", @"广州", @"成都", @"深圳", @"杭州", @"武汉"];
        _allCities = [NSMutableArray array];
        _hotCities = [NSMutableArray array];
        _citiesByInitial = [NSMutableDictionary dictionary];
        
        [self initializeWithFile:@"citylist.json"];
    }
    return self;
}

- (void)initializeWithFile:(NSString *)fileName
{
    //TODO: 根据业务需要获取城市列表
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        NSError *error = nil;
        NSArray *cityArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            NSLog(@"init city error :%@", error);
        }
        else {
            //创建数组
            for (NSDictionary *dic in cityArray) {
                MyCity *city = [[MyCity alloc] init];
                city.name = dic[@"name"];
                city.pinyin = dic[@"pinyin"];
                city.zip = dic[@"zip"];
                
                [_allCities addObject:city];
                if ([_hotCityName containsObject:city.name]) {
                    [_hotCities addObject:city];
                }
                
                NSString *key = [city.pinyin substringToIndex:1];
                NSMutableArray<MyCity *> *cityInitial = _citiesByInitial[key];
                if (cityInitial == nil) {
                    cityInitial = [NSMutableArray array];
                    [_citiesByInitial setObject:cityInitial forKey:key];
                }
                
                [cityInitial addObject:city];
            }
        }
    }
}

#pragma mark - Interfaces

- (NSArray<MyCity *> *)hotCities
{
    return _hotCities;
}

- (NSArray<MyCity *> *)allCities
{
    return _allCities;
}

@end
