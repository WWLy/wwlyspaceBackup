---
title: UITextField精准限制输入长度
date: 2016-09-27 22:45
tags: iOS
categories: iOS
---

```
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isHaveDian = YES;
    if ([textField.text rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        unichar single=[string characterAtIndex:0];//当前输入的字符
        if ((single >='0' && single<='9') || single=='.')//数据格式正确
        {
            //首字母不能为0和小数点
            if ([textField.text length]==0) {
                if (single == '.') {
                    // 第一个数字不能为小数点
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
                if (single == '0') {
                    // 亲，第一个数字不能为0
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            if (single=='.')  {
                if(!isHaveDian) // text中还没有小数点
                {
                    isHaveDian=YES;
                    return YES;
                } else {
                    // 已经输入过小数点
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            } else {
                if (isHaveDian) // 存在小数点
                {
                    // 判断小数点的位数
                    NSRange ran=[textField.text rangeOfString:@"."];
                    NSInteger tt = range.location-ran.location;
                    if (tt <= 2){
                        return YES;
                    } else {
                        // 最多输入两位小数
                        return NO;
                    }
                } else {
                    return YES;
                }
            }
        } else {
            // 输入的数据格式不正确
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    } else {
        return YES;
    }
}
```

