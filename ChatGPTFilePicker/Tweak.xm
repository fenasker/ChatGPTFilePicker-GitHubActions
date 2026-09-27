#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Private WebKit class used by iOS-era WebKit for HTML <input type="file"> uploads.
// This tweak intentionally avoids public API dependencies beyond UIKit.
@interface WKFileUploadPanel : NSObject
- (void)_showDocumentPickerMenu;
- (void)_showMediaSourceSelectionSheet;
- (void)_showPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;
@end

static BOOL CGFPPhotoLibraryAvailable(void) {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

%hook WKFileUploadPanel

- (void)_showDocumentPickerMenu {
    SEL photoSEL = @selector(_showPhotoPickerWithSourceType:);

    if ([self respondsToSelector:photoSEL] && CGFPPhotoLibraryAvailable()) {
        NSLog(@"[ChatGPTFilePicker] Forcing WebKit photo library picker");
        [(WKFileUploadPanel *)self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

- (void)_showMediaSourceSelectionSheet {
    SEL photoSEL = @selector(_showPhotoPickerWithSourceType:);

    if ([self respondsToSelector:photoSEL] && CGFPPhotoLibraryAvailable()) {
        NSLog(@"[ChatGPTFilePicker] Forcing WebKit photo library picker from media sheet");
        [(WKFileUploadPanel *)self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

%end

%ctor {
    // Only load into MobileSafari on iOS 12.x.
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleID isEqualToString:@"com.apple.mobilesafari"])
        return;

    NSOperatingSystemVersion v = [NSProcessInfo processInfo].operatingSystemVersion;
    if (v.majorVersion != 12)
        return;

    if (objc_getClass("WKFileUploadPanel") == Nil)
        return;

    %init(WKFileUploadPanel = objc_getClass("WKFileUploadPanel"));
}
