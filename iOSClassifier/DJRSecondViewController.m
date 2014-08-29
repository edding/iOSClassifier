//
//  DJRViewController.m
//  iOSClassifier
//
//  Created by JIARUI DING on 8/26/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import "DJRSecondViewController.h"

@interface DJRSecondViewController ()

@end


@implementation DJRSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    socket = [[DJRSocket alloc] init];
    
    // get time and use it as an unique identifier
    // the format of an identifier is <id>identifier</id>
    NSDate *now = [NSDate date];
    long long timeInterval = [now timeIntervalSince1970];
    identifier = [NSString stringWithFormat:@"<id>%lld</id>",timeInterval];
    NSLog(@"%@",identifier);
    
    // setup image and cropppable view
    [_imageView setImage:_selectedImage];
    [self setUpCroppableView];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        AMSmoothAlertView *firstLaunchAlert = [[AMSmoothAlertView alloc]
                                               initDropAlertWithTitle:@"Tips"
                                               andText:@"Please circle the area of the object you want to recognize"
                                               andCancelButton:NO
                                               forAlertType:AlertInfo];
        [firstLaunchAlert show];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_imageView setImage:_selectedImage];
}


#pragma mark - MY Methods -

- (void)setUpCroppableView {
    [_imageView setImage:_selectedImage];
    [croppableView removeFromSuperview];
    if (croppableView != nil) {
        croppableView = nil;
    }
    croppableView = [[MZCroppableView alloc] initWithImageView:_imageView];
    [self.view addSubview:croppableView];
}


#pragma mark - MY IBActions -

// Upload event
// Handle things including connection set up, upload etc.
- (IBAction)Upload:(id)sender {
    
    if (_imageView.image == nil) {
        AMSmoothAlertView *noPicAlert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error"
                                                                                  andText:@"Please select a picture."
                                                                          andCancelButton:NO
                                                                             forAlertType:AlertFailure];
        [noPicAlert setTextFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
        [noPicAlert show];
        
    } else {
        
        // Convert Pic into NSData
        NSData *data;
        UIImage *savedImage = [croppableView deleteBackgroundOf:_imageView];
        
        if (savedImage == nil) {
            // when there is no line drawn by the user, notify the server to
            // use OVERSAMPLE mode, inorder to enhace the accuracy
            savedImage = _imageView.image;
            
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s","OVERSAMPLE_TRUE");
            [socket send:buf withSize:1024];
        } else {
            // notify the server to set OVERSAMPLE as false, as the user
            // has cricled the interested spot.
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s","OVERSAMPLE_FALSE");
            [socket send:buf withSize:1024];
        }

        
        if (UIImagePNGRepresentation(savedImage) == nil) {
            data = UIImageJPEGRepresentation(savedImage, 1.0);
        } else {
            data = UIImagePNGRepresentation(savedImage);
        }
        
        // Save picture in the 'tmp' folder for uploading
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,@"/image.jpg"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        NSLog(@"%@",DocumentsPath);
        
        // create a HUD for processing work
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
        }
        [self.view addSubview:HUD];
        HUD.labelText = @"Analyzing";
        error = NO;
        
        [HUD showAnimated:YES
      whileExecutingBlock:
    ^{
        if ([socket setupConnection:[NSString stringWithFormat:@"%s",IP_ADDR]] == 0) {
            NSLog(@"connected!");
            
            // Tell the server to prepare for receiving
            memset(buf, 0, sizeof(buf));
            NSString *prepare = [NSString stringWithFormat:@"%@", identifier];
            sprintf(buf, "%s",[prepare UTF8String]);
            [socket send:buf withSize:1024];
            
            // Uploading process
            int count = 0;
            int readFile = open([filePath UTF8String], O_RDONLY);
            while (true) {
                memset(buf, 0, sizeof(buf));
                if (read(readFile, buf, BUFFER_SIZE) <= 0) {
                    break;
                }
                [socket send:buf];
                NSLog(@"%d\n",count++);
            }
            close(readFile);
            
            // Tell the server that this is the end of the file
            memset(buf, 0, sizeof(buf));
            NSString *eof = [NSString stringWithFormat:@"<END OF FILE>"];
            sprintf(buf, "%s",[eof UTF8String]);
            [socket send:buf];
            
            // get the result
            memset(buf, 0, sizeof(buf));
            [socket recv:buf];
            result = [NSString stringWithFormat:@"%s",buf];
            
            // Say good bye to the server and release the connection
            memset(buf, 0, sizeof(buf));
            NSString *bye = [NSString stringWithFormat:@"bye"];
            sprintf(buf, "%s",[bye UTF8String]);
            [socket send:buf];
            
            [socket releaseConnection];
        }
        else {
            // record connection error
            error = YES;
        }

      }
          completionBlock:
         ^{
             if (error == NO) {
                 AMSmoothAlertView *resultAlert = [[AMSmoothAlertView alloc]
                                                   initDropAlertWithTitle:@"Result"
                                                   andText:result
                                                   andCancelButton:NO
                                                   forAlertType:AlertSuccess];
                 [resultAlert show];
             } else {
                 // cannot connect to the server
                 AMSmoothAlertView *timeoutAlert = [[AMSmoothAlertView alloc]
                                                    initDropAlertWithTitle:@"Error"
                                                    andText:@"Can't connect to the server"
                                                    andCancelButton:NO
                                                    forAlertType:AlertFailure];
                 [timeoutAlert setTextFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
                 [timeoutAlert show];
             }

          }];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    // set Animations to change the view
    [UIView beginAnimations:@"View Flip" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.view.superview cache:YES];
    
    [self setUpCroppableView];
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
}

- (IBAction)resetButtonPressed:(id)sender {
    [self setUpCroppableView];
}


#pragma mark - Touch Methods -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Record first touch position for later use
    UITouch *firstTouch=[[touches allObjects] objectAtIndex:0];
    firstTouchPoint = [firstTouch locationInView:self.view];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect imageViewFrame = self.imageView.frame;
    // check whether the first touch point is located in image view frame
    // only respond to those circles that start with a poin within the frame
    if (CGRectContainsPoint(imageViewFrame, firstTouchPoint)) {
        UIImage *maskedImage = [croppableView setMaskFor:_imageView];
        [_imageView setImage:maskedImage];
    }
}

@end
