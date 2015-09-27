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
#import "SelectLangViewController.h"
#import "GUILanguageManager.h"

#import "MBProgressHUD.h"


@interface MasterViewController() <MLPAutoCompleteTextFieldDelegate,LanguageChangedDelegate>

@property (strong, nonatomic) NSString *startLangCode;
@property (strong, nonatomic) NSString *endLangCode;
@property (strong, nonatomic) NSString *inputString;


@property (strong, nonatomic) MLPAutoCompleteTextField *inputText;
@property (weak, nonatomic) MLPAutoCompleteTextField *startLang;
@property (weak, nonatomic) MLPAutoCompleteTextField *endLang;

@property (strong, nonatomic) UITextView *translatedText;

@property (strong, nonatomic) NSNumber *currentLanguage;

@property (strong, nonatomic) TranslatorFacade *translator;
@property (strong, nonatomic) Translation *translation;
@property (strong, nonatomic) KnownWordsDataSource * knownWordsDataSource;
@property (strong, nonatomic) LanguageNamesDataSource *languageNamesDataSource;


/**
 *  has suggestions tracks the state of the Autocomplete Text Fields,
 *  whether they are displaying suggestions or not. 
 *  This is needed when user taps outside of soft keyboard
 */
@property (nonatomic) BOOL hasSuggestions;
@property (nonatomic) BOOL isValid;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.translator = [[TranslatorFacade alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //Load user Prefernces
    self.currentLanguage = [prefs objectForKey:kCurrentLang];
    self.startLangCode = [prefs objectForKey:kStartLanguage];
    self.endLangCode = [prefs objectForKey:kEndLanguage];
    
    
    self.knownWordsDataSource = [[KnownWordsDataSource alloc] initWithStartLanguage:self.startLangCode destinationLanguage:self.endLangCode];
    self.languageNamesDataSource = [[LanguageNamesDataSource alloc] initWithUILanguage:self.currentLanguage];
    
    self.translation = nil;
    
    
    // Register for UI language changes notifications in order to update UI accordingly
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUIStrings:)
                                                 name:kUILanguageLoaded
                                               object:nil];
    
    
    // Hide keyboard on tap outside the text fields
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

- (void) dismissKeyboard {
    // Don't dismiss keyboard if Autocomplete is tableview has appeared.
    // User should select an option from autocomplete
    if (!self.hasSuggestions) {
        [self.inputText resignFirstResponder];
    }
}

/**
 *  In this method are updated all UI elements with the new language Strings
 *
 *  @param notification The notification that arrived
 */
- (void) updateUIStrings:(NSNotification*)notification{
    
    [self.tableView reloadData];
    self.navigationItem.title = [GUILanguageManager getUIStringForCode:@"main_title"];
}

