//
//  iOS_trip_searchUITests.m
//  iOS-trip-searchUITests
//
//  Created by hanxiaoming on 2017/6/8.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface iOS_trip_searchUITests : XCTestCase

@end

@implementation iOS_trip_searchUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [app.navigationBars[@"北京"].buttons[@"北京"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.element swipeDown];
    
    XCUIElement *cell = [app.tables.cells elementBoundByIndex:0];
    if (cell.exists) {
        if (cell.isHittable) {
            [cell tap];
        }
        else {
            XCUICoordinate *coor = [cell coordinateWithNormalizedOffset:CGVectorMake(0.1, 0.1)];
            [coor tap];
        }
    }
    else {
        [self recordFailureWithDescription:@"no search result" inFile:@__FILE__ atLine:__LINE__ expected:NO];
    }

    [app.buttons[@"您要去哪"] tap];
    
    XCUIElement *textField = [[app textFields] element];
    [textField typeText:@"西单\n"];
    
    sleep(1);
    XCUIElement *cellPOI = app.tables.staticTexts[@"西单大悦城"];
    
    if (cellPOI.exists) {
        if (cellPOI.isHittable) {
            [cellPOI tap];
        }
        else {
            XCUICoordinate *coor = [cellPOI coordinateWithNormalizedOffset:CGVectorMake(0.1, 0.1)];
            [coor tap];
        }
    }
    else {
        [self recordFailureWithDescription:@"poi search failed" inFile:@__FILE__ atLine:__LINE__ expected:NO];
    }
    
    XCUIElement *navigationBar = app.navigationBars[@"确认呼叫"];
    XCUIElement *button = [navigationBar childrenMatchingType:XCUIElementTypeButton].element;
    [button tap];
    
    sleep(1);
}

@end
