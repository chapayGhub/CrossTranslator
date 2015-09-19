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

@interface MasterViewController ()

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

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.translator = [[TranslatorFacade alloc] init];
    //[self.translator translatePhrase:@"begin" from:@"en" to:@"it" completition:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentLanguage = [prefs objectForKey:kCurrentLang];
    self.translation = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tuc *object = [self.translation.result.tuc objectAtIndex:indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.tuc = object;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.translation == nil ? 1 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1){
        if (self.translation == nil) {
            return 0;
        }else{
            return [self.translation.result.tuc count];
        }
    }else if (section == 2){
        return self.translation == nil ? 0 : 1;
    }else if (section == 3){
        return self.translation == nil ? 0 : 1;
    }
    
    return 0;
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
        
        [((FromLanguageCell*)cell).translate addTarget:self action:@selector(goTranslate) forControlEvents:UIControlEventTouchUpInside];
    }else if (indexPath.section == 1){
        cell = (ToLanguageCell*)[tableView dequeueReusableCellWithIdentifier:toLangCellID
                                                                forIndexPath:indexPath];
        Tuc *tuc = [self.translation.result.tuc objectAtIndex:indexPath.row];
        ((ToLanguageCell*)cell).translatePhrase.text = tuc.phrase.text;
        
    }else if (indexPath.section == 2){
        cell = (WikiSuggestsCell*)[tableView dequeueReusableCellWithIdentifier:wikiCellID
                                                                  forIndexPath:indexPath];
    }else if (indexPath.section == 3){
        cell = (GoogleAudioCell*)[tableView dequeueReusableCellWithIdentifier:googleAudioCellID
                                                                 forIndexPath:indexPath];
        
    }
    return cell;
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
        return 195;
    }else if (indexPath.section == 1){
        return 134;
    }else if (indexPath.section == 2){
        return 44;
    }else if (indexPath.section == 3){
        return 44;
    }

    return 44;
}

- (void) goTranslate{
    
    
    
    [self.translator translatePhrase:@"begin" from:@"en" to:@"it" completition:^(NSError *error, Translation *result){
        if (error == nil) {
            self.translation = result;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