- (void) dealloc{
    //In order to dealloc this object succesfully remove it from Notification Center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Checks if the Content of the Text Field is valid input to be translated
 *
 *  @param aString Content of Text Field
 *
 *  @return Is valid string
 */
- (BOOL)checkField:(NSString *)aString{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSArray* matches = [regex matchesInString:aString
                                      options:0
                                        range:NSMakeRange(0, [aString length])];
    if ([matches count] > 0) {
        return NO;
    }
    return YES;
}

/**
 *  If user entered invalid String change the Text Field text color
 */
-(void) userEnteredInputText{
    self.isValid = [self checkField:self.inputText.text];
    if (self.isValid) {
        self.inputText.textColor = [UIColor blackColor];
    }else{
        self.inputText.textColor = [UIColor redColor];
        
    }
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Opens the details of this Translation
    if ([[segue identifier] isEqualToString:@"showMeaning"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tuc *tuc = [self.translation.result.tuc objectAtIndex:indexPath.row];
        if ((tuc.meanings == nil) || ([tuc.meanings count] == 0)) {
            return;
        }
        Tuc *object = [self.translation.result.tuc objectAtIndex:indexPath.row];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        controller.tuc = object;
        controller.navigationItem.leftItemsSupplementBackButton = YES;

    // Opens the change Language ViewController
    }else if([[segue identifier] isEqualToString:@"showOptions"]){
        SelectLangViewController * dest = (SelectLangViewController*) [segue destinationViewController];
        dest.delegate = self;
        dest.currentLanguage = self.currentLanguage;
        dest.managedObjectContext = self.managedObjectContext;
    }
}


/**
 *  Some cells contain a Translation that does not have detailed explanation
 *  In this case we forbid the segue for the DetailViewController
 *
 *  @param identifier identifier of the segue
 *  @param sender
 *
 *  @return
 */
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showMeaning"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tuc *tuc = [self.translation.result.tuc objectAtIndex:indexPath.row];
        if ((tuc.meanings == nil) || ([tuc.meanings count] == 0)) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // If there is no translation yet display only the Input TableViewCell
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
            sectionName = [GUILanguageManager getUIStringForCode:@"main_input_sct"];
            break;
        case 1:
            sectionName = [GUILanguageManager getUIStringForCode:@"Wiki Link"];
            break;
        case 2:
            sectionName = [GUILanguageManager getUIStringForCode:@"Play Audio"];
            break;
        case 3:
            sectionName = [GUILanguageManager getUIStringForCode:@"Translation"];
            break;
        default:
            sectionName = [GUILanguageManager getUIStringForCode:@""];
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


/**
 *  Customize the Output (translation entry) cell
 *
 *  @param tCell     a ToLanguageCell
 *  @param indexPath selected IndexPath
 */
- (void)customizeOutputCell:(ToLanguageCell*)tCell inIndexPath:(NSIndexPath*)indexPath{
    Tuc *tuc = [self.translation.result.tuc objectAtIndex:indexPath.row];
    
    
    // Don't show accessory image for translation expression without further details
    if ((tuc.meanings == nil) || ([tuc.meanings count] == 0)) {
        tCell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        // Even though the default value in Interface Builder is UITableViewCellAccessoryDisclosureIndicator
        // the else clause is needed due to cell reuse
        tCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (tuc.phrase == nil) {
        if([tuc.meanings count] > 0){
            tCell.translatePhrase.text = ((Meaning*)[tuc.meanings objectAtIndex:0]).text;
            tCell.translateLabel.text = [self.languageNamesDataSource getLangNameForCode:((Meaning*)[tuc.meanings objectAtIndex:0]).language];
        }
    }else{
        tCell.translatePhrase.text = tuc.phrase.text;
        tCell.translateLabel.text = [self.languageNamesDataSource getLangNameForCode:tuc.phrase.language];
    }
    
    if ([tuc.authors count] > 0) {
        NSString *authorKey = [NSString stringWithFormat:@"%d",[[tuc.authors objectAtIndex:0] intValue]];
        tCell.authorValue.text = [[self.translation.result.authors valueForKey:authorKey] valueForKey:@"U"];
    }
    tCell.selectionStyle = UITableViewCellSelectionStyleNone;
}


// Open Safari at the correct Wiki Url
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.wikipedia.org/wiki/%@", self.startLangCode,self.inputText.text]]];
    }
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
        
        ToLanguageCell* tCell;
        tCell = (ToLanguageCell*)[tableView dequeueReusableCellWithIdentifier:toLangCellID
                                                                forIndexPath:indexPath];
        [self customizeOutputCell:tCell inIndexPath:indexPath];
        return tCell;
        
    }else if (indexPath.section == 1){
        cell = (WikiSuggestsCell*)[tableView dequeueReusableCellWithIdentifier:wikiCellID
                                                                  forIndexPath:indexPath];
        ((WikiSuggestsCell*)cell).linkLabel.text = [NSString stringWithFormat:@"https://%@.wikipedia.org/wiki/%@", self.startLangCode,self.inputText.text];
        
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
    
    
    cell.titleLabel.text = [GUILanguageManager getUIStringForCode:@"main_input_lbl"];
    cell.fromLang.text = [GUILanguageManager getUIStringForCode:@"main_from_lbl"];
    cell.toLang.text = [GUILanguageManager getUIStringForCode:@"main_to_lbl"];
    [cell.translate setTitle:[GUILanguageManager getUIStringForCode:@"main_trn_btn"] forState:UIControlStateNormal];
    
    self.inputText = cell.inputText;
    self.inputText.autoCompleteDataSource = self.knownWordsDataSource;
    self.inputText.autoCompleteDelegate = self;
    
    [self.inputText addTarget:self
                       action:@selector(userEnteredInputText)
             forControlEvents:UIControlEventEditingDidEnd];
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = [GUILanguageManager getUIStringForCode:@"Translating"];
    
    // if is in valid state do translate
    if (self.isValid) {
        [self.translator translatePhrase:self.inputText.text
                                    from:self.startLangCode
                                      to:self.endLangCode
                            completition:^(NSError *error, Translation *result){
                                //Hide HUD regardless of translation outcome
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                
                                
                                if (error == nil) {
                                    self.translation = result;
                                    [self.tableView reloadData];
                                }else{
                                    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                                     message:[error localizedDescription]
                                                                                    delegate:self
                                                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                           otherButtonTitles: nil];
                                    [alert show];
                                }
                            }];
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", nil)
                                                         message:@"Invalid Input string"
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Autocomplete Delegation
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //Save user selection in the preferences
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    LangCodeModel *lcm = (LangCodeModel*)selectedObject;
    BOOL changes = NO;
    
    if (textField == self.startLang) {
        if (![lcm.code isEqualToString:self.startLangCode]) {
            self.startLangCode = lcm.code;
            [prefs setValue:self.startLangCode forKey:kStartLanguage];
            changes =YES;
        }
    }else if (textField == self.endLang){
        if (![lcm.code isEqualToString:self.endLangCode]) {
            self.endLangCode = ((LangCodeModel*)selectedObject).code;
            [prefs setValue:self.endLangCode forKey:kEndLanguage];
            changes = YES;
        }
    }else if (textField == self.inputText){

    }
    
    if (changes) {
        [prefs synchronize];
        // One of the languages (source and/or destination) has changed
        // create a new autocomplete datasource object with the new languages
        // one would not expect to autocomplete for the same word but different source languages
        
        self.knownWordsDataSource = [[KnownWordsDataSource alloc] initWithStartLanguage:self.startLangCode destinationLanguage:self.endLangCode];
        self.inputText.autoCompleteDataSource = self.knownWordsDataSource;
    }
    self.hasSuggestions = NO;
    
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 didChangeNumberOfSuggestions:(NSInteger)numberOfSuggestions{
    if (numberOfSuggestions == 0) {
        self.hasSuggestions = NO;
    }
}
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView{
    self.hasSuggestions = YES;
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
