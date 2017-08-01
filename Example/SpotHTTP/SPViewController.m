//
//  SPViewController.m
//  SpotHTTP
//
//  Created by yclzone on 07/07/2017.
//  Copyright (c) 2017 yclzone. All rights reserved.
//

#import "SPViewController.h"
#import "SpotHTTP.h"

@interface SPViewController ()

@end

@implementation SPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SpotHTTPManager *manager = [SpotHTTPManager manager];
    NSString *domain = @"http://www.weather.com.cn";
    NSString *patch = @"/data/sk/101110101.html";
    
    [manager requestWithDomain:domain
                          path:patch
                        method:SpotHTTPMethodGET
              sharedParameters:nil
                      printLog:YES
                    parameters:nil
                     diskCache:YES
     constructingBodyWithBlock:nil
             completionHandler:^(NSDictionary *headerFields, id responseObject, NSError *networkError) {
                 //
             }];
}

@end
