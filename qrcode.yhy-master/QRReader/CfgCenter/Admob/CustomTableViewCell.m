#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 移除旧的分隔线视图
    [self.customSeparatorView removeFromSuperview];
    int x1=0;
    int x2=0;
    int x3=self.customSeparatorHeight;
    // 创建新的分隔线视图
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
         x1=140;
         x2=280;
         x3=2;
    }
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0+x1, self.bounds.size.height - self.customSeparatorHeight, self.bounds.size.width-x2,x3)];
    separatorView.backgroundColor = [UIColor lightGrayColor]; // 设置分隔线颜色
    [self addSubview:separatorView];
    
    // 保存新的分隔线视图
    self.customSeparatorView = separatorView;
}

@end
