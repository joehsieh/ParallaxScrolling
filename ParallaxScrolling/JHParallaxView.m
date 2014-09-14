/*
 JHParallaxView.m
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

#import "JHParallaxView.h"

static CGFloat const kDefaultBackgroundHeight = 250.0;

@interface JHParallaxView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) UIScrollView *backgroundScrollView;
@property (nonatomic, strong) UIScrollView *headerScrollView;
@property (nonatomic, strong) UIScrollView *foregroundScrollView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, weak) id <JHParallaxViewDelegate> delegate;
@end

@implementation JHParallaxView

#pragma mark - Constructor

- (id)initWithBackgroundView:(UIView *)backgroundView foregroundView:(UIView *)foregroundView delegate:(id)delegate;
{
    return [self initWithBackgroundView:backgroundView foregroundView:foregroundView frame:[UIScreen mainScreen].bounds backgroundHeight:kDefaultBackgroundHeight delegate:delegate];
}

- (id)initWithBackgroundView:(UIView *)backgroundView foregroundView:(UIView *)foregroundView frame:(CGRect)frame backgroundHeight:(CGFloat)height delegate:(id)delegate;
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), height);
        foregroundView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _backgroundView = backgroundView;
        _foregroundView = foregroundView;
        
        _backgroundScrollView = [[UIScrollView alloc] init];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
        _backgroundScrollView.showsVerticalScrollIndicator = NO;
        _backgroundScrollView.scrollsToTop = NO;
        _backgroundScrollView.canCancelContentTouches = YES;
        [_backgroundScrollView addSubview:_backgroundView];
        [self addSubview:_backgroundScrollView];
        
        _foregroundScrollView = [[UIScrollView alloc] init];
        _foregroundScrollView.backgroundColor = [UIColor clearColor];
        _foregroundScrollView.delaysContentTouches = NO;
        _foregroundScrollView.canCancelContentTouches = YES;
        _foregroundScrollView.delegate = self;
        [_foregroundScrollView addSubview:_foregroundView];
        [self addSubview:_foregroundScrollView];
        
        self.effect = JHScaleEffect | JHBlurEffect | JHScollEffect;
        self.frame = frame;
        if (height <= 0.0) {
            height = kDefaultBackgroundHeight;
        }
        _backgroundHeight = height;
        [self updateBackgroundFrame];
        [self updateForegroundFrame];
        [self updateContentOffset];
        
        // To make expected frame we must set autoresizingMask at last.
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

#pragma mark - Overrides UIView methods

- (void)setAutoresizingMask:(UIViewAutoresizing)autoresizingMask
{
    [super setAutoresizingMask:autoresizingMask];
    _backgroundView.autoresizingMask = autoresizingMask;
    _backgroundScrollView.autoresizingMask = autoresizingMask;
    _foregroundView.autoresizingMask = autoresizingMask;
    _foregroundScrollView.autoresizingMask = autoresizingMask;
    _headerScrollView.autoresizingMask = autoresizingMask;
    _headerView.autoresizingMask= autoresizingMask;
    if (_effect & JHBlurEffect) {
        _visualEffectView.autoresizingMask = autoresizingMask;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint pointInHeaderView = [_headerView convertPoint:point fromView:self];
    if ([_headerView pointInside:pointInHeaderView withEvent:event]) {
        for (UIView *subView in _headerView.subviews) {
            if (CGRectContainsPoint(subView.frame, pointInHeaderView) && [[subView class]isSubclassOfClass:[UIControl class]]) {
                return [_headerView hitTest:pointInHeaderView withEvent:event];
            }
        }
    }
    return [super hitTest:point withEvent:event];
}


#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateContentOffset];
    if ([_delegate respondsToSelector:_cmd]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Inits frame for views

- (void)updateBackgroundFrame
{
    _backgroundScrollView.frame = self.frame;
    _backgroundScrollView.contentSize = CGSizeMake(CGRectGetWidth(_backgroundScrollView.frame),
                                                   CGRectGetHeight(_backgroundScrollView.frame) + _backgroundHeight);;
    if (_effect & JHBlurEffect) {
        CGRect rect = _backgroundView.frame;
        rect.size.height = CGRectGetHeight(rect);
        _visualEffectView.frame = rect;
    }
}

- (void)updateForegroundFrame
{
    _foregroundScrollView.frame = self.frame;
    _foregroundScrollView.contentSize =
    CGSizeMake(CGRectGetWidth(_foregroundView.frame),
               CGRectGetHeight(_foregroundView.frame) + _backgroundHeight);
    _foregroundView.frame = CGRectMake(0.0f,
                                       _backgroundHeight,
                                       CGRectGetWidth(_foregroundView.frame),
                                       CGRectGetHeight(_foregroundView.frame));
}

- (void)updateHeaderFrame
{
    _headerScrollView.frame = self.bounds;
    _headerScrollView.contentSize = self.bounds.size;
    _headerScrollView.contentOffset	= CGPointZero;
    _headerView.frame = CGRectMake(0.0f,
                                   (_backgroundHeight - CGRectGetHeight(_headerView.frame)) / 2.0,
                                   CGRectGetWidth(_headerView.frame),
                                   CGRectGetHeight(_headerView.frame));
}

#pragma mark - Updates contentOffset for scrollViews

- (void)updateContentOffset
{
    CGFloat offsetY = _foregroundScrollView.contentOffset.y;
    CGFloat threshold = _backgroundHeight;
    BOOL isForegroundScrollViewPullDown = (offsetY - 0.0f <= 0);
    if (isForegroundScrollViewPullDown) {
        if (ABS(offsetY) <= ABS(threshold)) {
            // Applies parallax effects
            if (_effect & JHScollEffect) {
                self.backgroundScrollView.contentOffset = CGPointMake(0.0f, floorf(offsetY/2));
                self.headerScrollView.contentOffset = CGPointMake(0.0f, floorf(offsetY/2));
                if (ABS(offsetY) > ABS(threshold) / 4.0) {
                    [_delegate parallaxViewDidScrollToCenter:self];
                } else {
                    [_delegate parallaxViewDidScrollToOrigianl:self];
                }
            }
            if (_effect & JHScaleEffect) {
                CGRect rect = _backgroundView.bounds;
                CGFloat scale = 1 + ABS(offsetY) * 0.005;
                rect.size.width = scale * CGRectGetWidth(_backgroundScrollView.frame);
                rect.size.height = scale * CGRectGetHeight(_backgroundScrollView.frame);
                _backgroundView.bounds = rect;
                if (_visualEffectView) {
                    _visualEffectView.frame = rect;
                }
            }
            if (_effect & JHBlurEffect) {
                CGRect rect = _backgroundView.bounds;
                rect.size.height = CGRectGetHeight(rect);
                _visualEffectView.bounds = rect;
                CGFloat initialAlpha = 1.0;
                CGFloat pullDownPercentage = ABS(offsetY) * (initialAlpha / threshold);
                CGFloat alpha = initialAlpha - 3 * pullDownPercentage;
                _visualEffectView.alpha = alpha;
                _headerView.alpha = alpha;
            }
        }
        else {
            self.backgroundScrollView.contentOffset = CGPointMake(0.0f, offsetY + floorf(threshold/2));
        }
    }
    else {
        if (offsetY >= kDefaultBackgroundHeight) {
            [_delegate foregroundScrollViewDidScrollToBottom:self];
        }
        else {
            [_delegate foregroundScrollViewDidScrollToAboveBottom:self];
        }
        self.backgroundScrollView.contentOffset = CGPointMake(0.0f, offsetY / 3.0);
    }
}

#pragma mark - Properties

- (void)setEffect:(JHParallaxEffect)parallaxEffect
{
    _effect = parallaxEffect;
    if ((_effect & JHBlurEffect)) {
        NSAssert(_backgroundView, @"_backgroundView must exist.");
        if (_visualEffectView == nil) {
            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            
            _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            [_backgroundView addSubview:_visualEffectView];
        }
    }
    else {
        if (_visualEffectView) {
            [_visualEffectView removeFromSuperview];
            _visualEffectView = nil;
        }
    }
}

- (void)setHeaderView:(UIView *)headerView
{
    if (headerView == nil) {
        return;
    }
    _headerView = headerView;
    _headerScrollView = [[UIScrollView alloc] init];
    _headerScrollView.showsHorizontalScrollIndicator = NO;
    _headerScrollView.showsVerticalScrollIndicator = NO;
    _headerScrollView.scrollsToTop = NO;
    _headerScrollView.canCancelContentTouches = YES;
    _headerScrollView.backgroundColor = [UIColor clearColor];
    [_headerScrollView addSubview:_headerView];
    [self insertSubview:_headerScrollView aboveSubview:_backgroundScrollView];
    [self updateHeaderFrame];
}

@end
