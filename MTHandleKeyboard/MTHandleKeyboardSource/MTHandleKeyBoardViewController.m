//
//  MTHandleKeyBoardViewController.m
//  MTHandleKeyboard
//
//  Created by Jayaprakash Kaliappan on 11/5/12.
//  Copyright (c) 2012 Mallow Technologies Private Limited. All rights reserved.
//

#import "MTHandleKeyBoardViewController.h"

#define kIsiOS7Later (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
#define kViewDeltaY 64
#define kResignKeyboardNotification @"ResignKeyboardNotification"


@implementation MTHandleKeyBoardViewController

@synthesize keyBoardHeight = _keyboardHeight;
@synthesize currentField = _currentField;
@synthesize accessoryToolBar = _accessoryToolBar;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;
@synthesize flexibleSpaceButton = _fixedSpaceButton;
@synthesize doneButton = _doneButton;

@synthesize fieldCollection = _fieldCollection;
@synthesize keyboardScrollView = _keyboardScrollView;
@synthesize contentView = _contentView;

@synthesize tableView = _tableView;
@synthesize selectedIndexPath = _selectedIndexPath;


#pragma mark - Custom accessor methods

- (void)setCurrentField:(UIView *)currentField {
    _currentField = currentField;
    if(self.fieldCollection.count <= 1) {
        self.previousButton.enabled = NO;
        self.nextButton.enabled = NO;
    } else {
        if(currentField == [self.fieldCollection objectAtIndex:0]) {
            self.previousButton.enabled = NO;
            self.nextButton.enabled = YES;
        } else if (self.currentField == [self.fieldCollection lastObject]) {
            self.nextButton.enabled = NO;
            self.previousButton.enabled = YES;
        } else {
            self.nextButton.enabled = YES;
            self.previousButton.enabled = YES;
        }
    }
    if(self.tableView) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[(UIView *)[currentField superview] superview]];
        self.selectedIndexPath = indexPath;
    }
    [self scrollCurrentFieldToVisible];
}


#pragma mark - Custom methods

- (void)createToolBar {
    //Toolbar customize
    self.accessoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.accessoryToolBar.barStyle = UIBarStyleBlack;
    self.accessoryToolBar.translucent = YES;
    
    self.previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(toolBarPreviousButtonPressed)];
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(toolBarNextButtonPressed)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolBarDoneButtonPressed)];
    
    NSArray *toolBarItems = [[NSArray alloc]initWithObjects:self.previousButton, self.nextButton, self.flexibleSpaceButton, self.doneButton, nil];
    [self.accessoryToolBar setItems:toolBarItems];
}

- (void)resignKeyboard {
    if (self.currentField) {
        [self.currentField resignFirstResponder];
    }
}

- (BOOL)canHandleKeyboard {
    return YES;
}


#pragma mark - Gesture recognizition related methods

- (void)handleTap {
    if (self.currentField) {
        [self.currentField resignFirstResponder];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    id view = (UIView *)[touch view];
    
    // To handle a bug in iOS 5, we are accepting only touch other than the following common elements to dismiss the keyboard
    if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UISegmentedControl class]]) {
        return NO;
    }
    
    return (self.currentField != nil && [self.currentField isFirstResponder]);
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createToolBar];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // Setting up the tool bar for keyboard.
    for (UIView *field in self.fieldCollection) {
        if ([field isKindOfClass:[UITextField class]]) {
            ((UITextField *)field).delegate = self;
            ((UITextField *)field).inputAccessoryView = self.accessoryToolBar;
        }
        
        if ([field isKindOfClass:[UITextView class]]) {
            ((UITextView *)field).delegate = self;
            ((UITextView *)field).inputAccessoryView = self.accessoryToolBar;
        }

        if ([field isKindOfClass:[UISearchBar class]]) {
            ((UISearchBar *)field).delegate = self;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyboard) name:kResignKeyboardNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (kIsiOS7Later) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if ([self canHandleKeyboard]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.currentField resignFirstResponder];
    
    if ([self canHandleKeyboard]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.keyboardScrollView setContentSize:self.keyboardScrollView.frame.size];
}

- (void)viewDidUnLoad {
    self.accessoryToolBar = nil;
    self.previousButton = nil;
    self.nextButton = nil;
    self.flexibleSpaceButton = nil;
    self.doneButton = nil;
    self.fieldCollection = nil;
    self.keyboardScrollView = nil;
    self.contentView = nil;
    self.currentField = nil;
}


#pragma - mark Keyboard Handling Methods

