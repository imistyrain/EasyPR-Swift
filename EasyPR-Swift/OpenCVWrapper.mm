//
//  OpenCVWrapper.m
//  EasyPR-Swift
//
//  Created by yanyu on 2019/7/28.
//  Copyright © 2019 yanyu. All rights reserved.
//

#import <vector>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/types.hpp>
#import <Foundation/Foundation.h>
#import "easypr.h"
#import "CvText.h"
#import "OpenCVWrapper.h"
/// Orientation of UIImage will be lost.

std::string easypr::modeldir="/sdcard/mrcar";
CvText *pText=NULL;

static void UIImageToMat(UIImage *image, cv::Mat &mat) {
    assert(image.size.width > 0 && image.size.height > 0);
    assert(image.CGImage != nil || image.CIImage != nil);
    
    // Create a pixel buffer.
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    
    // Draw all pixels to the buffer.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (image.CGImage) {
        // Render with using Core Graphics.
        CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
        CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);
        CGContextRelease(contextRef);
    } else {
        // Render with using Core Image.
        static CIContext* context = nil; // I do not like this declaration contains 'static'. But it is for performance.
        if (!context) {
            context = [CIContext contextWithOptions:@{ kCIContextUseSoftwareRenderer: @NO }];
        }
        CGRect bounds = CGRectMake(0, 0, width, height);
        [context render:image.CIImage toBitmap:mat8uc4.data rowBytes:mat8uc4.step bounds:bounds format:kCIFormatRGBA8 colorSpace:colorSpace];
    }
    CGColorSpaceRelease(colorSpace);
    
    // Adjust byte order of pixel.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);
    
    mat = mat8uc3;
}

/// Converts a Mat to UIImage.
static UIImage *MatToUIImage(cv::Mat &mat) {
    
    // Create a pixel buffer.
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
    }
    
    // Change a image format.
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}
/// Restore the orientation to image.
static UIImage *RestoreUIImageOrientation(UIImage *processed, UIImage *original) {
    if (processed.imageOrientation == original.imageOrientation) {
        return processed;
    }
    return [UIImage imageWithCGImage:processed.CGImage scale:1.0 orientation:original.imageOrientation];
}

static void drawRotatedRects(cv::Mat &img,cv::RotatedRect rr,cv::Scalar color=cv::Scalar(255,0,0),int tickness=3){
    cv::Point2f vertices2f[4];
    rr.points(vertices2f);
    cv::Point vertices[4];
    for(int i = 0; i < 4; ++i){
        vertices[i] = vertices2f[i];
    }
    //cv::fillConvexPoly(img,vertices,4,color);
    cv::line(img,vertices[0],vertices[1],color,tickness);
    cv::line(img,vertices[1],vertices[2],color,tickness);
    cv::line(img,vertices[2],vertices[3],color,tickness);
    cv::line(img,vertices[3],vertices[0],color,tickness);
}

@implementation OpenCVWrapper
+ (nonnull UIImage *)plateRecognize:(nonnull UIImage *)image {
    cv::Mat bgrMat;
    UIImageToMat(image, bgrMat);
    easypr::CPlateRecognize pr;
    pr.setResultShow(false);
    pr.setDetectType(easypr::PR_DETECT_CMSER);
    string license;
    vector<easypr::CPlate> plateVec;
    cv::TickMeter tm;
    tm.start();
    int result= pr.plateRecognize(bgrMat, plateVec);
    tm.stop();
    for(auto pv : plateVec){
//        cout<<pv.getPlateStr()<<endl;
        drawRotatedRects(bgrMat,pv.getPlatePos());
        auto pp=pv.getPlatePos();
        cv::Point pt=pp.center;
        pt.x-=100;
        if(pt.y>=60)
            pt.y-=60;
        else
            pt.y=60;
        pText->putText(bgrMat, pv.getPlateStr(), pt, Scalar(0,0,255));
//        pt.y+=120;
//        cv::putText(bgrMat, pv.getPlateStr(), pt, 3, 1, cv::Scalar(0,0,255));
    }
    cv::putText(bgrMat,to_string(tm.getTimeMilli())+"ms", cv::Point(0,60), 3, 1, cv::Scalar(0,0,255));
    UIImage *resultImage=MatToUIImage(bgrMat);
    return RestoreUIImageOrientation(resultImage, image);
}

+ (void)setmodeldir:(NSString*)path {
    easypr::modeldir = std::string([path UTF8String])+"/model";
    //GlobalData::MainPath = std::string([path UTF8String]);
    string fontpath=easypr::modeldir+"/simhei.ttf";
    pText=new CvText(fontpath.c_str());
}

@end
