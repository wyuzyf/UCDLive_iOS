//
//  FilterPopoverViewCell.m
//  Popover
//
//  Created by Sidney on 03/05/17.
//  Copyright © 2017年 lifution. All rights reserved.
//

#import "FilterPopoverViewCell.h"

// extern
float const FilterPopoverViewCellHorizontalMargin = 15.f; ///< 水平边距
float const FilterPopoverViewCellVerticalMargin = 3.f; ///< 垂直边距
float const FilterPopoverViewCellTitleLeftEdge = 8.f; ///< 标题左边边距

@interface FilterPopoverViewCell ()

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UISlider *slider;
@property (nonatomic, weak) UIView *bottomLine;
@property (strong, nonatomic) PopoverAction *action;

@end

@implementation FilterPopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // initialize
    [self initialize];
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = _style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] : [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.00];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - Setter
- (void)setStyle:(PopoverViewStyle)style {
    _style = style;
    _bottomLine.backgroundColor = [self.class bottomLineColorForStyle:style];
    if (_style == PopoverViewStyleDefault) {
        [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    } else {
        [_button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
}

#pragma mark - Private
// 初始化
- (void)initialize {
    // UI
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.userInteractionEnabled = NO; // has no use for UserInteraction.
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.titleLabel.font = [self.class titleFont];
    _button.backgroundColor = self.contentView.backgroundColor;
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_button];
    
    _slider = [[UISlider alloc]init];
    _slider.minimumValue = 0;
    _slider.maximumValue = 100;
    _slider.value = 50;
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    [_slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_slider];
    
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_button]-margin-[_slider]-margin-|" options:kNilOptions metrics:@{@"margin" : @(FilterPopoverViewCellHorizontalMargin)} views:NSDictionaryOfVariableBindings(_button, _slider)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_button]-margin-|" options:kNilOptions metrics:@{@"margin" : @(FilterPopoverViewCellVerticalMargin)} views:NSDictionaryOfVariableBindings(_button)]];
//    [self.contentView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.button
//                                                            attribute:NSLayoutAttributeLeft
//                                                            relatedBy:NSLayoutRelationEqual
//                                                               toItem:self.button
//                                                            attribute:NSLayoutAttributeHeight
//                                                           multiplier:1.0
//                                                             constant:0.0]]];
    [self.contentView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.button
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.slider
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0.0]]];
    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_button]-margin-[_slider]" options:kNilOptions metrics:@{@"margin" : @(FilterPopoverViewCellHorizontalMargin)} views:NSDictionaryOfVariableBindings(_button, _slider)]];
    
    // 底部线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLine]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(bottomLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLine(lineHeight)]|" options:kNilOptions metrics:@{@"lineHeight" : @(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(bottomLine)]];
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:15.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(PopoverViewStyle)style {
    return style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00] : [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
}

- (void)setAction:(PopoverAction *)action {
    [_button setImage:action.image forState:UIControlStateNormal];
    [_button setTitle:action.title forState:UIControlStateNormal];
    _button.titleEdgeInsets = action.image ? UIEdgeInsetsMake(0, FilterPopoverViewCellTitleLeftEdge, 0, -FilterPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    
    _slider.value = action.sliderValue?action.sliderValue:0;
    _action = action;
}

- (void)showBottomLine:(BOOL)show {
    _bottomLine.hidden = !show;
}

- (void)sliderChanged:(UISlider *)slider
{
    if (self.action) {
        self.action.sliderValue = slider.value;
        if (self.action.handler) {
            self.action.handler(self.action);
        }

    }

//    if (_delegate && [_delegate respondsToSelector:@selector(filterPopoverViewCell:slider:)]) {
//        [_delegate filterPopoverViewCell:self.action slider:slider];
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end