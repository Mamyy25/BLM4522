
-- PROJE 2: YEDEKLEME VE FELAKETTEN KURTARMA PLANLAMASI

USE master;
GO

-- 1. Veritabanı Kurtarma Modeli
ALTER DATABASE TechMarketDB SET RECOVERY FULL;
GO

-- 2. YEDEKLEME SENARYOSU (Backup)

-- Full Backup 
BACKUP DATABASE TechMarketDB
TO DISK = 'C:\Backup\TechMarketDB_Full.bak'
WITH FORMAT, INIT,
NAME = 'TechMarketDB Full Backup',
STATS = 10;
GO

USE TechMarketDB;
GO
INSERT INTO Siparisler (MusteriID, SiparisTarihi, Tutar) 
VALUES (2, GETDATE(), 750.00);
GO
USE master;
GO

-- Differential Backup 
BACKUP DATABASE TechMarketDB
TO DISK = 'C:\Backup\TechMarketDB_Diff.bak'
WITH INIT,
NAME = 'TechMarketDB Differential Backup',
STATS = 10;
GO

-- Transaction Log Backup 
BACKUP LOG TechMarketDB
TO DISK = 'C:\Backup\TechMarketDB_Log1.trn'
WITH INIT,
NAME = 'TechMarketDB Transaction Log Backup 1',
STATS = 10;
GO

-- Yedeklemenin Doğruluğunu Test Etme 
RESTORE VERIFYONLY
FROM DISK = 'C:\Backup\TechMarketDB_Full.bak';
GO

-- 3. FELAKET SİMÜLASYONU (Disaster Simulation)

USE TechMarketDB;
GO

SELECT GETDATE() AS 'Felaket_Ani';
-- SİLME İŞLEMİ
DELETE FROM Siparisler;
GO

SELECT * FROM Siparisler;
GO
USE master;
GO

-- SSMS'in veya arka plan işlemlerinin kilitlerini zorla kırmak için veritabanı "Tek Kullanıcı" (Single User) moduna alınır.
-- Aksi takdirde SSMS sekmesi açık olduğu için "database is in use" hatası alınır.
ALTER DATABASE TechMarketDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

BACKUP LOG TechMarketDB
TO DISK = 'C:\Backup\TechMarketDB_TailLog.trn'
WITH NO_TRUNCATE, NORECOVERY,
NAME = 'TechMarketDB Tail Log Backup';
GO

-- 4. KURTARMA SENARYOSU (Restore - Point in Time Recovery)

-- Full Backup'ı Geri Yükle 
RESTORE DATABASE TechMarketDB
FROM DISK = 'C:\Backup\TechMarketDB_Full.bak'
WITH NORECOVERY, REPLACE;
GO

-- Differential Backup'ı Geri Yükle 
RESTORE DATABASE TechMarketDB
FROM DISK = 'C:\Backup\TechMarketDB_Diff.bak'
WITH NORECOVERY;
GO

-- Önceki Log Yedeğini Yükle 
RESTORE LOG TechMarketDB
FROM DISK = 'C:\Backup\TechMarketDB_Log1.trn'
WITH NORECOVERY;
GO

-- Tail-Log Yedeğini Yükle ve Felaket Anından ÖNCEKİ bir T-anına dön
RESTORE LOG TechMarketDB
FROM DISK = 'C:\Backup\TechMarketDB_TailLog.trn'
WITH RECOVERY;
GO

ALTER DATABASE TechMarketDB SET MULTI_USER;
GO

-- Verilerin geri geldiğini doğrulama
USE TechMarketDB;
GO
SELECT * FROM Siparisler;
GO
PRINT 'Yedekleme ve Geri Yükleme senaryosu tamamlandı.';
GO

-- 5. ZAMANLAYICI İLE OTOMATİK YEDEKLEME (SQL Server Agent)
USE msdb;
GO

-- Eski görev kalıntısı varsa silme
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'TechMarketDB_Nightly_Full_Backup')
    EXEC sp_delete_job @job_name = N'TechMarketDB_Nightly_Full_Backup';
GO

-- Görevi Oluşturma
EXEC dbo.sp_add_job
    @job_name = N'TechMarketDB_Nightly_Full_Backup',
    @enabled = 1,
    @description = N'TechMarketDB için her gece 00:00 da otomatik alınan tam yedek.';
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'TechMarketDB_Nightly_Full_Backup',
    @step_name = N'Take_Backup',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE TechMarketDB TO DISK = ''C:\Backup\TechMarketDB_Auto.bak'' WITH INIT',
    @database_name = N'master';
GO

-- Zamanlayıcıyı Oluşturma 
EXEC dbo.sp_add_schedule
    @schedule_name = N'NightlyAtMidnight',
    @freq_type = 4, 
    @freq_interval = 1, 
    @active_start_time = 0; 
GO

-- Görevi ve Zamanlayıcıyı Bağlama
EXEC sp_attach_schedule
   @job_name = N'TechMarketDB_Nightly_Full_Backup',
   @schedule_name = N'NightlyAtMidnight';
GO

-- Görevi Veritabanı Sunucusuna Ekleme
EXEC dbo.sp_add_jobserver
    @job_name = N'TechMarketDB_Nightly_Full_Backup';
GO

PRINT 'Zamanlanmış otomatik yedekleme görevi sisteme eklendi.';
GO
