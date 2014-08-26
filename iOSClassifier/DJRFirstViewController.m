//
//  DJRMainViewController.m
//  iOSClassifier
//
//  Created by JIARUI DING on 8/26/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import "DJRFirstViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DJRSecondViewController.h"

@interface DJRFristViewController ()

@property (strong, nonatomic) DJRSecondViewController *secondViewController;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (strong, nonatomic) UIImage *image;

@end

@implementation DJRFristViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [backgroundImage setImage:[UIImage imageNamed:@"background_demo.png"]];
    [self.view insertSubview:backgroundImage
                     atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)takePictures:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker
                           animated:YES
                         completion:NULL];
    } else {
        AMSmoothAlertView *noCamAlert = [[AMSmoothAlertView alloc]
                                         initDropAlertWithTitle:@"Error"
                                         andText:@"No Camera On Your Device!"
                                         andCancelButton:NO
                                         forAlertType:AlertFailure];
        [noCamAlert show];
    }
}


- (IBAction)chooseFromLibrary:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker
                       animated:YES
                     completion:NULL];
}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        _image = info[UIImagePickerControllerEditedImage];
    } else{
        NSLog(@"Not a picture!!");
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (self.secondViewController == nil) {
        self.secondViewController = [self.storyboard
                                     instantiateViewControllerWithIdentifier:@"Second"];
    }
    self.secondViewController.selectedImage = _image;
    
    [self.view insertSubview:self.secondViewController.view
                aboveSubview:self.view];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end



