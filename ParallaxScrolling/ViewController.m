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
#import "UIImageView+Mask.h"
#import "JHUtility.h"
#import "UIImage+ImageEffects.h"

static CGFloat const kFingerHeight = 44.0;
static NSString * const kCellIdentifier = @"kCellIdentifier";
static CGFloat const kHeaderHeight = 300.0;

@interface JHShuffleButtonView : UIView

@end

@implementation JHShuffleButtonView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect whiteRect = CGRectMake(0.0f, kFingerHeight / 2.0f, CGRectGetWidth(rect), CGRectGetHeight(rect));
    [[UIColor whiteColor] setFill];
    UIRectFill(whiteRect);
}

@end

@interface ViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *playerInfos;
@property (nonatomic, assign) BOOL isDiscoverButtonClicked;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *shuffleButtonView;
@property (nonatomic, strong) UIView *headerForegroundView;
@property (nonatomic, strong) UIView *headerBackgroundView;
@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
	UITableView *tableView = [[UITableView alloc] init];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.frame = self.view.bounds;
	tableView.delegate = self;
	tableView.dataSource = self;
	[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
	self.tableView = tableView;
	self.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
	[self.view addSubview:self.tableView];

    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.headerBackgroundView = [self _createHeaderBackgroundView];
    [backgroundView addSubview:self.headerBackgroundView];
    
    self.headerForegroundView = [self _createHeaderForegroundView];
	[backgroundView addSubview:self.headerForegroundView];
    
	self.tableView.backgroundView = backgroundView;
    self.shuffleButtonView = [self _createShuffleButtonView];
	self.shuffleButtonView.frame = CGRectMake(0, -kFingerHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kFingerHeight);
	[self.tableView addSubview:self.shuffleButtonView];
    
    self.playerInfos = @[@"Kobe Bryant", @"Derick Rose", @"Jeremy Lin", @"Stephen Curry", @"Kevin Love", @"Kyrie Irving", @"LeBron James", @"Rudy Gay",@"Kobe Bryant", @"Derick Rose", @"Jeremy Lin", @"Stephen Curry", @"Kevin Love", @"Kyrie Irving", @"LeBron James", @"Rudy Gay"];

}

#pragma mark - Creates views

- (UIView *)_createHeaderForegroundView
{
    CGFloat headerSquareLength = 128.0;
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf((CGRectGetWidth(self.view.bounds) - headerSquareLength) / 2.0), 30.0, headerSquareLength, headerSquareLength)];
    
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
    
    lastY += CGRectGetHeight(discoverButton.frame);
    CGRect headerViewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), lastY);
    headerView.frame = headerViewRect;
    return headerView;
}

- (UIView *)_createShuffleButtonView
{
    JHShuffleButtonView *shuffleButtonView = [[JHShuffleButtonView alloc] init];
    shuffleButtonView.backgroundColor = [UIColor clearColor];
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
    [shuffleButtonView addSubview:shuffleButton];
    
    return shuffleButtonView;
}

- (UIView *)_createHeaderBackgroundView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"jordanBackground"];
    backgroundImage = [backgroundImage applyBlurWithRadius:1.0f tintColor:[UIColor colorWithWhite:0.12 alpha:0.72] saturationDeltaFactor:1.3f maskImage:nil];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), kHeaderHeight * 1.5f)];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset = scrollView.contentOffset;
    CGFloat scrollViewTopOffsetY = -kFingerHeight;
    BOOL isScrolledAboveTop = (offset.y > scrollViewTopOffsetY);
    self.shuffleButtonView.backgroundColor = isScrolledAboveTop ? [UIColor blackColor] : [UIColor clearColor];
    CGFloat y =  isScrolledAboveTop ? -kFingerHeight + (offset.y - scrollViewTopOffsetY) : -kFingerHeight;
    CGRect rect = self.shuffleButtonView.frame;
    rect.origin.y = y;
    self.shuffleButtonView.frame = rect;
    
	if (-offset.y >= kHeaderHeight) {
        CGFloat headerForegroundViewLastY = offset.y + kHeaderHeight;
		CGRect headerForegroundViewRect = self.headerForegroundView.frame;
		headerForegroundViewRect.origin.y = floor(-headerForegroundViewLastY / 3.0f);
		self.headerForegroundView.frame = headerForegroundViewRect;
	}
    else {
        CGFloat headerBackgroundViewLastY = offset.y + kHeaderHeight;
        CGRect headerBackgroundViewRect = self.headerBackgroundView.frame;
        headerBackgroundViewRect.origin.y = floor(-headerBackgroundViewLastY / 3.0f);
        self.headerBackgroundView.frame = headerBackgroundViewRect;
    }
}
@end
