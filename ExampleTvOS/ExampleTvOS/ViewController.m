//
//  ViewController.m
//  ExampleTvOS
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 npaw. All rights reserved.
//

#import "ViewController.h"
#import "ImaPlayerViewController.h"
#import "ImaDaiPlayerViewController.h"
#import "ExampleTvOS-Swift.h"

@import YouboraConfigUtils;

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ImaPlayerViewController class]]) {
        ((ImaPlayerViewController*)segue.destinationViewController).viewModel = [ImaViewModelSwift new];
        return;
    }
    
    if ([segue.destinationViewController isKindOfClass:[ImaDaiPlayerViewController class]]) {
        ((ImaDaiPlayerViewController*)segue.destinationViewController).viewModel = [ImaViewModelSwift new];
        return;
    }
}

- (IBAction)pressAtSettings:(id)sender {
    [self.navigationController pushViewController:[YouboraConfigViewController initFromXIB] animated:true];
}

@end
