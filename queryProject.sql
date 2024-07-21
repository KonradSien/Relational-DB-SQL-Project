--Założenia: 
--a)	Właściciel może mieć kilka zwierząt, ale nigdy więcej niż jedno zwierzę o pewnym imieniu. 
--b)	Pamiętamy informacje o szczepieniach zwierząt. 
--c)	Pojedyncze szczepienie przeprowadza jeden weterynarz. 
--d)	Plec, data_zatrudnienia, uwagi nie są wymagane, pozostałe informacje są wymagane. 
--e)	Wartości id_wlasciciela, id_zwierzecia,  id_weterynarza, id_szczepienia są generowane automatycznie. 

--1. Utwórz tabelę Szczepienia, uwzględniając założenia a)-e) i określając odpowiednie (sensowne) typy kolumn, przyjmując założenie, iż pozostałe tabele już istnieją.

CREATE TABLE Szczepienia(
	id_szczepienia INT IDENTITY PRIMARY KEY,
	data DATE NOT NULL,
	rodzaj VARCHAR(50) NOT NULL,
	cena DECIMAL(10,2) NOT NULL,  
	uwagi VARCHAR(200),
	id_zwierzecia FOREIGN KEY REFERENCES Zwierzeta id_zwierzecia NOT NULL,
	id_weterynarza FOREIGN KEY REFERENCES Weterynarze id_weterynarza NOT NULL
);

-- IDENTITY PRIMARY KEY  ustawia kolumnę jako klucz główny , którego wartości automatycznie się generują
-- FOREIGN KEY REFERENCES kolumna stanowi klucz obcy odwołujący się do klucza głównego podanej tabeli 

--2. Wprowadź zmianę w powyższym schemacie, odpowiadającą zmianie wymagań: „w systemie przechowujemy PESEL każdego weterynarza”.

ALTER TABLE Weterynarze ADD pesel CHAR(11);

--3.	Wprowadź do schematu bazy danych ograniczenie na maksymalną cenę szczepienia w wysokości 100,00 zł.

ALTER TABLE Szczepienia ADD CONSTRAINT cena_max CHECK (cena<=100);


--4.Zarejestruj w bazie danych nowego weterynarza oraz jedno szczepienie wykonane przez niego  (uwzględniając zmiany dokonane w zad. 1-3). 

INSERT INTO Weterynarze(imie, nazwisko, specjlizacja, pesel, data_zatrudnienia) 
VALUES('Wojciech','Wojeciechowski','Zwierzęta domowe','12345678912','10-10-2018')

INSERT INTO Szczepienia(data, rodzaj, cena, id_zwierzecia, id_weterynarza)
VALUES('07-04-2024','przeciw wsciekliznie',50,1,(SELECT MAX(id_weterynarza) from Weterynarze));

--5.Wypisz dane wszystkich zwierząt z gatunku ‘kot’. Uporządkuj wyniki wg imienia, a następnie wg daty urodzenia, począwszy od kotów najmłodszych.   

SELECT * FROM Zwierzeta
WHERE gatunek='kot'
ORDER BY imie, data_urodzenia DESC;


--6.Podaj imiona i nazwiska weterynarzy, którzy do tej pory przeprowadzili mniej niż 75 szczepień. Uporządkuj wyniki wg liczby szczepień, a następnie po nazwisku i imieniu weterynarza. 

SELECT imie, naziwsko from Weterynarze W
LEFT JOIN Szczepienia S on W.id_weterynarza=S.id_weterynarza  
GROUP BY imie, naziwsko
HAVING COUNT(id_szczepienia) < 75
ORDER BY COUNT(id_szczepienia),naziwsko,imie;

--7. Usuń informacje o szczepieniach zwierząt z gatunku ‘pies domowy’, które zostały wykonane przed 1 maja 2004 roku (sprzed wstąpienia Polski do UE).
DELETE FROM Szczepienia
WHERE id_szczepienia IN(
SELECT id_szczepienia from Szczepienia S INNER JOIN
Zwierzeta Z ON S.id_zwierzecia=Z.id_zwierzecia
WHERE data < '01-05-2004' AND gatunek='pies domowy'
);

--8.Zwiększ o 20 zł cenę szczepień, które są wykonywane przez weterynarzy ze specjalizacją ‘Choroby przeżuwaczy’. 

UPDATE Szczepienia 
SET cena=cena+20
WHERE id_weterynarza IN(
	SELECT id_weterynarza from Weterynarze
	WHERE specjalizacja='Choroby przeżuwaczy'
);

--Utwórz procedurę o nazwie wypisz_szczepienia, która zwraca datę i rodzaj dla wszystkich szczepień danego zwierzęcia. Parametrami tej procedury powinny być id_wlasciciela oraz imię zwierzęcia. Podaj przykładowe wywołanie tej procedury.

CREATE PROCEDURE wypisz_szczepienia
	@id_wlasciciela INT,
	@imie VARCHAR(50)
AS BEGIN 
	SELECT data, rodzaj FROM Szczepienia S
	INNER JOIN Zwierzeta Z ON S.id_zwierzecia=Z.id_zwierzecia
	WHERE id_wlasciciela=@id_wlasciciela AND imie=@imie
END;

EXECUTE wypisz_szczepienia 1,'Reksio'