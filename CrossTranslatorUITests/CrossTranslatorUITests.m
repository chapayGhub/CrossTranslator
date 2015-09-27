//
//  CrossTranslatorUITests.m
//  CrossTranslatorUITests
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CrossTranslatorUITests : XCTestCase

@end

@implementation CrossTranslatorUITests

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
    XCUIElementQuery *tablesQuery = app.tables;
    XCUIElementQuery *cellsQuery = tablesQuery.cells;
    XCUIElement *textField = [[cellsQuery childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0];
    [textField tap];
    [textField typeText:@"five"];
    
    XCUIElement *textField2 = [[cellsQuery childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:1];
    [textField2 tap];
    
    XCUIElement *eliminaKey = app.keys[@"Elimina"];
    [eliminaKey doubleTap];
    [eliminaKey doubleTap];
    [eliminaKey doubleTap];
    [eliminaKey tap];
    [textField2 typeText:@"eng"];
    
    XCUIElement *textField3 = [[cellsQuery childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:2];
    [textField3 tap];
    [textField3 tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey tap];
    [eliminaKey doubleTap];
    [textField3 typeText:@"ita"];
    [textField2 tap];
    [tablesQuery.buttons[@"Translate"] tap];
    [[tablesQuery.cells containingType:XCUIElementTypeButton identifier:@"Play Audio"].element swipeUp];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"5"].staticTexts[@"LinkValue"] swipeUp];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"The digit/figure 5."].staticTexts[@"http://en.wiktionary.org"] tap];
    
    XCUIElement *mainButton = app.navigationBars[@"Master"].buttons[@"Main"];
    [mainButton tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"A person who is five years old."].staticTexts[@"http://en.wiktionary.org"] tap];
    [mainButton tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"A short rest, especially one of five minutes."].staticTexts[@"LinkValue"] swipeDown];
    [tablesQuery.otherElements[@"TRANSLATION"] swipeDown];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [tablesQuery.staticTexts[@"https://en.wikipedia.org/wiki/five"] tap];
    
}

@end
