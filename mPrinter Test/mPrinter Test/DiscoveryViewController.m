//
//  DiscoveryViewController.m
//  mPrinter Test
//
//  Created by Andy Muldowney on 7/25/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "ViewController.h"

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create a mutable array to hold our printers
    self.printers = [[NSMutableArray alloc] init];
    
    // Setup our activity indicator
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Clear our printers
    self.printers = [[NSMutableArray alloc] init];
    
    [self.refreshControl beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)foundPrinter:(NSString *)ip {
    [self.printers addObject:ip];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.printers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[self.printers objectAtIndex:[indexPath row]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *vc = (ViewController *)self.callingViewController;
    [vc setActivePrinter:[self.printers objectAtIndex:[indexPath row]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
