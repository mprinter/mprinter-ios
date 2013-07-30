//
//  ViewController.m
//  mPrinter Test
//
//  Created by Andy Muldowney on 7/22/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printer = [[mPrinter alloc] init];
    [printer setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)discover:(id)sender {
    [self performSegueWithIdentifier:@"ShowDiscovery" sender:self];
    [printer discoverPrinters];
}

- (IBAction)feed:(id)sender {
    [printer feed];
}

- (IBAction)printTest:(id)sender {
    [printer clear];
    [printer addImage:[UIImage imageNamed:@"mPrinter.bundle/img/mprinter_logo_mono.png"]];
    [printer addBlankLines:10];
    [printer addLine:MPrinterLineStyleDiagonal3 height:10.0f];
    [printer addBlankLines:10];
    [printer addText:@"Sample Test" size:24.0f];
    [printer addText:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce quis purus sed dui molestie ornare. Donec molestie blandit quam eu lobortis. Ut condimentum convallis elit et sollicitudin. Mauris blandit nunc at dui ornare pulvinar eu elementum lacus. Cras vehicula dictum ullamcorper. Nullam ornare lectus mauris, nec consequat dui porta a. Phasellus nec mauris urna. Sed accumsan diam quis interdum iaculis. Aliquam eget odio accumsan, elementum odio ut, tincidunt enim. Duis gravida id purus in volutpat." size:14.0f];
    [printer print];
}

#pragma mark - MPrinterDelegate
- (void)didDiscoverPrinter:(NSString *)ip {
    if (discoveryView) {
        [discoveryView foundPrinter:ip];
    }
}

#pragma mark - Helper functions
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDiscovery"]) {
        discoveryView = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
        discoveryView.callingViewController = self;
    }
}

- (void)setActivePrinter:(NSString *)ip {
    [printer setPrinterIP:ip];
    [self.statusLabel setText:[NSString stringWithFormat:@"Connected to %@", ip]];
    [self.printButton setEnabled:YES];
    [self.feedButton setEnabled:YES];
}

@end
