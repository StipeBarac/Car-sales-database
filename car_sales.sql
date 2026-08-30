-- =====================================================================
--  CAR SALES DATABASE  (Prodaja automobila)
--  PostgreSQL schema + sample data
--
--  Kako pokrenuti:
--    1) createdb -U postgres car_sales_db
--    2) psql -U postgres -d car_sales_db -f car_sales.sql
--  ili u pgAdmin / psql-u:  \i 'path/to/car_sales.sql'
--
--  Testirano na PostgreSQL 16+ (radi i na 17).
-- =====================================================================

-- Cist pocetak (ako vec postoje) -------------------------------------
DROP TABLE IF EXISTS rezervacija, reklamacija, automobil, racun, kupac, zaposlenik CASCADE;

-- =====================================================================
--  TABLICE
-- =====================================================================

CREATE TABLE zaposlenik (
    oib          char(11)     PRIMARY KEY,
    ime          varchar(50),
    prezime      varchar(50),
    adresa       text,
    kontakt_broj varchar(20)
);

CREATE TABLE kupac (
    oib          char(11)     PRIMARY KEY,
    ime          varchar(50),
    prezime      varchar(50),
    adresa       text,
    kontakt_broj varchar(20)
);

CREATE TABLE racun (
    id              serial      PRIMARY KEY,
    datum           date,
    oib_zaposlenika char(11),
    oib_kupca       char(11)
);

CREATE TABLE automobil (
    broj_sasije        varchar(20)   PRIMARY KEY,
    marka              varchar(50),
    model              varchar(50),
    godina_proizvodnje integer,
    oprema             text,
    boja               varchar(30),
    cijena             numeric(10,2),
    stanje_na_skladistu text,
    datum_dolaska      date,
    oib_zaposlenika    char(11),
    id_racun           integer,
    CONSTRAINT automobil_stanje_check
        CHECK (stanje_na_skladistu IN ('dostupan','prodan')),
    CONSTRAINT automobil_prodan_check
        CHECK ( (stanje_na_skladistu = 'dostupan' AND id_racun IS NULL)
             OR (stanje_na_skladistu = 'prodan'   AND id_racun IS NOT NULL) )
);

CREATE TABLE reklamacija (
    sifra_reklamacije  serial      PRIMARY KEY,
    opis_problema      text,
    datum_reklamacije  date,
    status_reklamacije varchar(50),
    broj_sasije        varchar(20),
    oib_kupca          char(11)
);

CREATE TABLE rezervacija (
    sifra_rezervacije serial      PRIMARY KEY,
    datum_rezervacije date,
    datum_preuzimanja date,
    broj_sasije       varchar(20),
    oib_kupca         char(11)
);

-- =====================================================================
--  PODACI
-- =====================================================================

INSERT INTO zaposlenik (oib, ime, prezime, adresa, kontakt_broj) VALUES
    ('12345678901', 'Marko', 'Marić', 'Ulica bana Jelačića 5, 42000 Varaždin', '0911111111'),
    ('23456789012', 'Ana', 'Anić', 'Matije Gupca 22, 47000 Karlovac', '0922222222'),
    ('34567890123', 'Ivan', 'Ivić', 'Istarska ulica 9, 52100 Pula', '0933333333'),
    ('45678901234', 'Petra', 'Petrović', 'Franje Tuđmana 17, 35000 Slavonski Brod', '0964444444'),
    ('56789012345', 'Luka', 'Lukić', 'Kneza Domagoja 3, 44000 Sisak', '0995555555');

INSERT INTO kupac (oib, ime, prezime, adresa, kontakt_broj) VALUES
    ('11111111111', 'Josip', 'Jozić', 'Ulica kralja Tomislava 14, 10000 Zagreb', '0910000000'),
    ('22222222222', 'Maja', 'Majstorović', 'Ante Starčevića 8, 21000 Split', '0920000000'),
    ('33333333333', 'Karlo', 'Kovač', 'Vukovarska cesta 102, 31000 Osijek', '0930000000'),
    ('44444444444', 'Iva', 'Ivanković', 'Riva 3, 51000 Rijeka', '0960000000'),
    ('55555555555', 'Nikola', 'Novak', 'Put Murvice 12, 23000 Zadar', '0990000000');

INSERT INTO racun (id, datum, oib_zaposlenika, oib_kupca) VALUES
    ('1', '2023-01-10', '12345678901', '11111111111'),
    ('2', '2024-02-15', '23456789012', '22222222222'),
    ('3', '2022-03-20', '34567890123', '33333333333'),
    ('4', '2025-04-25', '45678901234', '44444444444'),
    ('5', '2025-05-30', '56789012345', '55555555555');

