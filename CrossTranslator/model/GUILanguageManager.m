//
//  GUILanguageManager.m
//  CrossTranslator
//
//  Created by Andi Palo on 20/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "GUILanguageManager.h"
#import "CHCSVParser.h"
#import "Constants.h"

static NSMutableDictionary *allUIStrings;

@interface GUILanguageManager()<CHCSVParserDelegate>

@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSMutableArray *currentLine;
@property (strong, nonatomic) NSString *currentLanguage;
@property (nonatomic) NSInteger columnIndex;

@end

@implementation GUILanguageManager

+ (instancetype) sharedInstance{
    static GUILanguageManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[GUILanguageManager alloc] init];
    });
    return _sharedInstance;
}



+ (void) setNewLanguage:(NSString*)code{
    [GUILanguageManager sharedInstance].currentLanguage = code;
    if (allUIStrings == nil) {
        allUIStrings = [[NSMutableDictionary alloc] init];
    }else{
        [allUIStrings removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Load in background
        [[GUILanguageManager sharedInstance] loadLangCodes];
    });
}

+ (NSString*) getUIStringForCode:(NSString*)code{
    NSString* result = [allUIStrings objectForKey:code];
    
    if (result == nil) {
        result = code;
    }
    return result;
}

- (void) loadLangCodes{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ui_langs" ofType:@"csv"];
    NSURL *url = [NSURL fileURLWithPath:path];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithContentsOfDelimitedURL:url delimiter:';'];
    parser.delegate = self;
    [parser parse];
}

#pragma mark - Parsing Delegate Methods

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    self.lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    self.currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    NSLog(@"%@", field);
    [self.currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [self.lines addObject:_currentLine];
    
    //First line are supported UI Languages:
    if ([self.lines count] == 1) {
        for (NSInteger i = 0; i < [self.currentLine count] - 1; i++) {
            if ([self.currentLanguage isEqualToString:[self.currentLine objectAtIndex:i]]) {
                self.columnIndex = i;
            }
        }
    }else{
        [allUIStrings setValue:[self.currentLine objectAtIndex:self.columnIndex] forKey:[self.currentLine objectAtIndex:0]];
    }
    self.currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"parser ended");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUILanguageLoaded object:nil];
    });
}




@end
