#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

static NSString *CGFPJavaScript(void)
{
    return
    @"(function() {"
    
    "if (window.__CGFPInstalled) return;"
    "window.__CGFPInstalled = true;"

    "function isChatGPT() {"
    " var h = location.hostname || '';"
    " return h === 'chatgpt.com' ||"
    "        h.indexOf('.chatgpt.com') !== -1 ||"
    "        h === 'chat.openai.com' ||"
    "        h.indexOf('.chat.openai.com') !== -1;"
    "}"

    "function findPlusButton() {"
    " return document.querySelector('[data-testid=\"composer-plus-btn\"]') ||"
    "        document.querySelector('button[aria-label=\"Add files and more\"]');"
    "}"

    "function findFileInput() {"
    " return document.querySelector('#upload-files') ||"
    "        document.querySelector('#upload-photos') ||"
    "        document.querySelector('input[type=\"file\"]');"
    "}"

    "function placeInput() {"
    " if (!isChatGPT()) return;"

    " var button = findPlusButton();"
    " var input = findFileInput();"

    " if (!button || !input) return;"

    " var r = button.getBoundingClientRect();"

    " if (r.width <= 0 || r.height <= 0) return;"

    " input.style.setProperty('display', 'block', 'important');"
    " input.style.setProperty('visibility', 'visible', 'important');"
    " input.style.setProperty('position', 'fixed', 'important');"
    " input.style.setProperty('left', r.left + 'px', 'important');"
    " input.style.setProperty('top', r.top + 'px', 'important');"
    " input.style.setProperty('width', r.width + 'px', 'important');"
    " input.style.setProperty('height', r.height + 'px', 'important');"
    " input.style.setProperty('opacity', '0.01', 'important');"
    " input.style.setProperty('z-index', '2147483647', 'important');"
    " input.style.setProperty('margin', '0', 'important');"
    " input.style.setProperty('padding', '0', 'important');"
    " input.style.setProperty('border', '0', 'important');"
    " input.style.setProperty('background', 'transparent', 'important');"
    " input.style.setProperty('cursor', 'pointer', 'important');"
    " input.style.setProperty('pointer-events', 'auto', 'important');"
    " input.style.setProperty('-webkit-appearance', 'none', 'important');"
    "}"

    "function start() {"
    " placeInput();"

    " if (window.__CGFPObserverStarted) return;"
    " window.__CGFPObserverStarted = true;"

    " var observer = new MutationObserver(function() {"
    "   placeInput();"
    " });"

    " if (document.documentElement) {"
    "   observer.observe(document.documentElement, {"
    "     childList: true,"
    "     subtree: true,"
    "     attributes: true,"
    "     attributeFilter: ['class','style','data-testid','aria-label']"
    "   });"
    " }"

    " window.addEventListener('resize', placeInput, true);"
    " window.addEventListener('scroll', placeInput, true);"

    " setInterval(placeInput, 700);"
    "}"

    "if (document.readyState === 'loading') {"
    " document.addEventListener('DOMContentLoaded', start, false);"
    "} else {"
    " start();"
    "}"

    "})();";
}

static void CGFPInjectIntoWebView(id contentView)
{
    Ivar webViewIvar = class_getInstanceVariable(
        object_getClass(contentView),
        "_webView"
    );

    if (!webViewIvar) {
        webViewIvar = class_getInstanceVariable(
            [contentView class],
            "_webView"
        );
    }

    if (!webViewIvar)
        return;

    WKWebView *webView = object_getIvar(contentView, webViewIvar);

    if (!webView)
        return;

    [webView evaluateJavaScript:CGFPJavaScript()
              completionHandler:^(id result, NSError *error) {
        if (error) {
            NSLog(@"[ChatGPTFilePicker] JS error: %@", error);
        } else {
            NSLog(@"[ChatGPTFilePicker] Upload bridge injected");
        }
    }];
}

%hook WKContentView

- (void)didMoveToWindow
{
    %orig;

    dispatch_async(dispatch_get_main_queue(), ^{
        CGFPInjectIntoWebView(self);
    });
}

- (void)_didCommitLoadForMainFrame
{
    %orig;

    dispatch_async(dispatch_get_main_queue(), ^{
        CGFPInjectIntoWebView(self);
    });
}

%end

%ctor
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];

    if (![bundleID isEqualToString:@"com.apple.mobilesafari"])
        return;

    NSOperatingSystemVersion version =
        [NSProcessInfo processInfo].operatingSystemVersion;

    if (version.majorVersion != 12)
        return;

    if (!objc_getClass("WKContentView"))
        return;

    NSLog(@"[ChatGPTFilePicker] Loaded into MobileSafari");
}
