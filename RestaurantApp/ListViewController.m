//
//  ListViewController.m
//  RestaurantApp
//
//  Created by Robert Baghai on 5/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

#import "ListViewController.h"
#import "Constants.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions
- (IBAction)goBackToMap:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
