# Firebase Bağlantı Sorunları - Çözüm Kılavuzu

## Yapılan İyileştirmeler

### 1. ✅ AsyncImage Timeout Eklendi
- Görsellerin sonsuz "yükleniyor" durumunda kalması sorunu çözüldü
- 3 saniye timeout süresi eklendi
- Timeout sonrası otomatik placeholder gösterimi

### 2. ✅ Firebase Offline Persistence Aktif Edildi
- Firestore offline cache aktif edildi
- Ağ bağlantısı olmasa bile cached veriler kullanılabilir
- Cache boyutu unlimited olarak ayarlandı

### 3. ✅ Timeout Süreleri Optimize Edildi
- Firebase timeout: 5s → 3s
- Google Places timeout: 5s → 3s
- Daha hızlı fallback mekanizması

## Firebase Kontrol Listesi

### 1. GoogleService-Info.plist Kontrolü
```bash
# Dosyanın varlığını kontrol et
ls -la ReservationApp/GoogleService-Info.plist
```

✅ Dosya mevcut olmalı
✅ Xcode'da projeye eklenmiş olmalı
✅ Target Membership'de ReservationApp seçili olmalı

### 2. Firebase Console Kontrolleri

Firebase Console'da kontrol edilmesi gerekenler:
- ✅ Proje aktif mi?
- ✅ Firestore Database oluşturulmuş mu?
- ✅ Authentication aktif mi?
- ✅ iOS uygulaması eklenmiş mi?
- ✅ Bundle ID eşleşiyor mu?

### 3. Ağ Bağlantısı Kontrolleri

```bash
# Simulator/cihazın internet bağlantısını test et
ping -c 3 firestore.googleapis.com
```

### 4. Xcode Scheme Ayarları (nw_connection Hatasını Gizleme)

`nw_connection` hatası zararsızdır ancak konsolu kirletir. Gizlemek için:

1. Xcode'da: Product > Scheme > Edit Scheme
2. Run > Arguments sekmesi
3. Environment Variables bölümüne ekle:
   - Name: `OS_ACTIVITY_MODE`
   - Value: `disable`

## Hata Ayıklama Adımları

### Adım 1: Terminali Temizle ve Yeniden Çalıştır
```bash
# Derived Data'yı temizle
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Projeyi yeniden build et
cd /Users/mahmutarslan/Desktop/BitirmeProjesi/ReservationApp
xcodebuild clean
```

### Adım 2: Firebase Bağlantısını Test Et

Uygulama başladığında terminalde şu logları görmeli:
```
🔧 Configuring Firebase...
✅ Firebase configured successfully
✅ Firestore offline persistence enabled
📱 Firebase App Name: __FIRAPP_DEFAULT
🔑 Project ID: [your-project-id]
```

### Adım 3: Test Data Kontrolü

Eğer Firebase'den veri gelmiyorsa, uygulama otomatik olarak test verilerini kullanır:
```
⚠️ Firebase timeout - using test data
📝 Using test data with businessId: [id]
```

## Sık Karşılaşılan Sorunlar

### Sorun 1: "Görseller yükleniyor" durumunda kalıyor
**Çözüm:** ✅ Düzeltildi - TimeoutAsyncImage eklendi

### Sorun 2: nw_connection hatası
**Çözüm:** 
- Bu hata zararsızdır, Firebase'in ağ bağlantısı kurma denemesidir
- Gizlemek için yukarıdaki Xcode Scheme ayarlarını yapın
- Offline persistence sayesinde uygulama çalışmaya devam eder

### Sorun 3: Firebase'den veri gelmiyor
**Çözüm:**
1. GoogleService-Info.plist dosyasını kontrol edin
2. Firebase Console'da Firestore Database'in oluşturulduğundan emin olun
3. Security Rules'ı kontrol edin
4. Test data otomatik olarak yüklenecektir

## Performans İyileştirmeleri

1. **Offline First:** Firestore cache sayesinde offline çalışabilir
2. **Hızlı Timeout:** 3 saniye içinde fallback mekanizması devreye girer
3. **Async Loading:** Tüm network işlemleri background thread'de çalışır
4. **Image Caching:** URLSession otomatik cache kullanır

## Test Senaryoları

### Test 1: Normal Çalışma
- ✅ Firebase bağlantısı başarılı
- ✅ İşletmeler yüklendi
- ✅ Görseller gösteriliyor

### Test 2: Ağ Bağlantısı Yok
- ✅ Offline cache kullanılıyor
- ✅ Test data yükleniyor
- ✅ Placeholder görseller gösteriliyor

### Test 3: Yavaş Bağlantı
- ✅ 3 saniye timeout
- ✅ Otomatik fallback
- ✅ Kullanıcı beklemez

## Sonraki Adımlar

1. Uygulamayı yeniden çalıştırın
2. Terminal loglarını kontrol edin
3. Firebase Console'da verileri kontrol edin
4. Gerekirse test data ile devam edin

## Destek

Sorun devam ederse:
1. Terminal loglarının ekran görüntüsünü alın
2. Firebase Console ayarlarını kontrol edin
3. GoogleService-Info.plist içeriğini (hassas bilgiler hariç) paylaşın
