//
//  MyRecordManager.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyRecordManager.h"
#import "MyLocation.h"
#import "MyCity.h"
#import <AMapSearchKit/AMapSearchKit.h>

#define kMaxHistoryCount    10

#define kRecordHomeKey          @"kRecordHomeKey"
#define kRecordCompanyKey       @"kRecordCompanyKey"
#define kRecordHistoryKey       @"kRecordHistoryKey"

@implementation MyRecordManager

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
        
    }
    return self;
}

#pragma mark - Interfaces

- (MyLocation *)home
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRecordHomeKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)setHome:(MyLocation *)home
{
    if (home) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:home] forKey:kRecordHomeKey];
    }
    else {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordHomeKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordHomeKey];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (MyLocation *)company
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRecordCompanyKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)setCompany:(MyLocation *)company
{
    if (company) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:company] forKey:kRecordCompanyKey];
    }
    else {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordCompanyKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordCompanyKey];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<MyLocation *> *)historyArray
{
    NSArray *item = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kRecordHistoryKey]];
    return item;
}

- (void)addHistoryRecord:(MyLocation *)location
{
    if (location == nil) {
        return;
    }
    
    NSArray *oldHistory = [self historyArray];
    
    // 去重
    for (MyLocation *aPoi in oldHistory) {
        if ([aPoi.name isEqualToString:location.name]) {
            return;
        }
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:oldHistory];
    
    if (oldHistory.count == kMaxHistoryCount) {
        [array removeObjectAtIndex:array.count - 1];
    }
    
    [array addObject:location];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[array copy]] forKey:kRecordHistoryKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSArray<MyLocation *> *)historyArrayFilteredByCityName:(NSString *)city
{
    NSArray *originArray = [self historyArray];
    
    if (city.length == 0) {
        return originArray;
    }
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (MyLocation *loc in originArray) {
        if ([loc.city containsString:city]) {
            [filteredArray addObject:loc];
        }
    }
    
    return filteredArray;
}

- (void)clearHistory
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordHistoryKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordHistoryKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (AMapPOIKeywordsSearchRequest *)POISearchRequestWithKeyword:(NSString *)keyword inCity:(MyCity *)city
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.cityLimit = YES;
    
    request.city = city.name;
    //TODO: 需要设置location和sortrule
    
    return request;
}
@end
