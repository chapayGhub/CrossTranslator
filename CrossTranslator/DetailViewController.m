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
//  DetailViewController.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMeaningCell.h"
#import "NSString+HTML.h"
#import "LanguageNamesDataSource.h"

@interface DetailViewController ()
@property (strong, nonatomic) LanguageNamesDataSource *dataSource;

@end

@implementation DetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[LanguageNamesDataSource alloc] initWithUILanguage:self.uiLangCode];
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
    
    cell.meaningLabel.text = [self.dataSource getLangNameForCode:meaning.language];
    

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
