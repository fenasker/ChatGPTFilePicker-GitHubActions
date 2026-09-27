#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface WKFileUploadPanel : NSObject
- (void)_showDocumentPickerMenu;
- (void)_showMediaSourceSelectionSheet;
- (void)_showFilePickerMenu;
- (void)_showPhotoPickerWithSourceType:(NSInteger)sourceType;
@end

static BOOL CGFPPhotoLibraryAvailable(void) {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

%hook WKFileUploadPanel

- (void)_showDocumentPickerMenu {
    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        NSLog(@"[ChatGPTFilePicker] _showDocumentPickerMenu -> Photo Library");

        [self _showPhotoPickerWithSourceType:
            UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

- (void)_showMediaSourceSelectionSheet {
    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        NSLog(@"[ChatGPTFilePicker] _showMediaSourceSelectionSheet -> Photo Library");

        [self _showPhotoPickerWithSourceType:
            UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }

    %orig;
}

- (void)_showFilePickerMenu {
    if (CGFPPhotoLibraryAvailable() &&
        [self respondsToSelector:@selector(_showPhotoPickerWithSourceType:)]) {

        NSLog(@"[ChatGPTFilePicker] _showFilePickerMenu -> Photo Library");

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

    if (objc_getClass("WKFileUploadPanel") == Nil)
        return;

    %init(WKFileUploadPanel = objc_getClass("WKFileUploadPanel"));

    NSLog(@"[ChatGPTFilePicker] Loaded into MobileSafari");
}
