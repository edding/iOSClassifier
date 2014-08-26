//
//  DJRMainViewController.h
//  iOSClassifier
//
//  Created by JIARUI DING on 8/26/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMSmoothAlertView.h>

@interface DJRFristViewController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

- (IBAction)takePictures:(id)sender;
- (IBAction)chooseFromLibrary:(id)sender;

@end
