# Savant — Proje Spesifikasyonu (Claude Code için)

## 1. Genel Bakış

**Uygulama Adı:** Savant
**Platform:** Android (Flutter, Dart)
**Amaç:** Kullanıcıya günlük genel kültür kartları (Tarih, Jeopolitik, Bilim, Sanat, Genel Kültür) sunan, spaced repetition (aralıklı tekrar) algoritmasıyla öğrenmeyi pekiştiren, quiz modu ve streak takibi olan bir mobil öğrenme uygulaması.

**Hedef Kitle:** Genel kültürünü geliştirmek isteyen, günde birkaç dakika ayırabilen kullanıcılar.

**İçerik Kaynağı:** Kartlar önceden üretilmiş ve `cards.json` dosyasında hazır. Uygulama ilk açılışta bu JSON'u okuyup SQLite veritabanına seed eder. Uygulama İNTERNET GEREKTİRMEZ, tamamen offline çalışır. (Not: API key kullanılmıyor, bu yüzden güvenlik/maliyet riski yok.)

---

## 2. Teknoloji Yığını

- **Framework:** Flutter (en son stabil sürüm)
- **Dil:** Dart
- **State Management:** Riverpod (flutter_riverpod paketi)
- **Local Database:** SQLite (sqflite paketi)
- **Bildirimler:** flutter_local_notifications
- **Grafik/İstatistik:** fl_chart
- **Diğer:** path_provider (DB dosya yolu için), intl (tarih formatlama için)

---

## 3. Veri Modeli

### 3.1. `cards` tablosu (seed edilir, salt okunur)
| Alan | Tip | Açıklama |
|---|---|---|
| id | TEXT (PK) | Örn: "hist_001" |
| category | TEXT | Tarih / Jeopolitik / Bilim / Sanat / Genel Kültür |
| question | TEXT | Soru metni |
| options | TEXT (JSON array, 4 eleman) | Şıklar |
| correct_index | INTEGER | 0-3 arası doğru şık indexi |
| explanation | TEXT | Cevap sonrası gösterilecek açıklama |
| difficulty | TEXT | kolay / orta / zor |

### 3.2. `user_progress` tablosu (SM-2 algoritması verisi)
| Alan | Tip | Açıklama |
|---|---|---|
| card_id | TEXT (FK -> cards.id) | |
| repetition_count | INTEGER | Kaç kez tekrar edildi (default 0) |
| ease_factor | REAL | SM-2 kolaylık faktörü (default 2.5) |
| interval_days | INTEGER | Bir sonraki gösterime kaç gün var (default 0) |
| next_review_date | TEXT (ISO date) | Bir sonraki gösterim tarihi |
| last_reviewed_date | TEXT (ISO date, nullable) | Son gösterim tarihi |
| status | TEXT | "new" / "learning" / "known" |

### 3.3. `streak_log` tablosu
| Alan | Tip | Açıklama |
|---|---|---|
| date | TEXT (ISO date, PK) | Gün |
| cards_completed | INTEGER | O gün tamamlanan kart sayısı |
| streak_count | INTEGER | O güne kadar olan ardışık gün sayısı |

---

## 4. SM-2 Algoritması (Basitleştirilmiş)

