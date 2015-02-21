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
#import <CoreData/CoreData.h>
#import "Tweet.h"

@interface ViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) id request;
@property (nonatomic, strong) NSArray *bigArray;
@property (strong, nonatomic) IBOutlet MKMapView *map;


//@property (nonatomic, strong) NSManagedObject *tweets;

@end

@implementation ViewController {
    
    BOOL isTweetStreamOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.tweets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
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
                                             keywordsToTrack:@[@"hi"]
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
                                                       
                                                       NSNumber *longitude = coordinates2[0];
                                                       NSNumber *latitude = coordinates2[1];

                                                       
                                                       CLLocationCoordinate2D coord5 = CLLocationCoordinate2DMake(longitude.doubleValue, latitude.doubleValue);
                                                       MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
                                                       annotation5.title = [response objectForKey:@"text"];
                                                       NSDictionary *user = [response objectForKey:@"user"];

                                                       annotation5.subtitle = [user objectForKey:@"screen_name"];
                                                       [annotation5 setCoordinate:coord5];
                                                       
                                                       
                                                       [self.map addAnnotation:annotation5];
                                                       
                                                       
                                                       NSNumber *testNu = [response objectForKey:@"timestamp_ms"];
                                                       
                                                       NSTimeInterval seconds = [testNu doubleValue] / 1000;
                                                       
                                                       NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                                                       
                                                       
                                                       
                                                       NSManagedObjectContext *context = self.managedObjectContext;
                                                       NSManagedObject *tweet = [NSEntityDescription
                                                                                          insertNewObjectForEntityForName:@"Tweet"
                                                                                          inManagedObjectContext:context];
                                                       [tweet setValue:[response objectForKey:@"text"] forKey:@"text"];
                                                       [tweet setValue:[user objectForKey:@"screen_name"] forKey:@"username"];
                                                       [tweet setValue:longitude forKey:@"longitude"];
                                                       [tweet setValue:latitude forKey:@"latitude"];
                                                       [tweet setValue:date forKey:@"date"];
//                                                       NSManagedObject *failedBankDetails = [NSEntityDescription
//                                                                                             insertNewObjectForEntityForName:@"FailedBankDetails"
//                                                                                             inManagedObjectContext:context];
//                                                       [failedBankDetails setValue:[NSDate date] forKey:@"closeDate"];
//                                                       [failedBankDetails setValue:[NSDate date] forKey:@"updateDate"];
//                                                       [failedBankDetails setValue:[NSNumber numberWithInt:12345] forKey:@"zip"];
//                                                       [failedBankDetails setValue:failedBankInfo forKey:@"info"];
//                                                       [failedBankInfo setValue:failedBankDetails forKey:@"details"];
                                                       NSError *error;
                                                       if (![context save:&error]) {
                                                           NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                                                       }
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
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
