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


@interface TranslatorFacade ()

@property (strong, nonatomic) APNetworkClient *apiClient;
@property (strong, nonatomic) CoreDataTranslationManager *localTranslator;

@property (copy, nonatomic) void (^completition)(NSError *error, NSString* translation);

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
            completition:(void (^)(NSError *error, NSString* translation))completition{
    self.completition = completition;
    
    [self.apiClient translatePhrase:phrase from:startLanguage to:endLanguage];
    
}

- (void) translationForPhrase:(NSString*)phrase
                           is:(NSString*)translation
                         from:(NSString*)fromLanguage
                           to:(NSString*)toLanguage
                      isLocal:(BOOL)local
                        error:(NSError*)error{
    if (local) {
        
        
    }else{
        
    }
    
}

@end
