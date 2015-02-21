//
//  ViewController.m
//  Tweet-Stream
//
//  Created by William Robinson on 17/02/2015.
//  Copyright (c) 2015 William Robinson. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) id request;
@property (nonatomic, strong) NSArray *bigArray;
@property (strong, nonatomic) IBOutlet MKMapView *map;


@end

@implementation ViewController {
    
    BOOL isTweetStreamOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)see:(id)sender {
    NSLog(@"%@", self.bigArray);
}

- (IBAction)pressedTwitterButton:(UIBarButtonItem *)sender {
    
    [self toggleTwitterStream];
}

- (void)toggleTwitterStream {
    
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        NSMutableArray *testArray = [[NSMutableArray alloc] init];
        
        NSLog(@"%@", username);
        
        
         self.request = [self.twitter postStatusesFilterUserIDs:nil
                                             keywordsToTrack:@[@"Apple"]
                                       locationBoundingBoxes:nil
                                                   delimited:nil
                                               stallWarnings:nil
                                               progressBlock:^(NSDictionary *response) {
                                                   
                                                   //NSLog(@"progressBlock");
                                                   //NSLog(@"%@",response);
                                                   
                                                   if (testArray.count > 2000) {
                                                       [self.request cancel];
                                                   }
                                                   
                                                   if ([response valueForKey:@"geo"] != [NSNull null] &&
                                                       [response valueForKey:@"coordinates"] != [NSNull null]) {
                                                       
                                                       NSLog(@"%@", response);
                                                       [testArray addObject:response];
                                                       self.bigArray = testArray;
                                                       
                                                       NSDictionary *coordinates = [response valueForKey:@"coordinates"];
                                                       NSArray *coordinates2 = [coordinates valueForKey:@"coordinates"];
                                                       
                                                       
                                                       NSLog(@"%@", coordinates2[0]);
                                                       
                                                       NSNumber *lat = coordinates2[0];
                                                       NSNumber *longitude = coordinates2[1];

                                                       
                                                       CLLocationCoordinate2D coord5 = CLLocationCoordinate2DMake(longitude.doubleValue, lat.doubleValue);
                                                       MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
                                                       annotation5.title = @"judfjhdf";
                                                       annotation5.subtitle = @"@metzopaino";
                                                       [annotation5 setCoordinate:coord5];
                                                       
                                                       
                                                       [self.map addAnnotation:annotation5];
                                                       
                                                   }
                                               }
                                           stallWarningBlock:^(NSString *code, NSString *message, NSUInteger percentFull) {
                                               NSLog(@"-- stall warning");
                                           }
                                                  errorBlock:^(NSError *error) {
                                                      NSLog(@"-- %@", [error localizedDescription]);
                                                      if([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorNetworkConnectionLost) {
                                                          //[self startStreamRequest];
                                                      }
                                                  }
                   
                         ];
        
        NSLog(@"%@", testArray);
        
    } errorBlock:^(NSError *error) {
        //
        NSLog(@"%@", error.description);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
