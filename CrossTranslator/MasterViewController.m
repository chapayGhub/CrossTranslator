// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  MasterViewController.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

//System
#import <AudioToolbox/AudioToolbox.h>


//Custom Cells
#import "FromLanguageCell.h"
#import "ToLanguageCell.h"
#import "WikiSuggestsCell.h"
#import "GoogleAudioCell.h"

// Models and Utils
#import "Constants.h"
#import "TranslatorFacade.h"
#import "KnownWordsDataSource.h"
#import "LanguageNamesDataSource.h"
#import "LangCodeModel.h"
#import "SelectLangViewController.h"
#import "GUILanguageManager.h"

//External libs
#import "MLPAutoCompleteTextField.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "Chameleon/Chameleon.h"
#import "Chameleon.h"


@interface MasterViewController() <MLPAutoCompleteTextFieldDelegate,LanguageChangedDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *startLangCode;
@property (strong, nonatomic) NSString *endLangCode;
@property (strong, nonatomic) NSString *inputString;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *inputText;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *startLang;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *endLang;
@property (weak, nonatomic) IBOutlet UIButton *swapLangs;
@property (weak, nonatomic) IBOutlet UIButton *translate;



@property (strong, nonatomic) NSNumber *currentLanguage;

@property (strong, nonatomic) TranslatorFacade *translator;
@property (strong, nonatomic) Translation *translation;
@property (strong, nonatomic) KnownWordsDataSource * knownWordsDataSource;
@property (strong, nonatomic) LanguageNamesDataSource *languageNamesDataSource;


@property (nonatomic) BOOL networkIsReachable;

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
    
    
    self.knownWordsDataSource = [[KnownWordsDataSource alloc] init];
    [self.knownWordsDataSource setMOC:self.managedObjectContext];
    self.languageNamesDataSource = [[LanguageNamesDataSource alloc] initWithUILanguage:self.currentLanguage];
    
    self.translation = nil;
    
    
    
    self.navigationController.navigationBar.tintColor = FlatWhite;
    self.navigationController.navigationBar.barTintColor = FlatRed;
    [self.navigationController setStatusBarStyle:UIStatusBarStyleContrast];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:FlatWhite, NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

    
    
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
    
    [self customizeFixedHeader];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self monitorNetworkState];
}

- (void) customizeFixedHeader{
    [self.translate addTarget:self
                       action:@selector(goTranslate)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.translate setTitle:[GUILanguageManager getUIStringForCode:@"main_trn_btn"] forState:UIControlStateNormal];
    
    [self.swapLangs addTarget:self action:@selector(swapLanguages) forControlEvents:UIControlEventTouchUpInside];
    
 
    self.inputText.placeholder = [GUILanguageManager getUIStringForCode:@"main_input_lbl"];
    self.inputText.autoCompleteDataSource = self.knownWordsDataSource;
    self.inputText.autoCompleteDelegate = self;
    
    [self.inputText addTarget:self
                       action:@selector(userEnteredInputText)
             forControlEvents:UIControlEventEditingDidEnd];
    
    self.startLang.autoCompleteDataSource = self.languageNamesDataSource;
    self.startLang.autoCompleteDelegate = self;
    
    self.endLang.autoCompleteDataSource = self.languageNamesDataSource;
    self.endLang.autoCompleteDelegate = self;
    
    
    if (self.startLangCode != nil) {
        [self.startLang setText:[self.languageNamesDataSource getLangNameForCode:self.startLangCode]];
    }
    if (self.endLangCode != nil) {
        self.endLang.text = [self.languageNamesDataSource getLangNameForCode:self.endLangCode];
    }
}

- (void) monitorNetworkState{
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"Network unreachable");
        _networkIsReachable = YES;
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        if (!_networkIsReachable) {
            return;
        }
        _networkIsReachable = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:[GUILanguageManager getUIStringForCode:@"No Internet Connection"]
                                                             message:[GUILanguageManager getUIStringForCode:@"No more translations from remote service, only cached words will be displayed"]
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                   otherButtonTitles: nil];
            [alert show];
        });
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
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
        controller.uiLangCode = self.currentLanguage;
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
    return self.translation == nil ? 0 : 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1){
        if (self.translation == nil) {
            return 0;
        }else{
            return [self.translation.result.tuc count];
        }
    }else if (section == 0){
        return self.translation == nil ? 0 : 1;
    }
    
    return 0;
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
        }
    }else{
        tCell.translatePhrase.text = tuc.phrase.text;
    }
    
    if ([tuc.authors count] > 0) {
        NSString *authorKey = [NSString stringWithFormat:@"%d",[[tuc.authors objectAtIndex:0] intValue]];
        tCell.authorValue.text = [[self.translation.result.authors valueForKey:authorKey] valueForKey:@"U"];
    }
    [tCell.speakLoad addTarget:self
                        action:@selector(gtts:)
              forControlEvents:UIControlEventTouchUpInside];
    
    tCell.selectionStyle = UITableViewCellSelectionStyleNone;
}


// Open Safari at the correct Wiki Url
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.wikipedia.org/wiki/%@", self.startLangCode,self.inputText.text]]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* toLangCellID = @"ToTranslate";
    static NSString* wikiCellID = @"WikiSuggests";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 1){
        
        ToLanguageCell* tCell;
        tCell = (ToLanguageCell*)[tableView dequeueReusableCellWithIdentifier:toLangCellID
                                                                forIndexPath:indexPath];
        [self customizeOutputCell:tCell inIndexPath:indexPath];
        return tCell;
        
    }else if (indexPath.section == 0){
        cell = (WikiSuggestsCell*)[tableView dequeueReusableCellWithIdentifier:wikiCellID
                                                                  forIndexPath:indexPath];
        ((WikiSuggestsCell*)cell).linkLabel.text = [NSString stringWithFormat:@"https://%@.wikipedia.org/wiki/%@", self.startLangCode,self.inputText.text];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (double) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return 90;
    }else if (indexPath.section == 0){
        return 44;
    }

    return 44;
}

- (void) goTranslate{
    
    
    // if is in valid state do translate
    if (self.isValid) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = [GUILanguageManager getUIStringForCode:@"Translating"];
        
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

- (void) swapLanguages{
    NSString *temp = self.startLangCode;
    self.startLangCode = self.endLangCode;
    self.endLangCode = temp;
    
    temp = self.startLang.text;
    self.startLang.text = self.endLang.text;
    self.endLang.text = temp;
    
}

- (void)gtts:(id) sender{
    
    //call button was pressed on a row, find the point of the screen of this info button
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    
    //Find the row that corresponds to this point
    NSIndexPath *ipath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    Phrase *selectedPhrase = [self.translation.result.tuc objectAtIndex:ipath.row];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"file.mp3"];

    NSString *urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",selectedPhrase];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url] ;
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" forHTTPHeaderField:@"User-Agent"];
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    [data writeToFile:path atomically:YES];

    SystemSoundID soundID;
    NSURL *url2 = [NSURL fileURLWithPath:path];

    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url2, &soundID);
    AudioServicesPlaySystemSound (soundID);
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
