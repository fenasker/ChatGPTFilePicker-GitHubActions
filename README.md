# ChatGPTFilePicker — Windows'ta kurulum gerektirmeden derleme

Bu proje Windows'a Theos/LLVM/SDK kurmadan GitHub Actions üzerinde derlenebilir.

## Kullanım

1. GitHub.com'da yeni bir repository oluştur.
2. Bu klasördeki dosyaların tamamını repository'ye yükle.
3. **Actions** sekmesine gir.
4. `Build iOS 12 Tweak` workflow'unu seç.
5. **Run workflow** ile çalıştır.
6. İş bitince workflow sayfasının **Artifacts** bölümünden `ChatGPTFilePicker-deb` paketini indir.

## Hedef

- iOS 12.x
- arm64
- MobileSafari
- Theos
- iPhoneOS 12.4 SDK

Bu tweak deneysel bir uyumluluk denemesidir; iOS 12 WebKit'in özel API'lerine dayanır.
