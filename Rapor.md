# BLM4522 PROJE RAPORU

## BÖLÜM 1: YEDEKLEME VE FELAKETTEN KURTARMA PLANI (PROJE 2)

### 1.1. Full, Log ve Fark Yedeklemeleri
**Uygulama Adımı:** Veritabanının olası çökme senaryolarına karşı belirli periyotlarla TechMarketDB veritabanının fiziki Full (Tam), Differential (Fark) ve Transaction Log (Artık) yedeklerini yerel diske kaydettim.

### 1.2. Test Yedekleme Senaryoları 
**Uygulama Adımı:** Diske aldığım yedek dosyalarının, geri yükleme işlemi için sağlam ve okunabilir olup olmadığını test ettim.

### 1.3. Felaketten Kurtarma Senaryosu 
**Uygulama Adımı:** Yanlışlıkla çalıştırılan bir DELETE komutu sonucu silinen verilerin kurtarılması için, felaket anından hemen sonra bir Tail-Log aldım ve sistemi sorunsuz şekilde geri yükledim.

### 1.4. Zamanlayıcılarla Otomatik Yedekleme (SQL Server Agent)
**Uygulama Adımı:** Yedekleme süreçleri için MSDB üzerinden bir SQL Agent Job oluşturdum ve her gece saat 00:00'da çalışacak bir zamanlayıcı tanımladım.

*(Not: Database Mirroring özelliğini test edicek bir donanımım olmadığı için bu özelliği uygulayamadım.)*
