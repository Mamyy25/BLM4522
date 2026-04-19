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



## BÖLÜM 2: VERİTABANI GÜVENLİĞİ VE ERİŞİM KONTROLÜ (PROJE 3)

### 2.1. Erişim Yönetimi (Kullanıcı Rolleri ve İzinler)
**Uygulama Adımı:** SQL Server Authentication aracılığıyla farklı departmandaki çalışanlara kısıtlı erişim profilleri oluşturulmuştur. Satış kullanıcısı şirket siparişlerini görebilirken, müşterilerin "Kredi Kartı" bilgisini göremeyecek şekilde izni engellenmiştir.

### 2.2. Veri Şifreleme (Hücre Seviyesinde Şifreleme / Cell-Level Encryption)
**Uygulama Adımı:** Express sürüm kapsamında verileri korumak için müşterilerin Kredi Kartı sütunu `EncryptByPassPhrase` yöntemiyle hücre bazlı şifrelenmiş, okunamaz bir Binary formatına (`0x0113..`) dönüştürülmüştür. 

### 2.3. SQL Injection Testleri
**Uygulama Adımı:** Dinamik SQL metin birleştirmelerinin yol açtığı güvenlik açıklarına karşı `sp_executesql` prosedürü kullanılmış ve uygulamanın yolladığı dış veriler, zararlı komutlar çalıştıramaması için yalnızca "Parametre" şeklinde sınırlandırılmıştır.

### 2.4. Audit Logları (Kullanıcı Aktivitelerini İzleme)
**Uygulama Adımı:** Veritabanındaki tablolar üzerinde kullanıcıların gerçekleştirdiği onaylanmış dışındaki veri silme veya değiştirme işlemleri Server Audit kullanılarak fiziksel bir log dosyasına kaydedilmiştir.


