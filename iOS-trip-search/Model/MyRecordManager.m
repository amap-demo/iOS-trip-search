//
//  MyRecordManager.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyRecordManager.h"
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

- (AMapPOI *)home
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRecordHomeKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)setHome:(AMapPOI *)home
{
    if (home) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:home] forKey:kRecordHomeKey];
    }
    else {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordHomeKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordHomeKey];
        }
    }
    
}

- (AMapPOI *)company
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRecordCompanyKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)setCompany:(AMapPOI *)company
{
    if (company) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:company] forKey:kRecordCompanyKey];
    }
    else {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordCompanyKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordCompanyKey];
        }
    }
}

- (NSArray<AMapPOI *> *)historyArray
{
    NSArray *item = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kRecordHistoryKey]];
    return item;
}

- (void)addHistoryRecord:(AMapPOI *)poi
{
    if (poi == nil) {
        return;
    }
    
    NSArray *oldHistory = [self historyArray];
    
    // 去重
    for (AMapPOI *aPoi in oldHistory) {
        if ([aPoi.uid isEqualToString:poi.uid]) {
            return;
        }
    }

    if (oldHistory.count < kMaxHistoryCount) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:oldHistory];
        [array addObject:poi];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[array copy]] forKey:kRecordHistoryKey];
    }
}

- (NSArray<AMapPOI *> *)historyArrayFilteredByCityName:(NSString *)city
{
    NSArray *originArray = [self historyArray];
    
    if (city.length == 0) {
        return originArray;
    }
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (AMapPOI *poi in originArray) {
        if ([poi.city containsString:city]) {
            [filteredArray addObject:poi];
        }
    }
    
    return filteredArray;
}

- (void)clearHistory
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecordHistoryKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecordHistoryKey];
    }
}

@end
