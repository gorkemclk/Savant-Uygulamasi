import 'package:flutter/foundation.dart';

/// Birden fazla ekranın paylaşması gereken state için tek, merkezi
/// `ChangeNotifier`. `SavantApp` bunun tek instance'ını oluşturur ve
/// ihtiyacı olan ekranlara constructor üzerinden geçirir.
///
/// Ekranlar `initState()`'te `addListener`, `dispose()`'da `removeListener`
/// çağırıp gelen bildirimde kendi `setState`'lerini tetikler.
///
/// Şu an paylaşılacak somut bir alan yok (streak sayısı gibi veriler
/// Gün 7'de buraya eklenecek); iskelet, mimari şimdiden hazır olsun diye var.
class AppState extends ChangeNotifier {}