INSERT INTO automobil (broj_sasije, marka, model, godina_proizvodnje, oprema, boja, cijena, stanje_na_skladistu, datum_dolaska, oib_zaposlenika, id_racun) VALUES
    ('SAS123456A', 'Toyota', 'Corolla', '2022', 'Standard', 'Crvena', '18000.00', 'dostupan', '2024-01-05', '12345678901', NULL),
    ('SAS223456B', 'VW', 'Golf', '2023', 'Comfort', 'Siva', '22000.00', 'prodan', '2024-02-10', '23456789012', '2'),
    ('SAS323456C', 'Ford', 'Focus', '2021', 'Trend', 'Plava', '16000.00', 'dostupan', '2024-03-12', '34567890123', NULL),
    ('SAS423456D', 'BMW', '320d', '2020', 'Sport', 'Crna', '30000.00', 'prodan', '2024-04-18', '45678901234', '1'),
    ('SAS523456E', 'Audi', 'A4', '2022', 'Luxury', 'Bijela', '35000.00', 'prodan', '2024-05-22', '56789012345', '5');

INSERT INTO reklamacija (sifra_reklamacije, opis_problema, datum_reklamacije, status_reklamacije, broj_sasije, oib_kupca) VALUES
    ('1', 'Problem s motorom', '2024-06-01', 'otvorena', 'SAS223456B', '22222222222'),
    ('2', 'Kvar na klimi', '2024-06-02', 'zatvorena', 'SAS523456E', '55555555555'),
    ('3', 'Udaren', '2024-06-03', 'u obradi', 'SAS223456B', '22222222222'),
    ('4', 'Ne radi senzor', '2024-06-04', 'otvorena', 'SAS523456E', '55555555555'),
    ('5', 'Problem s brisačima', '2024-06-05', 'zatvorena', 'SAS223456B', '22222222222');

INSERT INTO rezervacija (sifra_rezervacije, datum_rezervacije, datum_preuzimanja, broj_sasije, oib_kupca) VALUES
    ('1', '2024-06-10', '2024-06-15', 'SAS123456A', '11111111111'),
    ('2', '2024-06-11', '2024-06-16', 'SAS323456C', '33333333333'),
    ('3', '2024-06-12', '2024-06-17', 'SAS423456D', '44444444444'),
    ('4', '2024-06-13', '2024-06-18', 'SAS123456A', '11111111111'),
    ('5', '2024-06-14', '2024-06-19', 'SAS323456C', '33333333333');

-- Sinkroniziraj serial sekvence s najvecim ID-em
SELECT setval('racun_id_seq', (SELECT max(id) FROM racun));
SELECT setval('reklamacija_sifra_reklamacije_seq', (SELECT max(sifra_reklamacije) FROM reklamacija));
SELECT setval('rezervacija_sifra_rezervacije_seq', (SELECT max(sifra_rezervacije) FROM rezervacija));

-- =====================================================================
--  STRANI KLJUCEVI (veze medu tablicama)
-- =====================================================================

ALTER TABLE racun
    ADD CONSTRAINT racun_zaposlenik_fk FOREIGN KEY (oib_zaposlenika) REFERENCES zaposlenik(oib),
    ADD CONSTRAINT racun_kupac_fk      FOREIGN KEY (oib_kupca)       REFERENCES kupac(oib);

ALTER TABLE automobil
    ADD CONSTRAINT automobil_zaposlenik_fk FOREIGN KEY (oib_zaposlenika) REFERENCES zaposlenik(oib),
    ADD CONSTRAINT automobil_racun_fk      FOREIGN KEY (id_racun)        REFERENCES racun(id);

ALTER TABLE reklamacija
    ADD CONSTRAINT reklamacija_automobil_fk FOREIGN KEY (broj_sasije) REFERENCES automobil(broj_sasije),
    ADD CONSTRAINT reklamacija_kupac_fk     FOREIGN KEY (oib_kupca)   REFERENCES kupac(oib);

ALTER TABLE rezervacija
    ADD CONSTRAINT rezervacija_automobil_fk FOREIGN KEY (broj_sasije) REFERENCES automobil(broj_sasije),
    ADD CONSTRAINT rezervacija_kupac_fk     FOREIGN KEY (oib_kupca)   REFERENCES kupac(oib);
