//
//  DetailViewController.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMeaningCell.h"
#import "NSString+HTML.h"

@interface DetailViewController ()

@end

@implementation DetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tuc.meanings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* meaningCellID = @"DetailMeaning";

    DetailMeaningCell *cell = (DetailMeaningCell*)[tableView dequeueReusableCellWithIdentifier:meaningCellID
                                                                               forIndexPath:indexPath];
    
    Meaning *meaning = [self.tuc.meanings objectAtIndex:indexPath.row];
    cell.meaningValue.text = [meaning.text stringByConvertingHTMLToPlainText];
    

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
