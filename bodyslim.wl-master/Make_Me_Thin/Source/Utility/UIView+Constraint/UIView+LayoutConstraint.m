//
//  UIView+Constraint.m
//  Transsexual
//
//  Created by ZB_Mac on 15/10/14.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import "UIView+LayoutConstraint.h"

@implementation UIView (LayoutConstraint)
-(NSLayoutConstraint *)layoutConstraintForIdentifier:(NSString *)layoutConstraintIdentifier
{
    NSArray *constraints = [self constraints];
    for (NSLayoutConstraint *layoutConstraint in constraints) {
        if ([layoutConstraint.identifier isEqualToString:layoutConstraintIdentifier]) {
            return layoutConstraint;
        }
    }
    return nil;
}
@end
