# BLM4522 - Veritabanı Yönetimi Projeleri

Bu depo, **Ankara Üniversitesi Bilgisayar Mühendisliği** bölümü **BLM4522 (Ağ Tabanlı Paralel Dağıtım Sistemleri)** dersi kapsamında hazırlanmış veritabanı yönetimi projelerini içermektedir.

Muhammed Eren Köseoğlu — 22290604

Tüm projeler, `TechMarketDB` adlı tek bir örnek veritabanı (Müşteriler, Çalışanlar, Siparişler tabloları) üzerinden farklı veritabanı yönetim konularını uygulamalı olarak göstermektedir. Vize projeleri SQL Server (T-SQL), final projeleri ise PostgreSQL üzerinde gerçekleştirilmiştir.

---

## 📁 Vize Projeleri (`vize/` — SQL Server)

### Proje 2 — Yedekleme ve Felaketten Kurtarma
`02_Backup_And_Recovery_Proj2.sql`
Full, Differential ve Transaction Log yedeklerinin alınması, yedeklerin test edilmesi, Tail-Log ile felaketten kurtarma senaryosu ve SQL Server Agent ile otomatik yedekleme zamanlayıcısı.

### Proje 3 — Güvenlik ve Erişim Kontrolü
`03_Security_And_Access_Proj3.sql`
Kullanıcı rolleri ve izin yönetimi, `EncryptByPassPhrase` ile hücre seviyesinde veri şifreleme (kredi kartı bilgisi), `sp_executesql` ile SQL Injection önleme ve Server Audit ile kullanıcı aktivite loglaması.

---

## 📁 Final Projeleri (`final/` — PostgreSQL)

### Proje 1 — Performans Optimizasyonu ve İzleme
`04_Performance_Optimization_Proj1.sql`
`pg_stat_statements` ile maliyetli sorguların analizi, sık aranan sütunlara B-Tree indeks tanımlanması (Seq Scan → Index/Bitmap Scan karşılaştırması) ve `pg_monitor` yetkili kısıtlı izleme rolü oluşturulması.

### Proje 5 — Veri Temizleme ve ETL Süreçleri
`05_Data_Cleaning_ETL_Proj5.sql`
Kirli/hatalı verilerin yüklendiği bir Staging (geçici) tablo tasarımı, verilerin temizlenmesi ve dönüştürülmesi (Transform & Clean) ve onaylanan verilerin ana tabloya aktarılması (ETL: Extract, Transform, Load).

### Proje 6 — Veritabanı Yükseltme ve Sürüm Yönetimi
`06_Database_Upgrade_Version_Proj6.sql`
Event Trigger ve PL/pgSQL ile şema değişikliklerinin (DDL) otomatik loglanması, yeni sürüm testi ve geri alma (rollback) senaryosu, tüm değişikliklerin `SchemaChangeLog` tablosuna kaydedilmesi.

---

