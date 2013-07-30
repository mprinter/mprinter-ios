//
//  DiscoveryViewController.h
//  mPrinter Test
//
//  Created by Andy Muldowney on 7/25/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoveryViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *printers;
@property (nonatomic, retain) UIViewController *callingViewController;

- (IBAction)dismiss:(id)sender;
- (void)foundPrinter:(NSString *)ip;

@end
