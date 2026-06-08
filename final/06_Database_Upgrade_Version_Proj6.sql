-- =======================================================================
-- VERİTABANI YÜKSELTME VE SÜRÜM YÖNETİMİ (PROJE 6 - POSTGRESQL)
-- =======================================================================

-- 1. Sürüm Yönetimi İçin Şema Değişikliklerini İzleme Tablosu
DROP TABLE IF EXISTS SchemaChangeLog;
CREATE TABLE SchemaChangeLog (
    LogID SERIAL PRIMARY KEY,
    EventDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    EventType VARCHAR(100),
    ObjectType VARCHAR(100),
    ObjectName VARCHAR(255),
    LoginName VARCHAR(255)
);
SELECT * FROM SchemaChangeLog;

-- 2. PL/pgSQL Event Trigger Fonksiyonu Kullanarak Sürüm Yönetimi
CREATE OR REPLACE FUNCTION trg_log_schema_changes()
RETURNS event_trigger AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
        INSERT INTO SchemaChangeLog (EventType, ObjectType, ObjectName, LoginName)
        VALUES (TG_TAG, r.object_type, r.object_identity, current_user);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- DROP işlemlerini yakalayan ayrı fonksiyon
CREATE OR REPLACE FUNCTION trg_log_drop_changes()
RETURNS event_trigger AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM pg_event_trigger_dropped_objects() LOOP
        INSERT INTO SchemaChangeLog (EventType, ObjectType, ObjectName, LoginName)
        VALUES (TG_TAG, r.object_type, r.object_identity, current_user);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Olası çakışmayı önlemek için eski trigger varsa silinir
DROP EVENT TRIGGER IF EXISTS track_schema_changes;
DROP EVENT TRIGGER IF EXISTS track_drop_changes;

-- Event Trigger — CREATE/ALTER yakalar
CREATE EVENT TRIGGER track_schema_changes
ON ddl_command_end
EXECUTE FUNCTION trg_log_schema_changes();

-- DROP komutlarını yakalamak için ayrı sql_drop eventi
CREATE EVENT TRIGGER track_drop_changes
ON sql_drop
EXECUTE FUNCTION trg_log_drop_changes();


-- 3. Test, Yükseltme Planı ve Geri Dönüş Senaryosu
CREATE TABLE YeniModul_TestTablosu (
    TestID INT PRIMARY KEY,
    TestAdi VARCHAR(50)
);

-- Yeni versiyonda tablonda değişiklik 
ALTER TABLE YeniModul_TestTablosu ADD COLUMN Aciklama VARCHAR(200);
DROP TABLE YeniModul_TestTablosu;


-- 4. Sürüm Yönetimi Raporu
SELECT LogID, EventDate, EventType, ObjectType, ObjectName, LoginName
FROM SchemaChangeLog
ORDER BY EventDate DESC;
