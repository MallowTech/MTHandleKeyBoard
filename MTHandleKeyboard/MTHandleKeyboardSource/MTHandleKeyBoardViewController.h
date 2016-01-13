//
//  MTHandleKeyBoardViewController.h
//  MTHandleKeyboard
//
//  Created by Jayaprakash Kaliappan on 11/5/12.
//  Copyright (c) 2012 Mallow Technologies Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTHandleKeyBoardViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    CGFloat _keyboardHeight;
    
    UIView *_currentField;
    UIToolbar *_accessoryToolBar;
    UIBarButtonItem *_previousButton;
    UIBarButtonItem *_nextButton;
    UIBarButtonItem *_fixedSpaceButton;
    UIBarButtonItem *_doneButton;
    
    NSIndexPath *_selectedIndexPath;
}

@property (nonatomic) CGFloat keyBoardHeight;

@property (nonatomic, strong) UIView *currentField;
@property (nonatomic, strong) UIToolbar *accessoryToolBar;
@property (nonatomic, strong) UIBarButtonItem *previousButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpaceButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) IBOutlet UIScrollView *keyboardScrollView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *fieldCollection;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

- (void)toolBarNextButtonPressed;
- (void)scrollCurrentFieldToVisible;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)textViewDidChange:(UITextView *)textView;
- (void)resignKeyboard;
- (void)refreshViewFrames:(NSTimeInterval)animationDuration;

@end
