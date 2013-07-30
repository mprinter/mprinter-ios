//
//  ViewController.h
//  mPrinter Test
//
//  Created by Andy Muldowney on 7/22/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mPrinter/mPrinter.h"
#import "DiscoveryViewController.h"

@interface ViewController : UIViewController <mPrinterDelegate> {
    mPrinter *printer;
    DiscoveryViewController *discoveryView;
}

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *feedButton;
@property (nonatomic, retain) IBOutlet UIButton *printButton;

- (IBAction)discover:(id)sender;
- (IBAction)feed:(id)sender;
- (IBAction)printTest:(id)sender;

- (void)setActivePrinter:(NSString *)ip;

@end