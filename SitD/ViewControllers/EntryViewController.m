//
//  EntryViewController.m
//  SitD
//
//  Created by rainwolf on 29/11/15.
//  Copyright © 2015 rainwolf. All rights reserved.
//

#import "EntryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MainTableViewController.h"
#import "SitDSplitViewController.h"
#import "EmptyUIViewController.h"
#import "DetailNavigationController.h"
#import "MasterNavigationController.h"
#import "SitDAccount.h"
//#import "TSMessage.h"

//#import <YapDatabase/YapDatabase.h>
//@import YapDatabase;


//@interface EntryViewController ()
//
//@end


@implementation PWTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

@end


@implementation EntryViewController
@synthesize keyboardHeight;
@synthesize passwordTextField;
@synthesize label;

@synthesize accountKey;
@synthesize accountName;
@synthesize sitdAccount;

@synthesize account;


-(id) init {
    if (self = [super init]) {
        accountName = nil;
        accountKey = nil;
        sitdAccount = nil;

        account = nil;

        keyboardHeight = 0;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (account == nil) {
        account = [[SitDAccount alloc] init];
        [account setCurrentVC: self];
        [[account networkConnection] startTor];
    } else {
        NSLog(@"kitteh");
        [account setCurrentVC: self];
        [account.networkConnection restartTor];
    }

    passwordTextField = [[PWTextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - (self.view.bounds.size.width / 1.61)) / 2, self.view.bounds.size.height - self.view.bounds.size.height/1.61 - 10, self.view.bounds.size.width / 1.61, 40)];
    [self.view addSubview:passwordTextField];
    passwordTextField.backgroundColor = [UIColor clearColor];
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.tintColor = [UIColor whiteColor];
    passwordTextField.layer.cornerRadius=8.0f;
    passwordTextField.layer.masksToBounds=YES;
    passwordTextField.layer.borderColor=[[UIColor whiteColor] CGColor];
    passwordTextField.layer.borderWidth = 1.0f;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.delegate = self;
    passwordTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];

    
    label = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, self.view.bounds.size.width - 30, 50)];
    [label setText: NSLocalizedString(@"*spark*", nil)];
    [label setTextColor:[UIColor whiteColor]];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: label];
//    NSLog(@"kitty");
    // Do any additional setup after loading the view.
    
    NSString *sitdDataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"SitDAccounts"];
    NSError *error;
    BOOL isFolder;
    [[NSFileManager defaultManager] fileExistsAtPath:sitdDataPath isDirectory:&isFolder];
    if (!isFolder) {
        NSLog(@"folder %@ does not exist", sitdDataPath);
        if (![[NSFileManager defaultManager] createDirectoryAtPath:sitdDataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Create directory error: %@", error);
        }
    } else {
//        NSLog(@"folder %@ does exist", sitdDataPath);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowHide:) name:UIKeyboardWillChangeFrameNotification object:nil];

}
-(void) viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)sender {
//    [passwordTextField resignFirstResponder];
    
    
    if (passwordTextField.text && ![passwordTextField.text isEqualToString:@""]) {
        // find database that matches the password or ask to confirm password to create one
//        NSLog(@"kitty %@ kitty", passwordTextField.text);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self checkAccountsAndLoad:passwordTextField.text]) {
                [self toMainViewController: NO];
            } else {
                [self createNewAccount:passwordTextField.text];
            }
        });
        

    }
}

-(void) createNewAccount: (NSString *) password {
    UIAlertController *passwordReEntryController = [UIAlertController
                                                    alertControllerWithTitle:NSLocalizedString(@"No Such Account", nil)
                                                    message:NSLocalizedString(@"repeat the password to create one.", nil)
                                                    preferredStyle:UIAlertControllerStyleAlert];
    [passwordReEntryController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.placeholder = NSLocalizedString(@"Password", nil);
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.passwordTextField setText:@""];
        NSLog(@"Cancel action");
        label.text = @"*spark*";




       }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       UITextField *passwordRepeatField = passwordReEntryController.textFields.firstObject;
       if ([password isEqualToString: passwordRepeatField.text]) {
           // create a new database with that password
           NSLog(@"passwords match");

//           UIAlertController *askStorageController = [UIAlertController
//                                                      alertControllerWithTitle:NSLocalizedString(@"Pick a way to enter the contact's key exchange", nil)
//                                                      message: nil
//                                                      preferredStyle:UIAlertControllerStyleActionSheet];
//           
//           UIAlertAction *tempStorage = [UIAlertAction actionWithTitle:NSLocalizedString(@"Don't allow backups", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//               [self createDbWithPassword: password inTempStorage: YES];
//           }];
//           UIAlertAction *backupStorage = [UIAlertAction actionWithTitle: NSLocalizedString(@"Allow backups", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//               [self createDbWithPassword: password inTempStorage: NO];
//           }];
//           [askStorageController addAction: tempStorage];
//           [askStorageController addAction: backupStorage];
//           
//           [self.view setNeedsLayout];
//           [self presentViewController: askStorageController animated:NO completion:nil];
           [self createDbWithPassword: password inTempStorage: YES];
           
       } else {
           UIAlertController *passwordNoMatchController = [UIAlertController
                                                           alertControllerWithTitle:NSLocalizedString(@"Passwords don't match", nil)
                                                           message:nil preferredStyle:UIAlertControllerStyleAlert];
           UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                      NSLog(@"Cancel action");
                }];
           [passwordNoMatchController addAction:okayAction];
           [passwordNoMatchController.view setNeedsLayout];
           [self presentViewController:passwordNoMatchController animated:NO completion:nil];
           NSLog(@"passwords don't match");
           [self.passwordTextField setText:@""];
           label.text = @"*spark*";
       }
   }];
    okAction.enabled = NO;
    [passwordReEntryController addAction:cancelAction];
    [passwordReEntryController addAction:okAction];
    
    [self.view setNeedsLayout];
    [self presentViewController:passwordReEntryController animated:NO completion:nil];
}

