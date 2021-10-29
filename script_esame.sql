-- (1) La prima per cancellare schemi e tabelle omonime eventualmente presenti nella base di dati.
\echo '\nElimino lo schema voli se esiste...'
DROP SCHEMA IF EXISTS VOLI CASCADE;


-- （2） La seconda per generare lo schema definendo vincoli opportuni.
\echo '\nCreo lo schema voli...'
CREATE SCHEMA VOLI;

\echo '\nImposto il search_path a VOLI'
SET
  search_path TO VOLI;

\echo '\nCreo il Dominio citta...'
CREATE DOMAIN dom_citta AS VARCHAR (32) NOT NULL;

\echo '\nCreo la tabella citta...'
CREATE TABLE citta (
  nome dom_citta PRIMARY KEY,
  numero_abitanti INT,
  nazione VARCHAR(64),
  CHECK(numero_abitanti >= 0)
);

\echo '\nCreo la tabella stazione...'
CREATE TABLE stazione (
  codice BIGSERIAL PRIMARY KEY,
  nome VARCHAR(64) UNIQUE,
  citta dom_citta REFERENCES citta(nome) ON DELETE CASCADE,
  categoria VARCHAR(64)
);


\echo '\nCreo la tabella treno...'
CREATE TABLE treno (
  codice BIGSERIAL PRIMARY KEY,
  orario_partenza TIME NOT NULL,
  orario_arrivo TIME NOT NULL,
  stazione_partenza BIGSERIAL REFERENCES stazione(codice) ON DELETE SET NULL,
  stazione_arrivo BIGSERIAL REFERENCES stazione(codice) ON DELETE SET NULL,
  azienda VARCHAR(64) NOT NULL,
  CHECK(stazione_partenza <> stazione_arrivo)
);

\echo '\nCreo la tabella percorso...'
CREATE TABLE percorso (
  treno BIGSERIAL REFERENCES treno(codice) ON DELETE CASCADE,
  citta dom_citta REFERENCES citta(nome) ON DELETE CASCADE,
  PRIMARY KEY(treno, citta)
);

\echo '\nPopolazione...'
-- （3） La terza per popolare opportunamente lo schema generato （con poche tuple per tabella）. 
\COPY citta FROM './dati_popolamento/citta.txt' (DELIMITER '|');


-- POPOLAZIONE STAZIONE 
\COPY stazione (nome, citta, categoria) FROM './dati_popolamento/stazioni.txt' (DELIMITER '|');


-- POPOLAZIONE TRENO 
\COPY treno (orario_partenza, orario_arrivo, stazione_partenza, stazione_arrivo, azienda) FROM './dati_popolamento/treni.txt' (DELIMITER '|');


\COPY percorso FROM './dati_popolamento/percorsi.txt' (DELIMITER '|');


-- （1） Determinare i treni che arrivano in una stazione situata a Perugia oppure partono da una stazione di Roma.
\echo '\nTreni che arrivano in una stazione situata a Perugia oppure partono da una stazione di Roma:'
SELECT
  *
FROM
  treno
WHERE
  stazione_arrivo IN (
    SELECT
      codice
    FROM
      stazione
    WHERE
      citta = 'Perugia'
  )
  OR stazione_partenza IN (
    SELECT
      codice
    FROM
      stazione
    WHERE
      citta = 'Roma'
  );


-- （2） Determinare i treni che non partono da una stazione di Bologna.
\echo '\nTreni che non partono da una stazione di Bologna:'
SELECT
  *
FROM
  treno
WHERE
  stazione_partenza NOT IN (
    SELECT
      codice AS codice
    FROM
      stazione
    WHERE
      citta = 'Bologna'
  );


-- （3） Determinare le aziende ferroviarie che hanno un treno IN partenza da ogni stazione memorizzato nella BD.
\echo '\nAziende che hanno un treno in partenza da ogni stazione:'
SELECT
  azienda
FROM
  treno
GROUP BY
  azienda
HAVING
  COUNT (DISTINCT stazione_partenza) = (
    SELECT
      COUNT (stazione.codice)
    FROM
      stazione
  );


-- Esercizio 3.Dopo aver aggiunto alla relazione Citta l ’ attributo numStazioni relativo al numero di stazioni della relativa citta ’ si definisca un trigger per l ’ aggiornare automatico di tale attributo. 
\echo '\nAggiungo la colonna \'num_stazioni\' alla tabella citta...'
ALTER TABLE
  citta
ADD
  num_stazioni INT DEFAULT 0;

\echo '\nCreo funzione \'update_num()\' per il trigger su stazione...'
CREATE
OR REPLACE FUNCTION update_num() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$ BEGIN
  IF (TG_OP = 'DELETE') THEN
  UPDATE
    citta
  SET
    num_stazioni = (
      SELECT
        COUNT(*)
      FROM
        stazione
      WHERE
        OLD .citta = stazione.citta
    )
  WHERE
    OLD .Citta = Citta.nome;
RETURN OLD;
END IF;
UPDATE
  citta
SET
  num_stazioni = (
    SELECT
      COUNT(*)
    FROM
      stazione
    WHERE
      NEW .citta = stazione.citta
  )
WHERE
  NEW .citta = citta.nome;
RETURN NEW;
END;
$$;


--creazione trigger
\echo '\nCreo trigger per aggiornare citta.num_stazioni...'
CREATE TRIGGER aggiorna_numStazioni AFTER
UPDATE
  OR
INSERT
  OR
DELETE
  ON stazione FOR EACH ROW EXECUTE PROCEDURE update_num();


/* 
Aggiorno i valori dell'attributo num_stazioni di tutte le tuple.
Non aggiornandolo adesso, una SELECT su citta, ritornerebbe tuple con num_stazione = default,
poichè il TRIGGER usato per aggiornare il valore num_stazioni di una specifica citta, 
potrebbe non essere ancora stato invocato.   
*/
\echo '\nAggiorno i valori di num_stazione di tutte le citta...'
UPDATE
  citta
SET
  num_stazioni = (
    SELECT
      COUNT(*)
    FROM
      stazione
    WHERE
      citta.nome = stazione.citta
  );