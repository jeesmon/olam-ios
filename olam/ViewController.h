//
//  ViewController.h
//  olam
//
//  Created by Jacob, Jeesmon on 10/14/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSMutableArray *matches;
    NSDictionary *parts;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *autoCompleteTableView;

@property (weak, nonatomic) IBOutlet UITextView *result;

@end
