//
//  CSVValidation.m
//  CrossTranslator
//
//  Created by Andi Palo on 27/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "CHCSVParser.h"

@interface CSVValidation : XCTestCase<CHCSVParserDelegate>

@property (strong, nonatomic) XCTestExpectation *parseExpectation;
@property (strong, nonatomic) CHCSVParser *parser;
@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSMutableArray *currentLine;

@property (strong, nonatomic) NSManagedObjectContext *moc;

@end

@implementation CSVValidation

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codes" ofType:@"csv"];
    
    XCTAssertNotNil(path,@"No input file found, codes.csv is expected to be in bundle folder");
    NSURL *url = [NSURL fileURLWithPath:path];
    _parser = [[CHCSVParser alloc] initWithContentsOfDelimitedURL:url delimiter:';'];
    _parser.delegate = self;
    
    // Test the parsing ends successfully
    _parseExpectation = [self expectationWithDescription:@"Test Parsing!"];
    [_parser parse];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
    
    
    //setup Core Data Stack
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CrossTranslator" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSError *error = nil;
    XCTAssertTrue([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error] ? YES : NO, @"Should be able to add in-memory store");
    
    
    self.moc = [[NSManagedObjectContext alloc] init];
    self.moc.persistentStoreCoordinator = psc;
    //_moc = [CSVValidation managedObjectContextForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEqualRowContent {
    NSArray *line = [_lines objectAtIndex:0];
    NSInteger firstLineCount = [line count];
    for (int i = 1;i < [_lines count]; i++){
        XCTAssertEqual(firstLineCount, [[_lines objectAtIndex:i] count],@"All rows must have same amount of elements");
    }
    
    //test number of columns
    XCTAssertTrue([[_lines objectAtIndex:0] count] > 1,@"At least one Interface language must be provided");
    
    //test number of rows
    XCTAssertTrue([_lines count] > 2,@"At least two language codes must be provided");
}



- (void) testAllInputIsSavedInCoreData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel"
                                              inManagedObjectContext:_moc];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [_moc executeFetchRequest:fetchRequest error:&error];
    
    
    XCTAssertEqual([[_lines objectAtIndex:0] count], [results count],@"Missmatch in saved data read %lu but saved %lu",(unsigned long)[[_lines objectAtIndex:0] count], (unsigned long)[results count]);
}


#pragma mark - Parsing Delegate Methods

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    self.lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    self.currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
//    NSLog(@"%@", field);
    [self.currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [self.lines addObject:_currentLine];
    self.currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"Parse Ended");
    [self.parseExpectation fulfill];
}


#pragma mark - Util Method
+ (NSManagedObjectContext *)managedObjectContextForTests {
    static NSManagedObjectModel *model = nil;
    if (!model) {
        model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    }
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    NSAssert(store, @"Should have a store by now");
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.persistentStoreCoordinator = psc;
    
    return moc;
}


+ (NSManagedObjectContext*)managedObjectContextForTesting
{
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"CrossTranslator" withExtension:@"momd"]];
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    return moc;
}

@end
