/*
 ViewController.m
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
#import "ViewController.h"
#import "JHParallaxView.h"
#import "UIImageView+Mask.h"
#import "JHUtility.h"

static CGFloat const kFingerHeight = 44.0;
static NSString * const kCellIdentifier = @"kCellIdentifier";

@interface JHForegroundView : UIView

@end

@implementation JHForegroundView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect whiteRect = CGRectMake(0.0f, kFingerHeight / 2.0f, CGRectGetWidth(rect), CGRectGetHeight(rect));
    [[UIColor whiteColor] setFill];
    UIRectFill(whiteRect);
}

@end

@interface ViewController ()<UIScrollViewDelegate, JHParallaxViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *playerInfos;
@property (nonatomic, assign) BOOL isDiscoverButtonClicked;
@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *backgroundView = [self _createBackgroundView];
    UIView *headerView = [self _createHeaderView];
    UIView *foregroundView = [self _createForegroundView];
    
    self.playerInfos = @[@"Kobe Bryant", @"Derick Rose", @"Jeremy Lin", @"Stephen Curry"];
    
    JHParallaxView *parallaxView = [[JHParallaxView alloc] initWithBackgroundView:backgroundView foregroundView:foregroundView];
    parallaxView.headerView = headerView;
    parallaxView.scrollViewDelegate = self;
    parallaxView.effect = JHScollEffect | JHScaleEffect | JHBlurEffect;
    parallaxView.delegate = self;
    [self.view addSubview:parallaxView];
}

#pragma mark - Creates views

- (UIView *)_createHeaderView
{
    CGFloat headerSquareLength = 128.0;
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf((CGRectGetWidth(self.view.bounds) - headerSquareLength) / 2.0), 0.0, headerSquareLength, headerSquareLength)];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"jordanHeader"];
    headerImageView.image = backgroundImage;
    [headerImageView applyRoundedMask];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;

    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerImageView];
    
    CGFloat lastY = CGRectGetMaxY(headerImageView.frame);
    lastY += 5.0;
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = JHSTR(@"Jordan");
    nameLabel.textColor = [UIColor whiteColor];
    [nameLabel sizeToFit];
    CGRect rect = nameLabel.frame;
    rect.origin.x = floorf((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(nameLabel.frame))/2.0);
    rect.origin.y = lastY;
    nameLabel.frame = rect;
    [headerView addSubview:nameLabel];
    
    lastY = CGRectGetMaxY(nameLabel.frame);
    lastY += 5.0;
    
    UIButton *discoverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [discoverButton setTitle:JHSTR(@"Discover") forState:UIControlStateNormal];
    discoverButton.titleLabel.font = [UIFont systemFontOfSize:8.0];
    [discoverButton sizeToFit];
    rect = discoverButton.frame;
    rect.origin.x = floorf((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(discoverButton.frame))/2.0);
    rect.origin.y = lastY;
    rect.size.width += 10.0;
    discoverButton.frame = rect;
    [discoverButton addTarget:self action:@selector(_didSelectDiscover:) forControlEvents:UIControlEventTouchUpInside];
    discoverButton.layer.borderWidth = 1.0;
    discoverButton.layer.borderColor = [UIColor whiteColor].CGColor;
    discoverButton.layer.cornerRadius = 12.0;
    discoverButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0);
    [headerView addSubview:discoverButton];
    
    CGRect headerViewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), lastY);
    headerView.frame = headerViewRect;
    return headerView;
}

- (UIView *)_createForegroundView
{
    JHForegroundView *foregroundView = [[JHForegroundView alloc] init];
    foregroundView.backgroundColor = [UIColor clearColor];
    CGFloat lastY = 0.0f;
    UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shuffleButton setTitle:JHSTR(@"Shffle") forState:UIControlStateNormal];
    shuffleButton.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [shuffleButton sizeToFit];
    CGRect rect = shuffleButton.frame;
    rect.size.height = kFingerHeight;
    rect.size.width = CGRectGetWidth(self.view.bounds) * 0.8;
    rect.origin.x = floorf((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(rect))/2.0);
    shuffleButton.frame = rect;
    [shuffleButton addTarget:self action:@selector(_didSelectShfflePlay:) forControlEvents:UIControlEventTouchUpInside];
    shuffleButton.layer.borderWidth = 1.0;
    shuffleButton.layer.borderColor = [UIColor clearColor].CGColor;
    shuffleButton.layer.cornerRadius = 12.0;
    shuffleButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0);
    shuffleButton.backgroundColor = [UIColor orangeColor];
    
    lastY += CGRectGetMaxY(shuffleButton.frame);
    [foregroundView addSubview:shuffleButton];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    rect = tableView.frame;
    rect.origin.y = lastY;
    tableView.frame = rect;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];

    [foregroundView addSubview:tableView];
    
    return foregroundView;
}

- (UIView *)_createBackgroundView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"jordanBackground"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImageView.image = backgroundImage;
    return backgroundImageView;
}

#pragma mark - Actions

- (void)_didSelectDiscover:(UIButton *)button
{
    button.layer.borderColor = _isDiscoverButtonClicked ? [UIColor whiteColor].CGColor : [UIColor greenColor].CGColor;
    self.isDiscoverButtonClicked = !_isDiscoverButtonClicked;
}

- (void)_didSelectShfflePlay:(UIButton *)button
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_playerInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _playerInfos[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - JHParallaxViewDelegate

- (void)parallaxViewDidScrollToCenter:(JHParallaxView *)inView
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)parallaxViewDidScrollToOrigianl:(JHParallaxView *)inView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}
@end