-(BOOL) checkAccountsAndLoad: (NSString *) password {
    NSString *sitdDataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"SitDAccounts"];
    NSArray *sitdFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sitdDataPath error:nil];
    for (int i = 0; i < [sitdFolder count]; i++) {
        NSLog(@"File %d: %@", (i + 1), [sitdFolder objectAtIndex:i]);
        if ([[sitdFolder objectAtIndex:i] length] == 16) {
            if ([self tryLoadingAtPath:[sitdFolder objectAtIndex:i] withPassword:password]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) tryLoadingAtPath: (NSString *) folder withPassword: (NSString *) password {
    NSData *salt = [FGIntXtra hexStringToNSData:folder];
    __block NSData *key = [FGIntXtra scryptPassphrase:password withSalt:salt cost:16384 parallelism:1 blockSize:8 keyLength:32];
    
    account.databaseKey = key;
    YapDatabaseOptions *options = [[YapDatabaseOptions alloc] init];
    options.corruptAction = YapDatabaseCorruptAction_Fail;
    options.cipherKeyBlock = ^ NSData *(void){
        return account.databaseKey;
    };
    NSString *sitdDataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"SitDAccounts"];
    sitdAccount = [[YapDatabase alloc] initWithPath:[sitdDataPath stringByAppendingPathComponent:folder] serializer:nil deserializer:nil options:options];
    if (sitdAccount == nil) {
        accountName = nil;
        account.databaseKey = nil;
        return NO;
    } else {
        accountName = folder;
        return YES;
    }
}


-(void) toMainViewController: (BOOL) generateKeys {
    SitDSplitViewController* splitViewController = [[SitDSplitViewController alloc] init];

    MainTableViewController *masterViewController = [[MainTableViewController alloc] init];
    MasterNavigationController *masterNavigationController = [[MasterNavigationController alloc] initWithRootViewController:masterViewController];
    
    EmptyUIViewController *emptyViewController = [[EmptyUIViewController alloc] init];
    DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:emptyViewController];
    
    [masterViewController setAccount:account];
    [account setDatabase:sitdAccount];
    [account setDatabaseName:accountName];
    YapDatabaseConnection *yapDBConnection = [sitdAccount newConnection];
    [account setDatabaseConnection:yapDBConnection];
    yapDBConnection = [sitdAccount newConnection];
    [account setRoConnection: yapDBConnection];

    if (generateKeys) {
        label.text = NSLocalizedString(@"Generating Ed25519SHA512 keys", nil);
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        Ed25519SHA512 *edKeys = [[Ed25519SHA512 alloc] init];
        [edKeys generateNewSecretAndPublicKey];
        [account setPrivateEd25519Key: edKeys];
        label.text = NSLocalizedString(@"Generating BBSsig group", nil);
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        BBSPrivateKey *bbsKeys = [[BBSPrivateKey alloc] init];
        [bbsKeys generateGroup];
        [account setPrivateBBSKey:bbsKeys];
        label.text = NSLocalizedString(@"Generating identity", nil);
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        NSData *identity = [edKeys secretKeyToCurve25519Key];
        [account setIdentity:identity];
        NSData *publicIdentity = [NaClPacket curve25519BasePointTimes:identity];
        [account setPublicIdentity:publicIdentity];
    }

    sitdAccount = nil;
    yapDBConnection = nil;
    accountName = nil;
    accountKey = nil;


    splitViewController.delegate = masterViewController;
    splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
//    if (!IS_IPHONE_6P) {
////        NSLog(@"not iPhone 6 plus");
//        [splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModePrimaryOverlay];
//    }
//    emptyViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
//    emptyViewController.navigationItem.leftItemsSupplementBackButton = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [account setCurrentVC:splitViewController];
        [[UIApplication sharedApplication].keyWindow setRootViewController:splitViewController];
    });
}


-(void) createDbWithPassword: (NSString *) password inTempStorage: (BOOL) tempStorage {
    NSData *salt = [FGIntXtra randomDataOfLength:8];
    accountName = [FGIntXtra dataToHexString:salt];
    account.databaseKey = [FGIntXtra scryptPassphrase:password withSalt:salt cost:16384 parallelism:1 blockSize:8 keyLength:32];
    YapDatabaseOptions *options = [[YapDatabaseOptions alloc] init];
    options.corruptAction = YapDatabaseCorruptAction_Fail;
    options.cipherKeyBlock = ^ NSData *(void){
        return account.databaseKey;
    };
    NSString *sitdDataPath;
    sitdDataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"SitDAccounts"];
//    if (tempStorage) {
//        <#statements#>
//    } else {
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sitdAccount = [[YapDatabase alloc] initWithPath:[sitdDataPath stringByAppendingPathComponent:accountName] serializer:nil deserializer:nil options:options];
        
        [self toMainViewController: YES];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *pwField = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = pwField.text.length > 0;
    }
}


-(void)keyboardWillShowHide: (NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    if ([[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y == self.view.bounds.size.height) {
        keyboardHeight = 0;
    } else {
        keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    }
    CGRect frameRect = passwordTextField.frame;
    float viewHeight = self.view.bounds.size.height - keyboardHeight;
    frameRect.origin.y = viewHeight - viewHeight/1.61 - 10;
    passwordTextField.frame = frameRect;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
