# progetto-basi-di-dati

NOME: Davide Maria
COGNOME: Mantione
MATRICOLA: 303391

VERSIONE PSQL UTILIZZATA: psql (14.0 (Ubuntu 14.0-1.pgdg20.04+1), server 13.4 (Ubuntu 13.4-4.pgdg20.04+1))

Lo script 'script_esame.sql' se passato come FILE nel comando \i di psql,
dovrebbe eseguire in automatico i diversi punti del progetto senza interruzioni,
restituendo a schermo i risultati delle operazioni oggetto degli esercizi. 


PROGETTO: 1111
    Esercizio 1. Si consideri il seguente schema relazionale:
            • Treno(codice, orario partenza, stazione partenza, orario arrivo, stazione arrivo,
            azienda)
            • Stazione(codice, nome, categoria, citta’ )
            • Citta(nome, numero abitanti, nazione)
            • Percorso (treno, citta)
    Si definisca uno script SQL per la generazione e la popolazione di uno schema voli
    che implementa lo schema relazionale proposto. Tale script dovra’ essere composto
    da 3 parti principali:
            (1) La prima, per cancellare schemi e tabelle omonime eventualmente presenti
            nella base di dati.
            (2) La seconda per generare lo schema definendo vincoli opportuni.
            (3) La terza, per popolare opportunamente lo schema generato (con poche tuple
            per tabella).
    Esercizio 2. Si estenda lo script SQL creato al punto precedente al fine di eseguire
    le seguenti interrogazioni:
            (1) Determinare i treni che arrivano in una stazione situata a Perugia oppure
            partono da una stazione di Roma.
            (2) Determinare i treni che non partono da una stazione di Bologna.
            (3) Determinare le aziende ferroviarie che hanno un treno in partenza da ogni
            stazione memorizzato nella BD.
    Esercizio 3. Dopo aver aggiunto alla relazione Citta l’attributo numStazioni rela-
    tivo al numero di stazioni della relativa citta’, si definisca un trigger per l’aggiornare
    automatico di tale attributo.
