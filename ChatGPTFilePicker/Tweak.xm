#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static NSString *CGFPJavaScript(void) {
    return
    @"(function() {"
    "  if (window.__CGFPInstalled) return;"
    "  window.__CGFPInstalled = true;"

    "  function isChatGPT() {"
    "    var h = location.hostname;"
    "    return h === 'chatgpt.com' ||"
    "           h.indexOf('.chatgpt.com') !== -1 ||"
    "           h === 'chat.openai.com' ||"
    "           h.indexOf('.chat.openai.com') !== -1;"
    "  }"

    "  function findUploadInput() {"
    "    return document.querySelector('#upload-files') ||"
    "           document.querySelector('#upload-photos') ||"
    "           document.querySelector('input[type=file]');"
    "  }"

    "  function isAttachButton(element) {"
    "    var el = element;"

    "    while (el && el !== document) {"
    "      if (el.getAttribute) {"
    "        var testid = el.getAttribute('data-testid');"
    "        var aria = el.getAttribute('aria-label');"
    "        var role = el.getAttribute('role');"
    "        var text = (el.textContent || '').trim();"

    "        if (testid === 'composer-plus-btn') return true;"
    "        if (aria === 'Add files and more') return true;"

    "        if (role === 'menuitem' &&"
    "            (/Add photos/i.test(text) || /files/i.test(text)))"
    "          return true;"
    "      }"

    "      el = el.parentNode;"
    "    }"

    "    return false;"
    "  }"

    "  document.addEventListener('click', function(event) {"
    "    if (!isChatGPT()) return;"
    "    if (!isAttachButton(event.target)) return;"

    "    var input = findUploadInput();"
    "    if (!input) return;"

    "    event.preventDefault();"
    "    event.stopPropagation();"

    "    try {"
    "      event.stopImmediatePropagation();"
    "    } catch (e) {}"

    "    input.click();"
    "  }, true);"
    "})();";
}

%hook WKWebView

- (instancetype)initWithFrame:(CGRect)frame
                 configuration:(WKWebViewConfiguration *)configuration
{
    WKUserContentController *controller =
        configuration.userContentController;

    WKUserScript *script =
        [[WKUserScript alloc]
            initWithSource:CGFPJavaScript()
            injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
            forMainFrameOnly:YES];

    [controller addUserScript:script];

    return %orig(frame, configuration);
}

%end
