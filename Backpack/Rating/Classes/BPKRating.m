/*
 * Backpack - Skyscanner's Design System
 *
 * Copyright 2018-2019 Skyscanner Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "BPKRating.h"

#import <Backpack/Color.h>
#import <Backpack/Common.h>
#import <Backpack/Font.h>
#import <Backpack/Label.h>
#import <Backpack/Spacing.h>

#import "BPKRatingBubble.h"
#import "BPKRatingTextWrapper.h"

NS_ASSUME_NONNULL_BEGIN
@interface BPKRating ()
@property(nonatomic) BPKRatingTextWrapper *textWrapper;
@property(nonatomic) BPKRatingBubble *ratingBubble;
@property(nonatomic) NSLayoutConstraint *textSpacingConstraintHorizontal;
@property(nonatomic) NSLayoutConstraint *textSpacingConstraintVertical;
@property(nonatomic) NSArray<NSLayoutConstraint *> *horizontalLayoutConstraints;
@property(nonatomic) NSArray<NSLayoutConstraint *> *verticalLayoutConstraints;
@end

@implementation BPKRating

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setUp];
    }

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self setUp];
    }

    return self;
}

- (instancetype)initWithRatingValue:(CGFloat)ratingValue
                              title:(NSString *)title
                           subtitle:(NSString *_Nullable)subtitle {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.ratingValue = ratingValue;
        self.title = title;
        self.subtitle = subtitle;

        [self setUp];
    }

    return self;
}

- (void)setUp {
    self.ratingBubble = [BPKRatingBubble new];
    self.ratingBubble.accessibilityElementsHidden = YES;
    self.size = BPKRatingSizeBase;
    [self.ratingBubble setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh
                                                       forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.ratingBubble];

    self.textWrapper = [[BPKRatingTextWrapper alloc] initWithFrame:CGRectZero];
    self.textWrapper.accessibilityElementsHidden = YES;
    [self addSubview:self.textWrapper];

    [self setUpConstraints];
    [self updateConstraints];
    [self updateStyle];
}

#pragma mark - State setters

- (void)setLowRatingColor:(UIColor *)lowRatingColor {
    BPKAssertMainThread();
    if (_lowRatingColor != lowRatingColor) {
        _lowRatingColor = lowRatingColor;

        self.ratingBubble.lowRatingColor = lowRatingColor;
    }
}

- (void)setMediumRatingColor:(UIColor *)mediumRatingColor {
    BPKAssertMainThread();
    if (_mediumRatingColor != mediumRatingColor) {
        _mediumRatingColor = mediumRatingColor;

        self.ratingBubble.mediumRatingColor = mediumRatingColor;
    }
}

- (void)setHighRatingColor:(UIColor *)highRatingColor {
    BPKAssertMainThread();
    if (_highRatingColor != highRatingColor) {
        _highRatingColor = highRatingColor;

        self.ratingBubble.highRatingColor = highRatingColor;
    }
}

- (void)setTitle:(NSString *)title {
    BPKAssertMainThread();
    _title = [title copy];

    self.textWrapper.title = self.title;
}

- (void)setSubtitle:(NSString *_Nullable)subtitle {
    BPKAssertMainThread();
    _subtitle = [subtitle copy];

    self.textWrapper.subtitle = self.subtitle;
}

- (void)setRatingValue:(CGFloat)ratingValue {
    BPKAssertMainThread();
    if (_ratingValue != ratingValue) {
        _ratingValue = ratingValue;

        self.ratingBubble.ratingValue = ratingValue;
    }
}

- (void)setSize:(BPKRatingSize)size {
    BPKAssertMainThread();
    if (_size != size) {
        _size = size;

        self.textSpacingConstraintHorizontal.constant = [self spacingForCurrentSize];
        self.textSpacingConstraintVertical.constant = [self spacingForCurrentSize];

        self.textWrapper.size = size;
        self.ratingBubble.size = size;
    }
}

- (CGFloat)spacingForCurrentSize {
    switch (self.size) {
    case BPKRatingSizeLarge:
    case BPKRatingSizeBase:
    case BPKRatingSizeSmall:
        return BPKSpacingMd;
    case BPKRatingSizeExtraSmall:
        return BPKSpacingSm;
    }
}

- (void)setLayout:(BPKRatingLayout)layout {
    BPKAssertMainThread();
    if (_layout != layout) {
        _layout = layout;

        self.textWrapper.layout = layout;
        [self updateLayout];
    }
}

- (void)updateLayout {
    switch (self.layout) {
    case BPKRatingLayoutHorizontal:
        [NSLayoutConstraint deactivateConstraints:self.verticalLayoutConstraints];
        [NSLayoutConstraint activateConstraints:self.horizontalLayoutConstraints];
        break;
    case BPKRatingLayoutVertical:
        [NSLayoutConstraint deactivateConstraints:self.horizontalLayoutConstraints];
        [NSLayoutConstraint activateConstraints:self.verticalLayoutConstraints];
        break;
    }
}

#pragma mark - Layout

- (void)setUpConstraints {
    self.textWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    self.ratingBubble.translatesAutoresizingMaskIntoConstraints = NO;

    self.textSpacingConstraintHorizontal =
        [self.textWrapper.leadingAnchor constraintEqualToAnchor:self.ratingBubble.trailingAnchor constant:BPKSpacingMd];

    self.textSpacingConstraintVertical =
        [self.textWrapper.topAnchor constraintEqualToAnchor:self.ratingBubble.bottomAnchor constant:BPKSpacingMd];

    self.horizontalLayoutConstraints = @[
        [self.ratingBubble.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        self.textSpacingConstraintHorizontal,
        [self.textWrapper.centerYAnchor constraintEqualToAnchor:self.ratingBubble.centerYAnchor]
    ];

    self.verticalLayoutConstraints = @[
        self.textSpacingConstraintVertical,
        [self.textWrapper.centerXAnchor constraintEqualToAnchor:self.ratingBubble.centerXAnchor],
        [self.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.ratingBubble.trailingAnchor]
    ];

    [NSLayoutConstraint activateConstraints:@[
        [self.ratingBubble.topAnchor constraintEqualToAnchor:self.topAnchor],

        [self.textWrapper.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor],
        [self.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.textWrapper.trailingAnchor],

        [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.textWrapper.bottomAnchor],
        [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.ratingBubble.bottomAnchor]
    ]];

    [self updateLayout];
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    [super systemLayoutSizeFittingSize:targetSize];
    CGSize ratingBubbleSize = [self.ratingBubble systemLayoutSizeFittingSize:targetSize];
    CGSize textWrapperSize = [self.textWrapper systemLayoutSizeFittingSize:targetSize];

    CGFloat desiredHeight = MAX(ratingBubbleSize.height, textWrapperSize.height);
    CGFloat desiredWidth = ratingBubbleSize.width + self.spacingForCurrentSize + textWrapperSize.width;
    if (self.layout == BPKRatingLayoutVertical) {
        desiredHeight = ratingBubbleSize.height + self.spacingForCurrentSize + textWrapperSize.height;
        desiredWidth = MAX(ratingBubbleSize.width, textWrapperSize.width);
    }

    CGFloat height = MIN(desiredHeight, targetSize.height);
    CGFloat width = MIN(desiredWidth, targetSize.width);

    return CGSizeMake(width, height);
}

#pragma mark - Updates

- (void)updateStyle {
    self.ratingBubble.ratingValue = self.ratingValue;
}

@end

NS_ASSUME_NONNULL_END