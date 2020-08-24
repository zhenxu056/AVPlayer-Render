//
//  SKPixelBufferDisplayView.h
//  AVPlayer+Render
//
//  Created by Sunflower on 2020/8/24.
//  Copyright © 2020 Sunflower. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKPixelBufferDisplayView : UIView

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
