-- TechMarketDB - PostgreSQL Kurulum Scripti

-- Tabloları sıfırla (varsa)
DROP TABLE IF EXISTS Siparisler CASCADE;
DROP TABLE IF EXISTS Musteriler CASCADE;
DROP TABLE IF EXISTS Calisanlar CASCADE;

CREATE TABLE Musteriler (
    MusteriID SERIAL PRIMARY KEY,
    AdSoyad   VARCHAR(100) NOT NULL,
    Email     VARCHAR(100) NOT NULL,
    KrediKartiNo VARCHAR(20) NOT NULL
);

CREATE TABLE Calisanlar (
    CalisanID  SERIAL PRIMARY KEY,
    AdSoyad    VARCHAR(100) NOT NULL,
    Departman  VARCHAR(50)  NOT NULL,
    Maas       DECIMAL(10,2) NOT NULL
);

CREATE TABLE Siparisler (
    SiparisID     SERIAL PRIMARY KEY,
    MusteriID     INT REFERENCES Musteriler(MusteriID),
    SiparisTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Tutar         DECIMAL(10,2) NOT NULL
);

-- Müşteri verileri
INSERT INTO Musteriler (AdSoyad, Email, KrediKartiNo) VALUES
('Ahmet Yılmaz', 'ahmet.y@email.com', '4532-1111-2222-3333'),
('Ayşe Kaya',   'ayse.k@email.com',  '4532-4444-5555-6666'),
('Mehmet Öz',   'mehmet.o@email.com','5521-7777-8888-9999'),
('Fatma Çelik', 'fatma.c@email.com', '5521-0000-1111-2222');

-- Çalışan verileri
INSERT INTO Calisanlar (AdSoyad, Departman, Maas) VALUES
('Ali Veli',    'Satış',            15000.00),
('Selin Demir', 'İnsan Kaynakları', 18000.00),
('Burak Can',   'IT',               20000.00);

-- Sipariş verileri
INSERT INTO Siparisler (MusteriID, SiparisTarihi, Tutar) VALUES
(1, '2023-10-01 10:30:00', 1250.50),
(2, '2023-10-02 14:15:00',  540.00),
(1, '2023-10-05 09:45:00', 3200.00),
(3, '2023-10-06 16:20:00',  150.75),
(4, '2023-10-10 11:10:00', 4500.00);

-- Doğrulama
SELECT 'Musteriler' AS tablo, COUNT(*) AS kayit_sayisi FROM Musteriler
UNION ALL
SELECT 'Calisanlar',          COUNT(*) FROM Calisanlar
UNION ALL
SELECT 'Siparisler',          COUNT(*) FROM Siparisler;
