#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

static NSString *const kSHLaunchAdManagerClassName = @"_TtC10SHAdModule17SHLaunchAdManager";
static NSString *const kSHStartUpAdViewClassName = @"_TtC10SHAdModule15SHStartUpAdView";
static NSString *const kSHHomeFeedOutFrameAdClassName = @"_TtC12SHHomeModule20SHHomeFeedOutFrameAd";

static BOOL SHRespondsToSelector(id object, SEL selector) {
    return object && selector && [object respondsToSelector:selector];
}

static void SHSetBoolIfPossible(id object, SEL selector, BOOL value) {
    if (!SHRespondsToSelector(object, selector)) {
        return;
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(object, selector, value);
}

static void SHHideLaunchAdManager(id manager) {
    if (!manager) {
        return;
    }

    SHSetBoolIfPossible(manager, @selector(setColdAdEnd:), YES);
    SHSetBoolIfPossible(manager, @selector(setSkipAd:), YES);
    SHSetBoolIfPossible(manager, @selector(setIsPlaying:), NO);
    SHSetBoolIfPossible(manager, @selector(setIsExcuteAd:), NO);

    SEL hideSelector = @selector(hiddenLaunchAdWithNoti:showAnimation:);
    if (SHRespondsToSelector(manager, hideSelector)) {
        ((void (*)(id, SEL, BOOL, BOOL))objc_msgSend)(manager, hideSelector, NO, NO);
    }

    SEL launchAdViewSelector = @selector(launchAdView);
    if (SHRespondsToSelector(manager, launchAdViewSelector)) {
        UIView *launchAdView = ((UIView *(*)(id, SEL))objc_msgSend)(manager, launchAdViewSelector);
        launchAdView.hidden = YES;
        launchAdView.userInteractionEnabled = NO;
        [launchAdView removeFromSuperview];
    }

    SEL containerViewSelector = @selector(containerView);
    if (SHRespondsToSelector(manager, containerViewSelector)) {
        UIView *containerView = ((UIView *(*)(id, SEL))objc_msgSend)(manager, containerViewSelector);
        containerView.hidden = YES;
        containerView.userInteractionEnabled = NO;
        [containerView removeFromSuperview];
    }

    SEL iPadContainerViewSelector = @selector(iPadContainerView);
    if (SHRespondsToSelector(manager, iPadContainerViewSelector)) {
        UIView *iPadContainerView = ((UIView *(*)(id, SEL))objc_msgSend)(manager, iPadContainerViewSelector);
        iPadContainerView.hidden = YES;
        iPadContainerView.userInteractionEnabled = NO;
        [iPadContainerView removeFromSuperview];
    }
}

static void SHHideLaunchAdView(UIView *view) {
    if (!view) {
        return;
    }

    view.hidden = YES;
    view.alpha = 0.0;
    view.userInteractionEnabled = NO;
    [view removeFromSuperview];
}

%hook _TtC10SHAdModule17SHLaunchAdManager

- (id)init {
    id result = %orig;
    SHHideLaunchAdManager(result);
    return result;
}

+ (id)shared {
    id result = %orig;
    SHHideLaunchAdManager(result);
    return result;
}

- (void)startShowScreen {
    SHHideLaunchAdManager(self);
}

- (void)startLoadAdData {
    SHHideLaunchAdManager(self);
}

- (void)applicationWillEnterForeground {
    SHHideLaunchAdManager(self);
}

- (void)addLaunchAdViewToWindow {
    SHHideLaunchAdManager(self);
}

- (void)showLaunchAdsWithShowAd:(id)showAd active:(BOOL)active {
    SHHideLaunchAdManager(self);
}

- (void)showImageViewWithAd:(id)ad active:(BOOL)active video:(BOOL)video {
    SHHideLaunchAdManager(self);
}

- (void)showAdVideoWithAd:(id)ad active:(BOOL)active {
    SHHideLaunchAdManager(self);
}

- (void)initPlayerWithAd:(id)ad active:(BOOL)active {
    SHHideLaunchAdManager(self);
}

%end

%hook _TtC10SHAdModule15SHStartUpAdView

- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    SHHideLaunchAdView(result);
    return result;
}

- (id)initWithCoder:(NSCoder *)coder {
    id result = %orig(coder);
    SHHideLaunchAdView(result);
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

- (void)nextSecond {
}

- (void)didMoveToWindow {
    %orig;
    SHHideLaunchAdView((UIView *)self);
}

- (void)didMoveToSuperview {
    %orig;
    SHHideLaunchAdView((UIView *)self);
}

%end

%hook _TtC12SHHomeModule20SHHomeFeedOutFrameAd

- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if ([result respondsToSelector:@selector(launchAdViewRemove)]) {
        ((void (*)(id, SEL))objc_msgSend)(result, @selector(launchAdViewRemove));
    }
    return result;
}

- (void)didMoveToWindow {
    %orig;
    id object = (id)self;
    if ([object respondsToSelector:@selector(launchAdViewRemove)]) {
        ((void (*)(id, SEL))objc_msgSend)(self, @selector(launchAdViewRemove));
    }
}

- (void)layoutSubviews {
    %orig;
    id object = (id)self;
    if ([object respondsToSelector:@selector(launchAdViewRemove)]) {
        ((void (*)(id, SEL))objc_msgSend)(self, @selector(launchAdViewRemove));
    }
}

%end

%ctor {
    @autoreleasepool {
        NSArray<NSString *> *classNames = @[
            kSHLaunchAdManagerClassName,
            kSHStartUpAdViewClassName,
            kSHHomeFeedOutFrameAdClassName
        ];

        for (NSString *className in classNames) {
            if (!NSClassFromString(className)) {
                NSLog(@"[ShihuoSkipla] class not found at load time: %@", className);
            }
        }
    }
}
