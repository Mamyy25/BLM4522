-- Veritabanını Oluştur
USE master;
GO

IF EXISTS(select * from sys.databases where name='TechMarketDB')
BEGIN
    ALTER DATABASE TechMarketDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechMarketDB;
END
GO

CREATE DATABASE TechMarketDB;
GO

USE TechMarketDB;
GO

CREATE TABLE Musteriler (
    MusteriID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    KrediKartiNo NVARCHAR(20) NOT NULL 
);
GO

CREATE TABLE Calisanlar (
    CalisanID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad NVARCHAR(100) NOT NULL,
    Departman NVARCHAR(50) NOT NULL,
    Maas DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Siparisler (
    SiparisID INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID INT FOREIGN KEY REFERENCES Musteriler(MusteriID),
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    Tutar DECIMAL(10,2) NOT NULL
);
GO


-- Müşterileri Ekle
INSERT INTO Musteriler (AdSoyad, Email, KrediKartiNo) VALUES 
('Ahmet Yılmaz', 'ahmet.y@email.com', '4532-1111-2222-3333'),
('Ayşe Kaya', 'ayse.k@email.com', '4532-4444-5555-6666'),
('Mehmet Öz', 'mehmet.o@email.com', '5521-7777-8888-9999'),
('Fatma Çelik', 'fatma.c@email.com', '5521-0000-1111-2222');
GO

-- Çalışanları Ekle
INSERT INTO Calisanlar (AdSoyad, Departman, Maas) VALUES 
('Ali Veli', 'Satış', 15000.00),
('Selin Demir', 'İnsan Kaynakları', 18000.00),
('Burak Can', 'IT', 20000.00);
GO

-- Siparişleri Ekle
INSERT INTO Siparisler (MusteriID, SiparisTarihi, Tutar) VALUES 
(1, '2023-10-01 10:30:00', 1250.50),
(2, '2023-10-02 14:15:00', 540.00),
(1, '2023-10-05 09:45:00', 3200.00),
(3, '2023-10-06 16:20:00', 150.75),
(4, '2023-10-10 11:10:00', 4500.00);
GO