- (CGRect)getRectToVisible {
    CGRect rect;
    if ([self.currentField isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.currentField;
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        caretRect = [self.keyboardScrollView convertRect:caretRect toView:self.contentView];
        caretRect.origin.y = MIN(self.navigationController.view.frame.size.height - (self.keyBoardHeight - kViewDeltaY), caretRect.origin.y);
        
        rect = caretRect;
    } else {
        rect = [self.keyboardScrollView convertRect:self.currentField.frame toView:self.contentView];
    }
    return rect;
}

- (UITableViewCell *)getCurrentFieldCell {
    UIView *superView = self.currentField.superview;
    
    while (![superView isKindOfClass:[UITableViewCell class]]) {
        superView = superView.superview;
    }
    return (UITableViewCell *)superView;
}

- (void)scrollCurrentFieldToVisible {
    if (![self canHandleKeyboard]) {
        return;
    }
    if (self.currentField) {
        if(self.keyboardScrollView) {
            CGRect currentTextFieldFrame = [self getRectToVisible];            
            [self.keyboardScrollView scrollRectToVisible:currentTextFieldFrame animated:YES];
        }
        if (self.tableView) {
            NSIndexPath *scrollIndexPath = self.selectedIndexPath;
            if (!scrollIndexPath && ([self.currentField isKindOfClass:[UITextField class]] || [self.currentField isKindOfClass:[UITextView class]])) {
                UITableViewCell *cell = [self getCurrentFieldCell];
                scrollIndexPath = [self.tableView indexPathForCell:cell];
            }
            [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else {
        // Somehow negative offset is getting set for the scrollview. So make sure we dont go below 0. Ref: http://stackoverflow.com/questions/11293263/textfield-autocorrection-issue
        if (self.keyboardScrollView) {
            CGPoint newOffset = CGPointMake(MAX(self.keyboardScrollView.contentOffset.x, 0), MAX(self.keyboardScrollView.contentOffset.y, 0));
            [self.keyboardScrollView setContentOffset:newOffset animated:YES];
        }
        if (self.tableView) {
            CGPoint newOffset = CGPointMake(MAX(self.tableView.contentOffset.x, 0), MAX(self.tableView.contentOffset.y, 0));
            [self.tableView setContentOffset:newOffset animated:YES];
        }
    }
}

- (void)refreshViewFrames:(NSTimeInterval)animationDuration {
    UIEdgeInsets newInset = UIEdgeInsetsMake(0, 0, self.keyBoardHeight, 0);
    
    /* Call for animation movement */
    [UIView animateWithDuration:animationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.keyboardScrollView) {
            self.keyboardScrollView.contentInset = newInset;
            self.keyboardScrollView.scrollIndicatorInsets = newInset;
        }
        if (self.tableView) {
            self.tableView.contentInset = newInset;
            self.tableView.scrollIndicatorInsets = newInset;
        }
        [self scrollCurrentFieldToVisible];
    } completion:nil];
}

/* Called when the UIKeyboardDidShowNotification is sent. */
- (void)keyboardWillBeShown:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.keyBoardHeight = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) - (self.tabBarController ? 49 : 0);
    } else {
        self.keyBoardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height - (self.tabBarController ? 49 : 0);
    }

    /* Get keyboard animation duration for animate chatViewEditor */
    NSTimeInterval keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self refreshViewFrames:keyboardAnimationDuration];
}

/* Called when the UIKeyboardWillHideNotification is sent */
- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    self.keyBoardHeight = 0;
    
    /* Get keyboard animation duration for animate chatViewEditor */
    NSTimeInterval keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self refreshViewFrames:keyboardAnimationDuration];
}


#pragma mark - UITextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.currentField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.currentField = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (kIsiOS7Later) {
        [self scrollCurrentFieldToVisible];

        // In iOS 7, when enter new line the text view won't scroll until new character entered. Refer: http://stackoverflow.com/questions/18070537/how-to-make-a-textview-scroll-while-editing
        if([textView.text hasSuffix:@"\n"] && textView.contentSize.height > textView.frame.size.height) {
            double delayInSeconds = 0.01;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                CGPoint bottomOffset = CGPointMake(0, textView.contentSize.height - textView.frame.size.height);
                [textView setContentOffset:bottomOffset animated:YES];
            });
        }
    }
}

#pragma mark - UITextField Delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentField = nil;
}


#pragma mark - UISearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.currentField = searchBar;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.currentField = nil;
}


#pragma mark - ToolBar button action methods

- (void)toolBarPreviousButtonPressed {
    NSUInteger currentFieldIndex = [self.fieldCollection indexOfObject:self.currentField];
    [[self.fieldCollection objectAtIndex:(currentFieldIndex - 1)] becomeFirstResponder];
}

- (void)toolBarNextButtonPressed {
    NSUInteger currentFieldIndex = [self.fieldCollection indexOfObject:self.currentField];
    [[self.fieldCollection objectAtIndex:(currentFieldIndex + 1)] becomeFirstResponder];
}

- (void)toolBarDoneButtonPressed {
    [self.currentField resignFirstResponder];
}

@end
