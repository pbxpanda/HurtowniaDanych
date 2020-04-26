USE master

GO

DROP DATABASE IF EXISTS HurtowniaWinaOLAP

GO 

CREATE DATABASE HurtowniaWinaOLAP

GO

USE HurtowniaWinaOLAP

GO

CREATE TABLE DIM_Daty (

				IDDaty INT PRIMARY KEY IDENTITY(1,1),

				Data DATE NOT NULL,

				Rok AS DATEPART(YEAR, Data),

				Kwartal AS DATEPART(QUARTER, Data),

				Miesiac AS DATEPART(MONTH, Data),

				Tydzien AS DATEPART(WEEK, Data),

				Dzien AS DATEPART(DAY, Data),

				DzienTygodnia AS DATEPART(WEEKDAY, Data),

				NazwaMiesiaca AS DATENAME(MONTH, Data),

				NazwaDniaTygodnia AS DATENAME(WEEKDAY, Data)

)

CREATE TABLE DIM_Adresy (

			   IDAdres INT PRIMARY KEY IDENTITY(1,1),

               Ulica NVARCHAR(200) NOT NULL,

               NumerDomu INT NOT NULL,

               NumerMieszkania INT NOT NULL,

               KodPocztowy NVARCHAR(20) NOT NULL,

               Miasto NVARCHAR(200) NOT NULL
)

CREATE TABLE DIM_Klient (

               IDKlienta INT PRIMARY KEY IDENTITY(1,1),

               Imie NVARCHAR(200) NOT NULL,

               Nazwisko NVARCHAR(200) NOT NULL,

			   IDDatyUrodzenia INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL,

               PESEL VARCHAR(11) NOT NULL,

			   IDAdres INT FOREIGN KEY REFERENCES DIM_Adresy(IDAdres) NOT NULL, 

               NumerTelefonu VARCHAR(9) NOT NULL,

               CzyKobieta BIT NOT NULL,

               IDDatyZarejestrowania INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL

)

CREATE TABLE DIM_Stanowisko (

               IDStanowiska INT PRIMARY KEY IDENTITY(1,1),

               Stanowisko NVARCHAR(200) NOT NULL,

)

CREATE TABLE DIM_Umowa (

               IDUmowa INT PRIMARY KEY IDENTITY(1,1),

               RodzajUmowy NVARCHAR(200) NOT NULL,

)

CREATE TABLE DIM_Pracownik (

               IDPracownika INT PRIMARY KEY IDENTITY(1,1),

               Imie NVARCHAR(200) NOT NULL,

               Nazwisko NVARCHAR(200) NOT NULL,

			   IDDatyUrodzenia INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL,

               PESEL CHAR(11) NOT NULL,

               IDAdres INT FOREIGN KEY REFERENCES DIM_Adresy(IDAdres) NOT NULL,

               Pensja MONEY NOT NULL,

               IDUmowa INT FOREIGN KEY REFERENCES DIM_Umowa(IDUmowa) NOT NULL,

               IDStanowiska INT FOREIGN KEY REFERENCES DIM_Stanowisko(IDStanowiska) NOT NULL,

               CzyKobieta BIT NOT NULL,

               IDDatyRozpoczeciaPracy INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL

)

CREATE TABLE DIM_Plantacja (

               IDPlantacji INT PRIMARY KEY IDENTITY(1,1),

               Nazwa NVARCHAR(200) NOT NULL

)

CREATE TABLE DIM_Rodzaj (

               IDRodzaj INT PRIMARY KEY IDENTITY(1,1),

               Rodzaj NVARCHAR(200) NOT NULL

)

CREATE TABLE DIM_KrajPochodzenia (

               IDKrajPochodzenia INT PRIMARY KEY IDENTITY(1,1),

               KrajPochodzenia VARCHAR(200) NOT NULL

)

CREATE TABLE DIM_Wino (

               IDWina INT PRIMARY KEY IDENTITY(1,1),

               Nazwa NVARCHAR(200) NOT NULL,

               IDRodzaj INT FOREIGN KEY REFERENCES DIM_Rodzaj(IDRodzaj) NOT NULL,

               IDKrajPochodzenia INT FOREIGN KEY REFERENCES DIM_KrajPochodzenia(IDKrajPochodzenia) NOT NULL,

               Rocznik INT NOT NULL,

               Cena MONEY NOT NULL,

               WartoscNetto MONEY NOT NULL,

               StawkaVAT INT NOT NULL,

               IDPlantacji INT FOREIGN KEY REFERENCES DIM_Plantacja(IDPlantacji) NOT NULL

)

CREATE TABLE DIM_StanZamowienia (

               IDStanZamowienia INT PRIMARY KEY IDENTITY(1,1),

               StanZamowienia NVARCHAR(200) NOT NULL

)

CREATE TABLE FACT_ZamowienieHDR (

               IDZamowienia INT PRIMARY KEY IDENTITY(1,1),

               IDKlienta INT FOREIGN KEY REFERENCES DIM_Klient(IDKlienta) NOT NULL,

               IDPracownika INT FOREIGN KEY REFERENCES DIM_Pracownik(IDPracownika) NOT NULL,

               IDDatyZlozeniaZamowienia INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL,

               IDDatyWysylki INT FOREIGN KEY REFERENCES DIM_Daty(IDDaty) NOT NULL,

               IDStanZamowienia INT FOREIGN KEY REFERENCES DIM_StanZamowienia(IDStanZamowienia) NOT NULL,

			   Cena MONEY NULL,

			   Faktura NVARCHAR(100) NOT NULL
)

CREATE TABLE DIM_ZamowienieDetale (

               IDZamowieniaDetale INT PRIMARY KEY IDENTITY(1,1),

               IDZamowienia INT FOREIGN KEY REFERENCES FACT_ZamowienieHDR(IDZamowienia) NOT NULL,

               IDWina INT FOREIGN KEY REFERENCES DIM_Wino(IDWina) NOT NULL,

               Ilosc INT NOT NULL,

			   Cena MONEY NOT NULL,
)