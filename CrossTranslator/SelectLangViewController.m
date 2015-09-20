//
//  SelectLangViewController.m
//  CrossTranslator
//
//  Created by Andi Palo on 20/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "SelectLangViewController.h"
#import "LanguageNamesDataSource.h"
#import "LangCodeModel.h"

@interface SelectLangViewController ()
@property (strong, nonatomic) NSArray *displayObjects;
@property (strong, nonatomic) LanguageNamesDataSource *ds;
@end

@implementation SelectLangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        self.displayObjects = results;
    }
    
    self.ds = [[LanguageNamesDataSource alloc] initWithUILanguage:self.currentLanguage];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* langCellID = @"LangCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:langCellID];
    NSString* code = ((LangCodeModel*)[self.displayObjects objectAtIndex:indexPath.row]).code;
    cell.textLabel.text = [self.ds getLangNameForCode:code];
    
    if (indexPath.row == [self.currentLanguage integerValue]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != [self.currentLanguage integerValue]) {
        [self.delegate languageChangedTo:((LangCodeModel*)[self.displayObjects objectAtIndex:indexPath.row]).index];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
