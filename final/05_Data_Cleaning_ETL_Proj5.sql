-- =======================================================================
-- VERİ TEMİZLEME VE ETL SÜREÇLERİ TASARIMI (PROJE 5 - POSTGRESQL)
-- =======================================================================

-- 1. Staging (Geçici) Tablosunun Oluşturulması
DROP TABLE IF EXISTS Siparisler_Staging;
CREATE TABLE Siparisler_Staging (
    TempID SERIAL PRIMARY KEY,
    MusteriID INT,
    SiparisTarihi TIMESTAMP,
    Tutar DECIMAL(10,2),
    Durum VARCHAR(50) DEFAULT 'Bekliyor'
);

-- Dış sistemden gelen kirli/hatalı verilerin simülasyonu
INSERT INTO Siparisler_Staging (MusteriID, SiparisTarihi, Tutar) VALUES 
(1, '2023-11-01 10:00:00', 1500.00), -- Geçerli
(2, NULL, 500.00),                  -- Hata: Tarih yok
(3, '2023-11-02 12:00:00', -100.00),-- Hata: Negatif tutar
(99, '2023-11-03 09:00:00', 250.00),-- Hata: Olmayan müşteri (Referans hatası)
(4, '2023-11-04 15:00:00', 3000.00);-- Geçerli

SELECT * FROM Siparisler_Staging;

-- 2. Veri Temizleme (Data Cleaning) ve Dönüştürme (Transformation) Süreçleri

-- Kural 1: Tutarı negatif olan hatalı kayıtları 'Reddedildi' olarak işaretle
UPDATE Siparisler_Staging
SET Durum = 'Reddedildi: Negatif Tutar'
WHERE Tutar <= 0;

-- Kural 2: Sipariş tarihi olmayanlara bugünün tarihini atayarak dönüştür
UPDATE Siparisler_Staging
SET SiparisTarihi = CURRENT_TIMESTAMP, Durum = 'Düzeltildi: Tarih Eklendi'
WHERE SiparisTarihi IS NULL AND Durum = 'Bekliyor';

-- Kural 3: Müşteriler tablosunda olmayan MusteriID'ye sahip kayıtları reddet
UPDATE Siparisler_Staging
SET Durum = 'Reddedildi: Gecersiz Musteri'
WHERE MusteriID NOT IN (SELECT MusteriID FROM Musteriler) AND Durum = 'Bekliyor';

SELECT TempID, MusteriID, SiparisTarihi, Tutar, Durum FROM Siparisler_Staging;

-- 3. Veri Yükleme (Data Loading)
-- Sadece temiz ve geçerli verileri ana 'Siparisler' tablosuna aktarma 
INSERT INTO Siparisler (MusteriID, SiparisTarihi, Tutar)
SELECT MusteriID, SiparisTarihi, Tutar
FROM Siparisler_Staging
WHERE Durum = 'Bekliyor' OR Durum LIKE 'Düzeltildi%';

-- Yüklenen kayıtları Staging tablosunda işaretle
UPDATE Siparisler_Staging
SET Durum = 'Başarıyla Yüklendi'
WHERE Durum = 'Bekliyor' OR Durum LIKE 'Düzeltildi%';


-- 4. Veri Kalitesi Raporları
-- İşlem sonucu verilerin durumunu raporlama
SELECT 
    Durum, 
    COUNT(*) AS KayitSayisi, 
    SUM(Tutar) AS ToplamTutar
FROM Siparisler_Staging
GROUP BY Durum;
