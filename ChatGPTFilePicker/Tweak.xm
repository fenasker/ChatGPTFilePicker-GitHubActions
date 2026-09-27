#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface WKFileUploadPanel : NSObject
- (void)_showDocumentPickerMenu;
- (void)_showMediaSourceSelectionSheet;
- (void)_showFilePickerMenu;
- (void)_showPhotoPickerWithSourceType:(NSInteger)sourceType;
@end

static BOOL CGFPPhotoLibraryAvailable(void) {
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

%hook WKFileUploadPanel

- (void)_showDocumentPickerMenu {
    NSLog(@"[ChatGPTFilePicker] _showDocumentPickerMenu");

    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        [self _showPhotoPickerWithSourceType:
              UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

- (void)_showMediaSourceSelectionSheet {
    NSLog(@"[ChatGPTFilePicker] _showMediaSourceSelectionSheet");

    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        [self _showPhotoPickerWithSourceType:
              UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

- (void)_showFilePickerMenu {
    NSLog(@"[ChatGPTFilePicker] _showFilePickerMenu");

    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        [self _showPhotoPickerWithSourceType:
              UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

%end

%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];

    if (![bundleID isEqualToString:@"com.apple.mobilesafari"])
        return;

    NSOperatingSystemVersion v =
        [NSProcessInfo processInfo].operatingSystemVersion;

    if (v.majorVersion != 12)
        return;

    Class cls = objc_getClass("WKFileUploadPanel");

    if (!cls)
        return;

    %init(WKFileUploadPanel = cls);

    NSLog(@"[ChatGPTFilePicker] Loaded into MobileSafari");
}
