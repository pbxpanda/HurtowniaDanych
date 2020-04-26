USE master

GO

DROP DATABASE IF EXISTS HurtowniaWina

GO 

CREATE DATABASE HurtowniaWina

GO

USE HurtowniaWina

GO

CREATE TABLE Adresy (

			   IDAdres INT PRIMARY KEY IDENTITY(1,1),

               Ulica NVARCHAR(200) NOT NULL,

               NumerDomu INT NOT NULL,

               NumerMieszkania INT NOT NULL,

               KodPocztowy NVARCHAR(20) NOT NULL,

               Miasto NVARCHAR(200) NOT NULL
)

CREATE TABLE Klient (

               IDKlienta INT PRIMARY KEY IDENTITY(1,1),

               Imie NVARCHAR(200) NOT NULL,

               Nazwisko NVARCHAR(200) NOT NULL,

			   DataUrodzenia DATE NOT NULL,

               PESEL CHAR(11) NOT NULL UNIQUE,

			   IDAdres INT FOREIGN KEY REFERENCES Adresy(IDAdres) NOT NULL, 

               NumerTelefonu VARCHAR(9) NOT NULL,

               CzyKobieta BIT NOT NULL,

               DataZarejestrowania DATE NOT NULL

)

CREATE TABLE Stanowisko (

               IDStanowiska INT PRIMARY KEY IDENTITY(1,1),

               Stanowisko NVARCHAR(200) NOT NULL UNIQUE,

)

CREATE TABLE Umowa (

               IDUmowa INT PRIMARY KEY IDENTITY(1,1),

               RodzajUmowy NVARCHAR(200) NOT NULL UNIQUE,

)

CREATE TABLE Pracownik (

               IDPracownika INT PRIMARY KEY IDENTITY(1,1),

               Imie NVARCHAR(200) NOT NULL,

               Nazwisko NVARCHAR(200) NOT NULL,

			   DataUrodzenia DATE NOT NULL,

               PESEL CHAR(11) NOT NULL UNIQUE,

               IDAdres INT FOREIGN KEY REFERENCES Adresy(IDAdres) NOT NULL,

               Pensja MONEY NOT NULL,

               IDUmowa INT FOREIGN KEY REFERENCES Umowa(IDUmowa) NOT NULL,

               IDStanowiska INT FOREIGN KEY REFERENCES Stanowisko(IDStanowiska) NOT NULL,

               CzyKobieta BIT NOT NULL,

               DataRozpoczeciaPracy DATE NOT NULL

)

  

 

CREATE TABLE Plantacja (

               IDPlantacji INT PRIMARY KEY IDENTITY(1,1),

               Nazwa NVARCHAR(200) NOT NULL UNIQUE

)

CREATE TABLE Rodzaj (

               IDRodzaj INT PRIMARY KEY IDENTITY(1,1),

               Rodzaj NVARCHAR(200) NOT NULL UNIQUE

)

CREATE TABLE KrajPochodzenia (

               IDKrajPochodzenia INT PRIMARY KEY IDENTITY(1,1),

               KrajPochodzenia VARCHAR(200) NOT NULL UNIQUE

)

CREATE TABLE Wino (

               IDWina INT PRIMARY KEY IDENTITY(1,1),

               Nazwa NVARCHAR(200) NOT NULL UNIQUE,

               IDRodzaj INT FOREIGN KEY REFERENCES Rodzaj(IDRodzaj) NOT NULL,

               IDKrajPochodzenia INT FOREIGN KEY REFERENCES KrajPochodzenia(IDKrajPochodzenia) NOT NULL,

               Rocznik INT NOT NULL,

               Cena MONEY NOT NULL,

               WartoscNetto MONEY NOT NULL,

               StawkaVAT INT NOT NULL,

               IDPlantacji INT FOREIGN KEY REFERENCES Plantacja(IDPlantacji) NOT NULL

)

 

CREATE TABLE StanZamowienia (

               IDStanZamowienia INT PRIMARY KEY IDENTITY(1,1),

               StanZamowienia NVARCHAR(200) NOT NULL UNIQUE

)

 

CREATE TABLE ZamowienieHDR (

               IDZamowienia INT PRIMARY KEY IDENTITY(1,1),

               IDKlienta INT FOREIGN KEY REFERENCES Klient(IDKlienta) NOT NULL,

               IDPracownika INT FOREIGN KEY REFERENCES Pracownik(IDPracownika) NOT NULL,

               DataZlozeniaZamowienia DATE NOT NULL,

               DataWysylki DATE NOT NULL,

               IDStanZamowienia INT FOREIGN KEY REFERENCES StanZamowienia(IDStanZamowienia) NOT NULL
)

 

CREATE TABLE ZamowienieDetale (

               IDZamowieniaDetale INT PRIMARY KEY IDENTITY(1,1),

               IDZamowienia INT FOREIGN KEY REFERENCES ZamowienieHDR(IDZamowienia) NOT NULL,

               IDWina INT FOREIGN KEY REFERENCES Wino(IDWina) NOT NULL,

               Ilosc INT NOT NULL

)

GO

CREATE FUNCTION dbo.Podlicz(@IDZamowieniaDetale INT)
RETURNS MONEY
AS

BEGIN

	DECLARE @cena MONEY = (
		SELECT Ilosc * W.Cena
		FROM ZamowienieDetale AS ZD JOIN Wino AS W ON ZD.IDWina = W.IDWina
		WHERE IDZamowieniaDetale = @IDZamowieniaDetale
	)

	RETURN @cena

END

GO

ALTER TABLE ZamowienieDetale
ADD Cena AS dbo.Podlicz(IDZamowieniaDetale)

GO

CREATE FUNCTION dbo.Sumuj(@IDZamowienia INT)
RETURNS MONEY
AS

BEGIN

	DECLARE @cena MONEY = (
		SELECT SUM(Cena)
		FROM ZamowienieDetale
		WHERE IDZamowienia = @IDZamowienia
		GROUP BY IDZamowienia
	)

	RETURN @cena

END

GO

ALTER TABLE ZamowienieHDR
ADD Cena AS dbo.Sumuj(IDZamowienia)

GO

ALTER TABLE ZamowienieHDR
ADD Faktura AS 'FVAT_' + RIGHT('0000000000' + CAST(IDZamowienia AS VARCHAR(10)), 10) + '_' + FORMAT(DataWysylki, 'yyyyMMdd')