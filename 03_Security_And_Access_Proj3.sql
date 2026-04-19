-- PROJE 3: VERİTABANI GÜVENLİĞİ VE ERİŞİM KONTROLÜ

USE master;
GO

-- 1. VERİ ŞİFRELEME (Hücre Seviyesinde Şifreleme / Cell-Level Encryption)

USE TechMarketDB;
GO

-- Şifreli verilerin saklanacağı yeni sütun
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SifreliKrediKarti' AND Object_ID = Object_ID(N'dbo.Musteriler'))
BEGIN
    ALTER TABLE Musteriler ADD SifreliKrediKarti VARBINARY(MAX);
END
GO

-- veri şifreleme
IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'KrediKartiNo' AND Object_ID = Object_ID(N'dbo.Musteriler'))
BEGIN
    UPDATE Musteriler SET SifreliKrediKarti = ENCRYPTBYPASSPHRASE('CokGizliSifre_123!!', KrediKartiNo);
    ALTER TABLE Musteriler DROP COLUMN KrediKartiNo;
END
GO

-- Tablodaki verilerin şifreli halini görme
SELECT AdSoyad AS Musteri, SifreliKrediKarti AS [Sifrelenmis Görüntü] FROM Musteriler;
GO

-- şifreli veriyi geri çözme
SELECT 
    AdSoyad AS Musteri, 
    CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('CokGizliSifre_123!!', SifreliKrediKarti)) AS [Cozulmus Gercek Veri] 
FROM Musteriler;
GO

PRINT 'Hücre Seviyesinde Şifreleme (Cell-Level Encryption) başarıyla uygulandı.'
GO

-- 2. ERİŞİM YÖNETİMİ VE ROLLER
-- SQL Server Authentication ile Login
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'SalesUser')
    CREATE LOGIN SalesUser WITH PASSWORD = 'SalesPassword123!';
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'HRUser')
    CREATE LOGIN HRUser WITH PASSWORD = 'HRPassword123!';
GO

USE TechMarketDB;
GO

-- Login'ler için kullanıcılar
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SalesUser')
    CREATE USER SalesUser FOR LOGIN SalesUser;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'HRUser')
    CREATE USER HRUser FOR LOGIN HRUser;
GO

-- Role göre yetkilendirme 
-- Satış yetkilisi sadece Siparişleri ve Müşteri temel bilgilerine erişebilir
GRANT SELECT, INSERT, UPDATE ON dbo.Siparisler TO SalesUser;
GRANT SELECT (MusteriID, AdSoyad, Email) ON dbo.Musteriler TO SalesUser;
-- Satış görevlisinin Müşterilerin Şifrelenen Kredi Kartı alanını göremez
DENY SELECT (SifreliKrediKarti) ON dbo.Musteriler TO SalesUser;

-- İK görevlisi sadece Çalışanları görebilsin, müşterilere erişemesin
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Calisanlar TO HRUser;
DENY SELECT ON dbo.Musteriler TO HRUser;
DENY SELECT ON dbo.Siparisler TO HRUser;
GO

PRINT 'Kullanıcılar(SalesUser, HRUser), Roller ve Yetkilendirmeler başarıyla tanımlandı.'
GO


-- 3. SQL İNJECTION 
USE TechMarketDB;
GO

-- Parametreli kullanım, girilen ifadeyi string olarak algılar, sql kodu olarak işletmez.
EXEC sp_executesql 
    N'SELECT * FROM Musteriler WHERE AdSoyad = @MusteriAd', 
    N'@MusteriAd NVARCHAR(100)', 
    @MusteriAd = ''' OR 1=1 --'; 
GO

-- 4. SERVER AUDIT

USE master;
GO

-- Audit oluşturma
IF NOT EXISTS (SELECT * FROM sys.server_audits WHERE name = 'TechMarket_Audit')
BEGIN
    CREATE SERVER AUDIT TechMarket_Audit
    TO FILE ( FILEPATH = 'C:\Backup\' ); 
END
GO

ALTER SERVER AUDIT TechMarket_Audit WITH (STATE = ON);
GO

USE TechMarketDB;
GO

IF NOT EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'TechMarket_DB_AuditSpec')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION TechMarket_DB_AuditSpec
    FOR SERVER AUDIT TechMarket_Audit
    -- Calisanlar tablosundaki tüm DELETE işlemlerini izler:
    ADD (DELETE ON SCHEMA::dbo BY [public]),
    -- Musteriler tablosundaki hatalı erişimleri vs. raporlayabiliriz
    ADD (UPDATE ON SCHEMA::dbo BY [public])
    WITH (STATE = ON);
END
GO

PRINT 'SQL Server Audit konfigürasyonu tamamlandı. Loglar C:\Backup dizinine kaydedilecek.'
GO
