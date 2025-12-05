//
//  RoundCornerRuleView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerRuleView.h"
#import "Masonry.h"

@implementation RoundCornerRuleView
- (void)awakeFromNib {
  [super awakeFromNib];

  _textV = [[UITextView alloc] initWithFrame:self.bounds];
  [self.contentView addSubview:_textV];
  _textV.font = [UIFont systemFontOfSize:IS_IPAD?18:14];
  _textV.editable = NO;
  _textV.backgroundColor = [UIColor clearColor];
  _textV.selectable = NO;
  [_textV mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  self.textV.textColor = [UIColor whiteColor];
  self.titleLabel.text = LocalizedGameStr(rules);
  [self.closeButton setTitle:LocalizedGameStr2(dialog_close) forState:(UIControlStateNormal)];
  [self.textV addObserver:self forKeyPath:@"center" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
  self.textV.text = LocalizedGameStr(game_rules_freecell);
}

- (void)dealloc {
  [self.textV removeObserver:self forKeyPath:@"center"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"center"] && (object == self.textV)) {
    [self.textV setContentOffset:CGPointZero animated:NO];
  }
}


- (void)prepareForPortrait:(NSNumber *)boolObject {
  BOOL isp = [boolObject boolValue];

  self.closeButtonCenterX.constant = isp?0:(CGRectGetWidth(self.bounds)/2 - (CGRectGetWidth(self.closeButton.bounds)/2+ 8+8));

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
