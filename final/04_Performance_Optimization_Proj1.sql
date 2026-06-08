-- =======================================================================
-- VERİTABANI PERFORMANS OPTİMİZASYONU VE İZLEME (PROJE 1 - POSTGRESQL)
-- =======================================================================

-- 1. Veritabanı İzleme: pg_stat_statements eklentisi ile En Çok Kaynak Tüketen Sorguları Bulma
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Sistemde en fazla toplam yürütme zamanı (total_exec_time) harcayan ilk 5 sorgu:
SELECT 
    calls AS execution_count,
    total_exec_time AS total_worker_time,
    mean_exec_time AS avg_worker_time,
    query AS query_text
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;


-- 2. İndeks Yönetimi ve Sorgu İyileştirme

-- ADIM 2a: Küçük tablolarda PostgreSQL optimizer her zaman Seq Scan tercih ettiği için 1000 adet rastgele sipariş verisi.
INSERT INTO Siparisler (MusteriID, SiparisTarihi, Tutar)
SELECT
    (random() * 3 + 1)::INT,
    NOW() - (random() * 365 || ' days')::INTERVAL,
    round((random() * 5000 + 100)::NUMERIC, 2)
FROM generate_series(1, 1000);

-- Tablo istatistiklerini güncelle
ANALYZE Siparisler;

-- ADIM 2b: İndeks OLMADAN sorgu → "Seq Scan"
DROP INDEX IF EXISTS ix_siparisler_musteriid;

EXPLAIN ANALYZE
SELECT MusteriID, Tutar, SiparisTarihi
FROM Siparisler
WHERE MusteriID = 1;

-- ADIM 2c: B-Tree Index 
CREATE INDEX ix_siparisler_musteriid ON Siparisler (MusteriID) INCLUDE (Tutar, SiparisTarihi);

-- ADIM 2d: Aynı sorguyu İNDEKSLİ çalıştır
EXPLAIN ANALYZE
SELECT MusteriID, Tutar, SiparisTarihi
FROM Siparisler
WHERE MusteriID = 1;

-- ADIM 2e: İndeks kullanım istatistikleri
SELECT
    relname      AS table_name,
    indexrelname AS index_name,
    idx_scan     AS user_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE relname = 'siparisler';

-- Gereksiz / Kullanılmayan İndekslerin Kaldırılması
-- DROP INDEX IF EXISTS ix_kullanilmayan_indeks;


-- 3. Veri Yöneticisi Rolleri 
-- Performans izleme işlemleri yapacak kullanıcıya sistem istatistiklerini görebilmesi için 'pg_monitor' rolü tanımlanır.
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'perfmonitoruser') THEN
        CREATE ROLE perfmonitoruser WITH LOGIN PASSWORD 'PerfPassword123!';
    END IF;
END $$;

-- Kullanıcıya PostgreSQL'in sistem logları ve view'lerini görebilme (okuma) yetkisi tanımlanır.
GRANT pg_monitor TO perfmonitoruser;
