//
//  DJRViewController.h
//  iOSClassifier
//
//  Created by JIARUI DING on 8/26/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJRSocket.h"
// --------------------------
// Some Third Party libraries
// Attention: AMSmoothAlertView depend on GPUImage.framework, which
// does NOT work on 64bit devices
#import <AMSmoothAlertView.h>
#import <MBProgressHUD.h>
#import "MZCroppableView.h"
//
// --------------------------

@class DJRSocket;

@interface DJRSecondViewController : UIViewController
<UIActionSheetDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate> {
    UIActionSheet *sourceActionSheet;
    DJRSocket *socket;
    NSString *filePath;
    NSString *identifier;
    MBProgressHUD *HUD;
    MZCroppableView *croppableView;
    CGPoint firstTouchPoint;
    
    // used to contain data during multiThread
    BOOL error;
    char buf[BUFFER_SIZE];
    NSString *result;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) NSString *test;

- (IBAction)Upload:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end
