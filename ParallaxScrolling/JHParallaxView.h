/*
 JHParallaxView.h
 Copyright (C) 2014 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
@class JHParallaxView;
typedef enum
{
    JHBlurEffect = 1 << 0,
    JHScaleEffect = 1 << 1,
    JHScollEffect = 1 << 2,
}
JHParallaxEffect;

#import <UIKit/UIKit.h>

@protocol JHParallaxViewDelegate <NSObject>
- (void)parallaxViewDidScrollToCenter:(JHParallaxView *)inView;
- (void)parallaxViewDidScrollToOrigianl:(JHParallaxView *)inView;
@end
@interface JHParallaxView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
@property (nonatomic, assign) CGFloat backgroundHeight;
@property (nonatomic, assign) JHParallaxEffect effect;
@property (nonatomic, weak) id <JHParallaxViewDelegate> delegate;
@property (nonatomic, strong) UIView *headerView;

- (id)initWithBackgroundView:(UIView *)backgroundView foregroundView:(UIView *)foregroundView;

- (id)initWithBackgroundView:(UIView *)backgroundView foregroundView:(UIView *)foregroundView frame:(CGRect)frame backgroundHeight:(CGFloat)height;

@end
