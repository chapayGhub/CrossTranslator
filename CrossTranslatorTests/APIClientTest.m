//
//  APIClient.m
//  CrossTranslator
//
//  Created by Andi Palo on 27/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APNetworkClient.h"


@interface APIClientTest : XCTestCase <TranslationDelegateProtocol>
@property (strong, nonatomic) APNetworkClient *networkClient;
@property (strong, nonatomic) XCTestExpectation *translateExpectation;
@end

@implementation APIClientTest

- (void)setUp {
    [super setUp];
    _networkClient = [[APNetworkClient alloc] init];
    _networkClient.delegate = self;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFromItaToEng {
    self.translateExpectation = [self expectationWithDescription:@"Shall receive a response"];
    [_networkClient translatePhrase:@"separato" from:@"it" to:@"en"];
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


- (void) translation:(Translation*)translation
             isLocal:(BOOL)local
               error:(NSError*)error{
    
    XCTAssertTrue(!local,@"Should have been a remote response not local");
    XCTAssertNil(error,@"No error should have happened");
    XCTAssertNotNil(translation.result,@"Empty response");
    XCTAssertTrue([[NSThread currentThread] isMainThread], @"callback should be called on Main Thread");
    
    [_translateExpectation fulfill];
}


@end
