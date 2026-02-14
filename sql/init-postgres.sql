-- PostgreSQL Initialisierung für WebApp
-- Wird automatisch von docker-compose ausgeführt

-- Schema erstellen (falls nicht automatisch)
CREATE SCHEMA IF NOT EXISTS public;

-- Greetings Tabelle
CREATE TABLE IF NOT EXISTS greetings (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'de',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initial-Daten
INSERT INTO greetings (message, language) 
VALUES ('Hello World!', 'en')
ON CONFLICT DO NOTHING;

INSERT INTO greetings (message, language) 
VALUES ('Hallo Welt!', 'de')
ON CONFLICT DO NOTHING;

INSERT INTO greetings (message, language) 
VALUES ('¡Hola Mundo!', 'es')
ON CONFLICT DO NOTHING;

-- Index für Performance
CREATE INDEX IF NOT EXISTS idx_greetings_language ON greetings(language);

-- Berechtigungen prüfen
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO webapp_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO webapp_user;

-- Erfolgs-Nachricht
DO $$
BEGIN
    RAISE NOTICE 'PostgreSQL Schema erfolgreich initialisiert!';
END $$;
