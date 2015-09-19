//
//  TranslatorFacade.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "TranslatorFacade.h"
#import "APNetworkClient.h"
#import "CoreDataTranslationManager.h"
#import "Translation.h"


@interface TranslatorFacade ()

@property (strong, nonatomic) APNetworkClient *apiClient;
@property (strong, nonatomic) CoreDataTranslationManager *localTranslator;

@property (copy, nonatomic) void (^completition)(NSError *error, Translation* translation);

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSString *phrase;

@end

@implementation TranslatorFacade

- (id) init{
    if (self = [super init]) {
        self.localTranslator = [[CoreDataTranslationManager alloc] init];
        self.localTranslator.delegate = self;
        self.apiClient = [[APNetworkClient alloc] init];
        self.apiClient.delegate = self;
    }
    return self;
}

- (void) translatePhrase:(NSString*) phrase
                    from:(NSString*)startLanguage
                      to:(NSString*)endLanguage
            completition:(void (^)(NSError *error, Translation* translation))completition{
    self.completition = completition;
    self.from = startLanguage;
    self.to = endLanguage;
    self.phrase = phrase;
    
    [self.localTranslator translatePhrase:phrase from:startLanguage to:endLanguage];
    
    
}

- (void) translation:(Translation*)result
             isLocal:(BOOL)local
               error:(NSError*)error{
    if (local) {
        if (error) {
            [self.apiClient translatePhrase:self.phrase from:self.from to:self.to];
        }else{
            self.completition(error,result);
        }
    }else{
        self.completition(error,result);
    }
    
}

@end
