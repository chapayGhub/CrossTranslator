//
//  MasterViewController.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "MLPAutoCompleteTextField.h"

#import "FromLanguageCell.h"
#import "ToLanguageCell.h"
#import "WikiSuggestsCell.h"
#import "GoogleAudioCell.h"
#import "Constants.h"

#import "TranslatorFacade.h"
#import "KnownWordsDataSource.h"
#import "LanguageNamesDataSource.h"
#import "LangCodeModel.h"
#import "NSString+HTML.h"
#import "SelectLangViewController.h"


@interface MasterViewController() <MLPAutoCompleteTextFieldDelegate,LanguageChangedDelegate>

@property (strong, nonatomic) NSString *startLangCode;
@property (strong, nonatomic) NSString *endLangCode;
@property (strong, nonatomic) NSString *inputString;


@property (weak, nonatomic) MLPAutoCompleteTextField *inputText;
@property (weak, nonatomic) MLPAutoCompleteTextField *startLang;
@property (weak, nonatomic) MLPAutoCompleteTextField *endLang;

@property (weak, nonatomic) UITextView *translatedText;

@property (strong, nonatomic) NSNumber *currentLanguage;

@property (strong, nonatomic) TranslatorFacade *translator;
@property (strong, nonatomic) Translation *translation;
@property (strong, nonatomic) KnownWordsDataSource * knownWordsDataSource;
@property (strong, nonatomic) LanguageNamesDataSource *languageNamesDataSource;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.translator = [[TranslatorFacade alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentLanguage = [prefs objectForKey:kCurrentLang];
    
    self.startLangCode = [prefs objectForKey:kStartLanguage];
    self.endLangCode = [prefs objectForKey:kEndLanguage];
    
    
    self.knownWordsDataSource = [[KnownWordsDataSource alloc] initWithStartLanguage:self.startLangCode destinationLanguage:self.endLangCode];
    self.languageNamesDataSource = [[LanguageNamesDataSource alloc] initWithUILanguage:self.currentLanguage];
    
    self.translation = nil;
    self.navigationItem.title = @"Main";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMeaning"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tuc *object = [self.translation.result.tuc objectAtIndex:indexPath.row];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        controller.tuc = object;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }else if([[segue identifier] isEqualToString:@"showOptions"]){
        SelectLangViewController * dest = (SelectLangViewController*) [segue destinationViewController];
        dest.delegate = self;
        dest.currentLanguage = self.currentLanguage;
        dest.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.translation == nil ? 1 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 3){
        if (self.translation == nil) {
            return 0;
        }else{
            return [self.translation.result.tuc count];
        }
    }else if (section == 1){
        return self.translation == nil ? 0 : 1;
    }else if (section == 2){
        return self.translation == nil ? 0 : 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Input";
            break;
        case 1:
            sectionName = @"Wiki Link";
            break;
        case 2:
            sectionName = @"Play Audio";
            break;
        case 3:
            sectionName = @"Translation";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* fromLangCellID = @"FromTranslate";
    static NSString* toLangCellID = @"ToTranslate";
    static NSString* wikiCellID = @"WikiSuggests";
    static NSString* googleAudioCellID = @"GoogleAudio";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = (FromLanguageCell*)[tableView dequeueReusableCellWithIdentifier:fromLangCellID
                                                                  forIndexPath:indexPath];
        
        [self customizeInputCell:(FromLanguageCell*)cell];

    }else if (indexPath.section == 3){
        cell = (ToLanguageCell*)[tableView dequeueReusableCellWithIdentifier:toLangCellID
                                                                forIndexPath:indexPath];
        Tuc *tuc = [self.translation.result.tuc objectAtIndex:indexPath.row];
        
        
        if ((tuc.meanings == nil)|| ([tuc.meanings count] == 0)) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (tuc.phrase == nil) {
            if([tuc.meanings count] > 0){
                ((ToLanguageCell*)cell).translatePhrase.text = [((Meaning*)[tuc.meanings objectAtIndex:0]).text stringByConvertingHTMLToPlainText];
            }
        }else{
            ((ToLanguageCell*)cell).translatePhrase.text = [tuc.phrase.text stringByConvertingHTMLToPlainText];
        }
        
    }else if (indexPath.section == 1){
        cell = (WikiSuggestsCell*)[tableView dequeueReusableCellWithIdentifier:wikiCellID
                                                                  forIndexPath:indexPath];
    }else if (indexPath.section == 2){
        cell = (GoogleAudioCell*)[tableView dequeueReusableCellWithIdentifier:googleAudioCellID
                                                                 forIndexPath:indexPath];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void) customizeInputCell:(FromLanguageCell*)cell{
    [cell.translate addTarget:self
                       action:@selector(goTranslate)
             forControlEvents:UIControlEventTouchUpInside];
    
    self.inputText = cell.inputText;
    self.inputText.autoCompleteDataSource = self.knownWordsDataSource;
    self.inputText.autoCompleteDelegate = self;
    
    self.startLang = cell.fromLangValue;
    self.startLang.autoCompleteDataSource = self.languageNamesDataSource;
    self.startLang.autoCompleteDelegate = self;
    
    self.endLang = cell.toLangValue;
    self.endLang.autoCompleteDataSource = self.languageNamesDataSource;
    self.endLang.autoCompleteDelegate = self;
    
    
    if (self.startLangCode != nil) {
        [self.startLang setText:[self.languageNamesDataSource getLangNameForCode:self.startLangCode]];
    }
    if (self.endLangCode != nil) {
        self.endLang.text = [self.languageNamesDataSource getLangNameForCode:self.endLangCode];
    }
}


- (void) invokeTranslate{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

- (double) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 255;
    }else if (indexPath.section == 3){
        return 134;
    }else if (indexPath.section == 1){
        return 44;
    }else if (indexPath.section == 2){
        return 44;
    }

    return 44;
}

- (void) goTranslate{
    [self.translator translatePhrase:self.inputText.text
                                from:self.startLangCode
                                  to:self.endLangCode
                        completition:^(NSError *error, Translation *result){
        if (error == nil) {
            self.translation = result;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Autocomplete Delegation

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (textField == self.startLang) {
        self.startLangCode = ((LangCodeModel*)selectedObject).code;
        [prefs setValue:self.startLangCode forKey:kStartLanguage];
    }else if (textField == self.endLang){
        self.endLangCode = ((LangCodeModel*)selectedObject).code;
        [prefs setValue:self.endLangCode forKey:kEndLanguage];
    }else if (textField == self.inputText){

    }
    [prefs synchronize];
    
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 didChangeNumberOfSuggestions:(NSInteger)numberOfSuggestions{

    
}

#pragma mark - Language change Delegate Methods
- (void) languageChangedTo:(NSNumber *)newLanguage{
    self.currentLanguage = newLanguage;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:newLanguage forKey:kCurrentLang];
    [prefs synchronize];
    [self.languageNamesDataSource changeLanguage:newLanguage];
    
    self.startLang.text = [self.languageNamesDataSource getLangNameForCode:self.startLangCode];
    self.endLang.text = [self.languageNamesDataSource getLangNameForCode:self.endLangCode];
    
    
}

@end