Kullanıcı bir kartı gördükten sonra üç seçenekten birini işaretler: **Zor / Orta / Kolay** (kalite puanı: Zor=2, Orta=3, Kolay=5, standart SM-2'de 0-5 skalası kullanılır, biz 3 seviyeye sadeleştiriyoruz).

```
Eğer kalite < 3 (Zor):
    repetition_count = 0
    interval_days = 1
Değilse:
    repetition_count += 1
    Eğer repetition_count == 1:
        interval_days = 1
    Elif repetition_count == 2:
        interval_days = 6
    Else:
        interval_days = round(interval_days * ease_factor)

ease_factor = ease_factor + (0.1 - (5 - kalite) * (0.08 + (5 - kalite) * 0.02))
ease_factor = max(ease_factor, 1.3)  // alt sınır

next_review_date = bugün + interval_days gün
```

Bu formül klasik SM-2'nin standart uyarlamasıdır, Claude Code'a bu pseudo-kodu birebir Dart'a çevirmesini söyleyebilirsin.

---

## 5. Ekranlar ve Akış

### 5.1. Ana Sayfa (Home)
- Bugünkü streak sayısı (büyük ve belirgin)
- "Bugünün Kartları" butonu → o gün `next_review_date <= bugün` olan kartlar + öğrenilmemiş yeni kartlardan bir set (örn. günde 10-15 kart) gösterilir
- Kategori bazlı ilerleme özet çubukları (5 kategori, her biri % tamamlanma)
- Quiz Moduna hızlı erişim butonu

### 5.2. Kart Akışı (Study Flow)
- Tek kart tam ekranda gösterilir: soru + 4 şık
- Kullanıcı bir şık seçer → doğru/yanlış geri bildirimi + açıklama gösterilir
- Ardından "Bu kart sana ne kadar zor geldi?" sorusu ile Zor/Orta/Kolay seçimi yapılır → SM-2 güncellenir
- Set bitince özet ekranı: kaç doğru, kaç yanlış, streak güncellendi bilgisi

### 5.3. Quiz Modu
- Kategori seçimi (opsiyonel, "Karışık" varsayılan)
- Rastgele 10 soruluk çoktan seçmeli test
- Süre sınırı yok (istersen sonradan eklenir)
- Sonunda skor ekranı (X/10) + yanlış yapılan kartların listesi

### 5.4. İlerleme / İstatistik Ekranı
- Kategori bazlı öğrenilen/toplam kart grafiği (bar chart, fl_chart)
- Son 7-30 günlük streak takvimi (basit heatmap veya çizgi grafik)
- Toplam öğrenilen kart sayısı, toplam quiz sayısı

### 5.5. Ayarlar
- Günlük hatırlatma bildirimi saat seçimi (varsayılan 20:00)
- Bildirimi aç/kapat

---

## 6. Bildirim Mantığı

- Her gün belirlenen saatte, kullanıcı o gün henüz kart çevirmediyse local notification gönderilir: "Bugün henüz kart çevirmedin! Streakini kaybetme 🔥"
- flutter_local_notifications ile günlük tekrarlayan bildirim zamanlanır (scheduled notification)

---

## 6.5. API Entegrasyonu — "Günün Bonus Soruları" (Open Trivia DB)

**Amaç:** Staj amirinin talebi üzerine, uygulamaya canlı bir API entegrasyonu eklendi. Mevcut offline mimari (SQLite + seed edilen cards.json) korunuyor; API katmanı ek ve izole bir özellik olarak entegre ediliyor.

**Kaynak API:** Open Trivia Database — https://opentdb.com/api.php — ücretsiz, API key gerektirmiyor, kayıt gerektirmiyor.

**Endpoint:**
```
GET https://opentdb.com/api.php?amount=3&type=multiple
```

**Davranış:**
- Uygulama günde bir kez (kullanıcı ana sayfaya girdiğinde, o gün için henüz çekilmediyse) API'den 3 rastgele çoktan seçmeli soru çeker.
- Çekilen sorular SQLite'a kalıcı olarak KAYDEDİLMEZ, sadece o günlük gösterim için tutulur. Spaced repetition sistemine dahil değildir (kaynağı harici olduğu için).
- Günün bonus sorularının çekildiği tarih `SharedPreferences` içinde saklanır (`last_bonus_fetch_date`); aynı gün içinde tekrar API çağrısı yapılmaz.
- API yanıtındaki `correct_answer` ve `incorrect_answers` alanları HTML-encoded gelebilir (örn. `&quot;`, `&#039;`) — gösterim öncesi decode edilmeli.
- Şıklar (doğru + 3 yanlış cevap) gösterim sırasında karıştırılır (shuffle), doğru cevap her zaman aynı sırada olmasın.

**Hata Yönetimi:**
- İnternet yoksa / timeout olursa: kullanıcıya "Bonus sorular şu an yüklenemedi, internet bağlantını kontrol et" mesajı gösterilir, uygulamanın geri kalanı (offline kart sistemi) normal çalışmaya devam eder.
- `response_code != 0` dönerse (API'nin kendi hata kodu): aynı şekilde nazik bir hata mesajı gösterilir, tekrar deneme butonu sunulabilir.

**Yeni Dosyalar:**
```
lib/
  services/
    trivia_api_service.dart   // HTTP GET + JSON parse + hata yönetimi
  models/
    bonus_question_model.dart // BonusQuestion sınıfı
  providers/
    bonus_question_provider.dart  // Riverpod: günlük bonus soru state'i
  widgets/
    bonus_question_card.dart  // UI: "🎁 Günün Bonus Soruları" bölümü
```

**Gerekli paket:** `http` (pubspec.yaml'a eklenmeli)

**Örnek servis mantığı (pseudo-kod):**
```
fetchDailyBonusQuestions():
    lastFetchDate = SharedPreferences'tan oku
    eğer lastFetchDate == bugün:
        cache'lenmiş soruları döndür
    değilse:
        try:
            response = http.get("https://opentdb.com/api.php?amount=3&type=multiple")
            json = decode(response.body)
            eğer json.response_code != 0:
                hata fırlat
            questions = json.results.map(decode HTML entities, parse et)
            cache'e kaydet, lastFetchDate = bugün
            questions döndür
        catch (network hatası):
            kullanıcıya hata mesajı göster, boş liste döndür
```

**UI Yerleşimi:** Ana sayfada, günlük kart setinin altında ayrı bir kart/bölüm olarak "🎁 Günün Bonus Soruları" başlığıyla gösterilir. Bu sorular normal kart akışından görsel olarak ayrışmalı (örn. farklı bir arka plan rengi) ki kullanıcı bunun "canlı/dış kaynak" içerik olduğunu ayırt edebilsin.

---

## 7. Proje Klasör Yapısı (Önerilen)

```
lib/
  main.dart
  models/
    card_model.dart
    user_progress_model.dart
    streak_model.dart
    bonus_question_model.dart    // Bölüm 6.5
  services/
    database_service.dart       // sqflite init + CRUD
    seed_service.dart            // cards.json'u ilk açılışta DB'ye yükler
    spaced_repetition_service.dart  // SM-2 algoritması
    notification_service.dart
    trivia_api_service.dart      // Open Trivia DB API entegrasyonu (Bölüm 6.5)
  providers/
    card_provider.dart           // Riverpod providers
    progress_provider.dart
    streak_provider.dart
    bonus_question_provider.dart // Bölüm 6.5
  screens/
    home_screen.dart
    study_screen.dart
    quiz_screen.dart
    stats_screen.dart
    settings_screen.dart
  widgets/
    flip_card_widget.dart
    category_progress_bar.dart
    streak_badge.dart
    bonus_question_card.dart     // Bölüm 6.5
assets/
  cards.json
```

---

## 8. Milestone Planı (10 Gün)

1. **Gün 1:** Proje kurulumu, paket bağımlılıkları, klasör iskeleti, `cards.json`'un assets'e eklenmesi
2. **Gün 2:** SQLite şeması + seed servisi (cards.json → DB), model sınıfları
3. **Gün 3-4:** Ana sayfa + kart akışı (Study Flow) UI ve mantığı
4. **Gün 5:** SM-2 algoritması entegrasyonu ve test
5. **Gün 6:** Quiz modu
6. **Gün 7:** Streak sistemi + local notification
7. **Gün 8:** İstatistik ekranı + fl_chart grafikleri + **Open Trivia DB API entegrasyonu (Günün Bonus Soruları, Bölüm 6.5)**
8. **Gün 9:** UI cilalama, tutarlı tema/renk paleti, hata ayıklama
9. **Gün 10:** Test, ekran görüntüleri, staj raporu için dokümantasyon

> Not: 10 gün dar geliyorsa API entegrasyonunu Gün 9'a kaydırıp cilalamayı Gün 10 ile birleştirebilirsin — API kısmı görece küçük bir iş (tek servis dosyası + tek UI bileşeni).

---

## 9. Claude Code'a İlk Prompt Önerisi

Bu dokümanı ve `cards.json` dosyasını Claude Code'a verdikten sonra şu şekilde bir ilk istekle başlayabilirsin:

> "Bu spec dokümanına göre Flutter projesinin iskeletini oluştur: pubspec.yaml bağımlılıkları, klasör yapısı, cards.json'u assets'e ekleme ve SQLite şemasını oluşturan database_service.dart dosyasını yaz. Riverpod kullan."

Sonraki günlerde milestone planındaki her adımı ayrı ayrı isteyerek ilerle — tek seferde her şeyi istemek yerine adım adım gitmek hem kaliteyi artırır hem de neyi neden yaptığını takip etmeni kolaylaştırır (staj raporunda işine yarar).

---

## 10. Staj Raporu İçin Notlar

- **Kullanılan mimari desenler:** Repository/Service pattern, Provider pattern (state management), Observer pattern (Riverpod state dinleme)
- **Öne çıkarılabilecek teknik konular:** Local database tasarımı ve normalizasyon, spaced repetition algoritması (bilişsel bilim temelli), local notification zamanlama, state management mimarisi
- **Vurgulanabilecek nokta:** Uygulamanın çekirdek işlevselliği (kart tekrar sistemi, quiz, streak) tamamen offline çalışıyor — bu güvenlik ve performans açısından bilinçli bir mimari tercih. Buna ek olarak "Günün Bonus Soruları" özelliğiyle Open Trivia DB (opentdb.com) açık kaynak API'sinden canlı veri çekiliyor; bu da HTTP istekleri, JSON parse etme, hata yönetimi (network hatası, timeout, geçersiz yanıt) ve local cache stratejisi (günde bir kez çekme) gibi konularda pratik gösteriyor. İki yaklaşımın bir arada kullanılması — offline-first çekirdek + opsiyonel online zenginleştirme — bilinçli bir mimari karar olarak raporda sunulabilir.
