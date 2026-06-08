# BLM4522 PROJE RAPORU

**Drive Linki:** https://drive.google.com/drive/folders/1IiPwbvQ_XZO259W9J8NKdW0_gDG01TxS?usp=drive_link

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



## BÖLÜM 2: VERİTABANI GÜVENLİĞİ VE ERİŞİM KONTROLÜ (PROJE 3)

### 2.1. Erişim Yönetimi (Kullanıcı Rolleri ve İzinler)
**Uygulama Adımı:** SQL Server Authentication aracılığıyla farklı departmandaki çalışanlara kısıtlı erişim profilleri oluşturulmuştur. Satış kullanıcısı şirket siparişlerini görebilirken, müşterilerin "Kredi Kartı" bilgisini göremeyecek şekilde izni engellenmiştir.

### 2.2. Veri Şifreleme (Hücre Seviyesinde Şifreleme / Cell-Level Encryption)
**Uygulama Adımı:** Express sürüm kapsamında verileri korumak için müşterilerin Kredi Kartı sütunu `EncryptByPassPhrase` yöntemiyle hücre bazlı şifrelenmiş, okunamaz bir Binary formatına (`0x0113..`) dönüştürülmüştür. 

### 2.3. SQL Injection Testleri
**Uygulama Adımı:** Dinamik SQL metin birleştirmelerinin yol açtığı güvenlik açıklarına karşı `sp_executesql` prosedürü kullanılmış ve uygulamanın yolladığı dış veriler, zararlı komutlar çalıştıramaması için yalnızca "Parametre" şeklinde sınırlandırılmıştır.

### 2.4. Audit Logları (Kullanıcı Aktivitelerini İzleme)
**Uygulama Adımı:** Veritabanındaki tablolar üzerinde kullanıcıların gerçekleştirdiği onaylanmış dışındaki veri silme veya değiştirme işlemleri Server Audit kullanılarak fiziksel bir log dosyasına kaydedilmiştir.


## BÖLÜM 3: VERİTABANI PERFORMANS OPTİMİZASYONU VE İZLEME (PROJE 1)

### 3.1. Veritabanı İzleme (pg_stat_statements)
**Uygulama Adımı:** Sistem görünüm eklentileri (pg_stat_statements) kullanılarak sunucu üzerinde en çok kaynak (CPU/Zaman) tüketen maliyetli sorgular listelenmiş ve analiz edilmiştir.

### 3.2. İndeks Yönetimi ve Sorgu İyileştirme
**Uygulama Adımı:** Tablolar üzerinde performansı optimize etmek için çok aranan sütunlara (MusteriID) indeks (B-Tree Index) tanımlanmış, pg_stat_user_indexes ile atıl indeksler kontrol edilmiştir.

### 3.3. Veri Yöneticisi Rolleri (Erişim Yetkisi)
**Uygulama Adımı:** Performans izleme işlemleri için sunucu kaynaklarına kısıtlı ama okuma yetkili özel roller (pg_monitor yetkisi verilen perfmonitoruser) tanımlanmıştır.


## BÖLÜM 4: VERİ TEMİZLEME VE ETL SÜREÇLERİ TASARIMI (PROJE 5)

### 4.1. Staging (Geçici) Tablo ve Kirli Veri
**Uygulama Adımı:** Dış kaynaklardan gelen hatalı/kirli veriler için (eksik ID, eksi tutar vb.) PostgreSQL ortamında SERIAL yapılandırılmış bir geçici (Staging) tablo oluşturulmuş ve sisteme yüklenmiştir.

### 4.2. Veri Temizleme ve Dönüştürme
**Uygulama Adımı:** Sisteme aktarılan verilerde hatalar ayıklanmış, eksik bilgiler (tarih) mantıksal kurallarla (CURRENT_TIMESTAMP) doldurulmuş ve onarılamayan veriler reddedilmiştir (Transform & Clean).

### 4.3. Veri Yükleme (ETL Load)
**Uygulama Adımı:** Başarıyla temizlenen veriler, güvenli şekilde ana Siparişler tablosuna aktarılarak ETL (Extract, Transform, Load) süreci tamamlanmıştır.


## BÖLÜM 5: VERİTABANI YÜKSELTME VE SÜRÜM YÖNETİMİ (PROJE 6)

### 5.1. Event Triggers ve PL/pgSQL Kullanarak Sürüm Yönetimi
**Uygulama Adımı:** Tablolarda ve sütunlarda meydana gelen şema değişikliklerini izleyip raporlayabilmek için veritabanı seviyesinde bir Event Trigger ve Loglama Fonksiyonu tanımlanmıştır.

### 5.2. Test ve Yükseltme Geri Dönüşü
**Uygulama Adımı:** Yeni bir sürüm olarak bir tablo oluşturulup değiştirilmiş, ardından yapı (Rollback) olarak geri alınmış ve tüm adımların log tablosuna (SchemaChangeLog) kaydedildiği doğrulanmıştır.
