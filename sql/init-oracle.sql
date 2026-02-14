-- Oracle Initialisierung für WebApp Production
-- Ausführen mit: sqlplus username/password@SERVICE_NAME @init-oracle.sql

-- Verbindung testen
SELECT 'Connected to Oracle: ' || banner FROM v$version WHERE ROWNUM = 1;

-- Greetings Tabelle erstellen
CREATE TABLE greetings (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    message VARCHAR2(4000) NOT NULL,
    language VARCHAR2(10) DEFAULT 'de',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kommentar hinzufügen
COMMENT ON TABLE greetings IS 'Begrüßungsnachrichten für WebApp';
COMMENT ON COLUMN greetings.message IS 'Begrüßungstext';
COMMENT ON COLUMN greetings.language IS 'Sprache (ISO 639-1)';

-- Initial-Daten
INSERT INTO greetings (message, language) VALUES ('Hello World!', 'en');
INSERT INTO greetings (message, language) VALUES ('Hallo Welt!', 'de');
INSERT INTO greetings (message, language) VALUES ('¡Hola Mundo!', 'es');

COMMIT;

-- Index für Performance
CREATE INDEX idx_greetings_language ON greetings(language);

-- Statistiken aktualisieren
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => USER,
        tabname => 'GREETINGS',
        cascade => TRUE
    );
END;
/

-- Erfolgs-Meldung
SELECT 'Oracle Schema erfolgreich initialisiert!' AS status FROM DUAL;
SELECT 'Anzahl Greetings: ' || COUNT(*) AS count FROM greetings;

-- Berechtigungen für zusätzliche User (optional)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON greetings TO other_user;

EXIT;
