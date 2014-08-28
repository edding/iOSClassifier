//
//  MZCroppableView.h
//  MZCroppableView
//
//  Created by macbook on 30/10/2013.
//  Copyright (c) 2013 macbook. All rights reserved.
//

//  This work is a copy from github: mzeeshanid/MZCroppableView
//  For more details please check: https://github.com/mzeeshanid/MZCroppableView

//  Edited by JIARUI DING
//  inorder to make it work for my project, I've modified touch ended and touched moved
//  event.
//  Also, a new function:
//  (UIImage *)setMaskFor:(UIImageView *)image
//  has been added to the original version, to ad a transparent mask view above
//  the main imageView

#import <UIKit/UIKit.h>

@interface MZCroppableView : UIView

@property(nonatomic, strong) UIBezierPath *croppingPath;
@property(nonatomic, strong) UIColor *lineColor;
@property(nonatomic, assign) float lineWidth;

- (id)initWithImageView:(UIImageView *)imageView;

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2;

- (UIImage *)setMaskFor:(UIImageView *)image;

- (UIImage *)deleteBackgroundOf:(UIImageView *)image;
@end
