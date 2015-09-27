//
//  TranslationFacadeTest.m
//  CrossTranslator
//
//  Created by Andi Palo on 27/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TranslatorFacade.h"

@interface TranslationFacadeTest : XCTestCase

@end

@implementation TranslationFacadeTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    TranslatorFacade *tf = [[TranslatorFacade alloc] init];
    XCTestExpectation *translateExpectation = [self expectationWithDescription:@"Facade did translate"];
    [tf translatePhrase:@"begin"
                   from:@"en"
                     to:@"it"
           completition:^(NSError *error, Translation *translation){
               
               XCTAssertNil(error,@"No error should have happened");
               XCTAssertNotNil(translation.result,@"Empty response");
               XCTAssertTrue([[NSThread currentThread] isMainThread], @"callback should be called on Main Thread");
               [translateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
