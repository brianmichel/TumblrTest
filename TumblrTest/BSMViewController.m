//
//  BSMViewController.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "BSMViewController.h"
#import "BSMPost.h"
#import "BSMTumblrDatabase.h"

@interface BSMViewController ()
@property (strong) dispatch_queue_t processingQueue;
@end

@implementation BSMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.processingQueue = dispatch_queue_create("com.bsm.tumblr.processing", DISPATCH_QUEUE_CONCURRENT);
    
    [[TMAPIClient sharedInstance] dashboard:nil callback:^(id dashboard, NSError *error) {
        if (dashboard) {
            dispatch_async(self.processingQueue, ^{
                NSArray *posts = dashboard[@"posts"];
                for (NSDictionary *post in posts) {
                    NSError *error = nil;
                    BSMPost *postModel = [MTLJSONAdapter modelOfClass:[BSMPost class] fromJSONDictionary:post error:&error];
                    [[BSMTumblrDatabase sharedDatabase] savePost:postModel];
                    NSLog(@"BASE POST: %@", postModel);
                }
            });
        }

    }];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
