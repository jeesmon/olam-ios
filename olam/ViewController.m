//
//  ViewController.m
//  olam
//
//  Created by Jacob, Jeesmon on 10/14/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "ViewController.h"
#import "DictDao.h"
#import "EnMlDict.h"
#import "PorterStemmer.h"

@interface ViewController ()

@end

@implementation ViewController

#define SYSTEM_VERSION_LESS_THAN(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


const float kBigFontSize = 20.0f;
const float kSmallFontSize = 18.0f;

bool inFullScreen = NO;
CGRect normalFrame;
CGRect hiddenFrame;
CGRect normalViewFrame;
CGRect fullViewFrame;
float animationDuration = 0.5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        _searchBar.tintColor = [UIColor blackColor];
    }
    
	self.title = @"ഓളം";
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    parts = @{
            @"n": @"നാമം  :noun",
            @"v": @"ക്രിയ  :verb",
            @"a": @"വിശേഷണം  :adjective",
            @"adv": @"ക്രിയാവിശേഷണം  :adverb",
            @"pron": @"സര്‍വ്വനാമം  :pronoun",
            @"propn": @"സംജ്ഞാനാമം  :proper noun",
            @"phrv": @"ഉപവാക്യ ക്രിയ  :phrasal verb",
            @"conj": @"അവ്യയം  :conjunction",
            @"interj": @"വ്യാക്ഷേപകം  :interjection",
            @"prep": @"ഉപസര്‍ഗം  :preposition",
            @"pfx": @"പൂർവ്വപ്രത്യയം  :prefix",
            @"sfx": @"പ്രത്യയം  :suffix",
            @"idm": @"ഭാഷാശൈലി  :idiom",
            @"abbr": @"സംക്ഷേപം  :abbreviation",
            @"auxv": @"പൂരകകൃതി  :auxiliary verb"
    };

    _searchBar.text = @"olam";
    [self search:_searchBar.text withStem:NO];
    
    //[self setupFullScreen];
}

- (void) setupFullScreen
{
    // The normal navigation bar frame, i.e. fully visible
    normalFrame = self.navigationController.navigationBar.frame;
    
    // The frame of the hidden navigation bar (moved up by its height)
    hiddenFrame = normalFrame;
    hiddenFrame.origin.y -= CGRectGetHeight(normalFrame);
    
    // The frame of your view as specified in the nib file
    normalViewFrame = self.view.frame;
    
    // The frame of your view moved up by the height of the navigation bar
    // and increased in height by the same amount
    fullViewFrame = normalViewFrame;
    fullViewFrame.origin.y -= CGRectGetHeight(normalFrame);
    fullViewFrame.size.height += CGRectGetHeight(normalFrame);
}

- (void) toggleFullScreen
{
    if(inFullScreen) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.navigationController.navigationBar.frame = normalFrame;
                             self.view.frame = normalViewFrame;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.navigationController.navigationBar.frame = hiddenFrame;
                             self.view.frame = fullViewFrame;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    inFullScreen = !inFullScreen;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAutoCompleteTableView:nil];
    [self setSearchBar:nil];
    [self setResult:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(matches) {
        return [matches count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    
    static NSString *CellIdentifier = @"AutoCompleteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [matches objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectRowAtIndexPath");
    [self search:[matches objectAtIndex:indexPath.row] withStem:NO];
    _searchBar.text = [matches objectAtIndex:indexPath.row];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
    _autoCompleteTableView.hidden = NO;
    _result.hidden = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
    _autoCompleteTableView.hidden = YES;
    _result.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"textDidChange: %@", searchText);
    if([searchText length] > 0) {
        DictDao *dao = [[DictDao alloc] init];
        matches = [dao fetchWords:@"olam" withText:searchText];
        [_autoCompleteTableView reloadData];
    }
    else {
        matches = nil;
        [_autoCompleteTableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
    _autoCompleteTableView.hidden = YES;
    _result.hidden = NO;
    searchBar.text = nil;
    matches = nil;
    [_autoCompleteTableView reloadData];
    [_result becomeFirstResponder];
}

- (void)search:(NSString *)text withStem:(BOOL) stem {
    NSLog(@"search: %@", text);
    
    if(stem) {
        text = [PorterStemmer stemFromString:text];
        NSLog(@"stemmed text: %@", text);
    }
    
    DictDao *dao = [[DictDao alloc] init];
    NSMutableArray *rows = [dao fetchRows:@"olam" withText:text andExactMatch:!stem];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    NSString *prevEn = nil;
    NSString *prevPart = nil;
    id tempString;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.headIndent += 15.0f;
    paragraph.firstLineHeadIndent = paragraph.headIndent - 10.0f;
    
    for(EnMlDict* row in rows) {
        if(prevEn == nil || ![prevEn isEqualToString:row.en]) {
            tempString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [content appendAttributedString:tempString];
            
            tempString = [[NSMutableAttributedString alloc] initWithString:row.en attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBigFontSize]}];
            [content appendAttributedString:tempString];
            tempString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [content appendAttributedString:tempString];
            prevPart = nil;
        }
        prevEn = row.en;
        
        if([row.parts length] > 0) {
            if(prevPart == nil || ![prevPart isEqualToString:row.parts]) {
                if(prevPart != nil) {
                    tempString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
                    [content appendAttributedString:tempString];
                }
                
                NSString *part = parts[row.parts];
                if(part != nil) {
                    tempString = [[NSMutableAttributedString alloc] initWithString:part attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:kSmallFontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
                    [content appendAttributedString:tempString];
                    
                    tempString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
                    [content appendAttributedString:tempString];
                }
            }
        }
        prevPart = row.parts;
        
        tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"• %@", row.ml] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBigFontSize], NSParagraphStyleAttributeName: paragraph}];
        [content appendAttributedString:tempString];
        
        tempString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
        [content appendAttributedString:tempString];
    }
    
    bool detectLinks = NO;
    if([rows count] == 0) {
        tempString = [[NSMutableAttributedString alloc] initWithString:@"\nNo matches\n\nYou can add it at http://olam.in/Add/" attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:kSmallFontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
        [content appendAttributedString:tempString];
        detectLinks = YES;
    }
    
    //NSLog(@"%@", content);
    
    _result.attributedText = content;
    if(detectLinks) {
        _result.dataDetectorTypes = UIDataDetectorTypeLink;
    }
    [_result becomeFirstResponder];
    [_result scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text withStem:YES];
}

-(void) showInfo {
    NSLog(@"showInfo");
    _autoCompleteTableView.hidden = YES;
    _result.hidden = NO;
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    id tempString;
    
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nOlam Dictionary\n\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBigFontSize]}];
    [content appendAttributedString:tempString];
    
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"App developed by:\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kSmallFontSize]}];
    [content appendAttributedString:tempString];
    
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Jeesmon Jacob\n(jeesmon@gmail.com)\n\n"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kSmallFontSize]}];
    [content appendAttributedString:tempString];
    
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Content from:\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kSmallFontSize]}];
    [content appendAttributedString:tempString];
    
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Kailash Nadh (http://olam.in/open/enml/)"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kSmallFontSize]}];
    [content appendAttributedString:tempString];
    
    _result.attributedText = content;
    _result.dataDetectorTypes = UIDataDetectorTypeAll;
    [_result becomeFirstResponder];
}

@end
