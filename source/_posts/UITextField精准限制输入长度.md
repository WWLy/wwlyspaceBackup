---
title: UITextField精准限制输入长度
date: 2016-09-27 22:06
tags: iOS
categories: iOS
---

> 首先需要对 `textField` 进行通知监听, 通知为`UITextFieldTextDidChangeNotification`

```
[[NSNotificationCenter defaultCenter] addObserver:self 
selector:@selector(encourageNameFieldDidChange:) 
name:UITextFieldTextDidChangeNotification 
object:textField];
```

> 绑定的方法实现如下

```
- (void)encourageNameFieldDidChange:(NSNotification *)notification {
    NSString *toBeString = self.encourageNameField.text;
    UITextInputMode *currentInputMode = self.encourageNameField.textInputMode;
    if (currentInputMode == nil) {
        if (toBeString.length > 10) {
            self.encourageNameField.text = [toBeString substringToIndex:10];
        }
        return;
    }
    NSString *lang = [currentInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入
        UITextRange *selectedRange = [self.encourageNameField markedTextRange];
        // 获取高亮部分
        UITextPosition *position = [self.encourageNameField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字, 则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 10) {
                self.encourageNameField.text = [toBeString substringToIndex:10];
            }
        }
        // 有高亮选择的字符串, 暂不对文字进行统计和限制
        else {
            
        }
    }
    else {
        if (toBeString.length > 10) {
            self.encourageNameField.text = [toBeString substringToIndex:10];
        }
    }
}
```


