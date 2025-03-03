//
//  ALHomeViewController.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALHomeViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <SafariServices/SafariServices.h>

@interface ALHomeViewController()
@property (nonatomic, weak) IBOutlet UITableViewCell *mediationDebuggerCell;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *muteToggle;
@end

@implementation ALHomeViewController
static NSString *const kSupportLink = @"https://support.applovin.com/hc/en-us";
static const NSInteger kRowIndexToHideForPhone = 3;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addFooterLabel];
    
    self.muteToggle.image = [self muteIconForCurrentSdkMuteSetting];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if ( [tableView cellForRowAtIndexPath: indexPath] == self.mediationDebuggerCell )
    {
        [[ALSdk shared] showMediationDebugger];
    }
    else if ( indexPath.section == 1 )
    {
        if ( indexPath.row == 0 )
        {
            [self openSupportSite];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && indexPath.section == 0 && indexPath.row == kRowIndexToHideForPhone )
    {
        cell.hidden = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && indexPath.section == 0 && indexPath.row == kRowIndexToHideForPhone )
    {
        return 0;
    }
    return [super tableView: tableView heightForRowAtIndexPath: indexPath];
}

#pragma mark - Sound Toggling

- (IBAction)toggleMute:(UIBarButtonItem *)sender
{
    /**
     * Toggling the sdk mute setting will affect whether your video ads begin in a muted state or not.
     */
    ALSdk *sdk = [ALSdk shared];
    sdk.settings.muted = !sdk.settings.muted;
    sender.image = [self muteIconForCurrentSdkMuteSetting];
}

- (UIImage *)muteIconForCurrentSdkMuteSetting
{
    return [ALSdk shared].settings.muted ? [UIImage imageNamed: @"mute"] : [UIImage imageNamed: @"unmute"];
}

#pragma mark - Table View Actions

- (void)openSupportSite
{
    NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
    if ( version.majorVersion > 8 )
    {
        SFSafariViewController *safariController = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: kSupportLink]
                                                                       entersReaderIfAvailable: YES];
        [self presentViewController: safariController animated: YES completion: nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: kSupportLink]];
    }
}

- (void)addFooterLabel
{
    UILabel *footer = [[UILabel alloc] init];
    footer.font = [UIFont systemFontOfSize: 14.0f];
    footer.numberOfLines = 0;
    
    NSString *sdkVersion = [ALSdk version];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *text = [NSString stringWithFormat: @"SDK Version: %@\niOS Version: %@\n\nLanguage: Objective-C", sdkVersion, systemVersion];
    
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.alignment =  NSTextAlignmentCenter;
    style.minimumLineHeight = 20.0f;
    footer.attributedText = [[NSAttributedString alloc] initWithString: text attributes: @{NSParagraphStyleAttributeName : style}];
    
    CGRect frame = footer.frame;
    frame.size.height = [footer sizeThatFits: CGSizeMake(CGRectGetWidth(footer.frame), CGFLOAT_MAX)].height + 60.0f;
    footer.frame = frame;
    self.tableView.tableFooterView = footer;
}

@end
