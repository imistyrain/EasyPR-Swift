//
//  OpenCVWrapper.h
//  EasyPR-Swift
//
//  Created by yanyu on 2019/7/28.
//  Copyright © 2019 yanyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <string.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (nonnull UIImage *)plateRecognize:(nonnull UIImage *)image;
+ (nonnull UIImage *)detect:(unsigned char *)data: (int)width: (int)height;
+ (void)setmodeldir:(NSString*)path;
@end

NS_ASSUME_NONNULL_END

