USE planetsdatabase
GO

-- Zapytanie 1
-- Zapytanie pozwalające sprawdzić czy planet w bazie na pewno są planetami, sprawdzając
-- czy orbita jest okręgiem lub elipsą.
SELECT planet_name,
       IIF(0 <= eccentricity AND eccentricity < 0.01, 'circle',
           IIF(eccentricity < 1, 'ellipse', 'parabola')) AS 'orbit is ellipse'
FROM planets
WHERE eccentricity IS NOT NULL
GO

-- Zapytanie 2
-- Gwiazdy mają swoje specialne oznaczenia, u nas przedstawione jako star_type. Przedstawia jedną z głównych zależności,
-- mianowicie zależność od temperatury. Mimo wszystko czasami typ planety może nie być możliwy do rozpoznania wyłącznie
-- po temperaturze, dlatego warto, byłoby mieć pokazane gwiazdy, które mogły zostać niewłaściwie skatalogowanie
SELECT stellar_name, temperature, CONCAT(min_temperature, '-', max_temperature) AS 'zakres temperatur'
FROM stellar s,
     star_type st
WHERE st.class = s.class
  AND (min_temperature > temperature OR max_temperature < temperature)
GO

-- może się również zdarzyć, że dany typ gwiazdy nie ma ustawionej minimalnej i maksymalnej temperatury, zdarza się to
-- w sytuacji 'wyjątkowych gwiazd'. Przykładowo gwiazda Sirius B jest białym karłem, co odpowiada oznaczeniu D, a jej
-- temperatura wskazywałaby na klase inną, poniżej przykład (ciąg dalszy niżej):
SELECT stellar_name, temperature, mass, radius, s.class, st.class AS 'klasa na podstawie temperatury'
FROM stellar s,
     star_type st
WHERE stellar_name = 'Sirius B'
  AND min_temperature <= temperature
  AND temperature <= max_temperature
GO

-- Funkcja 1
-- cd.: w takiej sytuacji warto byłoby dodatkowo sprawdzić gęstość, ponieważ wysoka gęstość wskazuję
-- na gwiazde zdegenerowaną (białego karła, gwiazde neutronową, czarną dziure)
CREATE OR ALTER FUNCTION compute_density_for_star(@radius float, @mass float)
    RETURNS float
AS
BEGIN
    DECLARE @density_sun_units float = @mass / (4 * PI() * POWER(@radius, 3) / 3);
    RETURN @density_sun_units * 1405.89
END
GO

-- Ponownie wywołujemy nasze zapytanie, ale tak żeby zobaczyć gęstość (zdajemy sobie sprawę, że to wywołanie
-- nie liczy się za 2, ale chcieliśmy tak zrobić, żeby proces myślowy był lepiej widoczny
SELECT stellar_name,
       temperature,
       IIF(density IS NULL, dbo.compute_density_for_star(radius, mass), density) AS 'density',
       s.class,
       st.class                                                                  AS 'class by stellar temperature'
FROM stellar s,
     star_type st
WHERE st.min_temperature <= temperature
  AND temperature <= st.max_temperature
ORDER BY density DESC
GO

-- Procedura 1
-- żeby nie liczyć za każdym razem gęstości możemy uzupełnić ją wszędzie tam gdzie nie jest podana,
-- robię to w procedurze, ponieważ, teraz wystarczy po dodaniu nowych rekordów wywołać ją.
CREATE OR ALTER PROCEDURE correct_density AS
UPDATE stellar
SET density = dbo.compute_density_for_star(radius, mass)
WHERE density IS NULL
GO

EXEC correct_density;
GO

-- Zapytanie 3
-- Teraz możemy ostatecznie ustalić czy gwiazda ma przyporządkowaną odpowiednią klase
SELECT s.stellar_name,
       s.temperature,
       s.density,
       s.class,
       IIF(max_temperature IS NULL AND min_temperature IS NULL, '',
           CONCAT(min_temperature, '-', max_temperature)) 'temperature_range_for_class',
       mean_density                                       'mean_density_for_class'
FROM stellar s,
     star_type st
WHERE s.class = st.class
-- Można tutaj odnieśc wrażenie, że nadal nie jest to dobre przyporządkowanie, bo jakby nie patrzeć, gęstość dla danej
-- klasy, nie jest równa gęstości gwiazdy. Przy porównywaniu takich wielkości warto jest spojrzeć na rząd wielkości,
-- który powinien być +-1, więc przy takim założeniu się zgadza (oczywiście jeśli spojrzymy dla gwiazd mających klase D,
-- dla pozostałych klas nie są podane średnie gęstości

-- Zapytanie 4
-- Przydałoby się sprawdzić czy istnieje zależność między typem gwiazdy, a ilością planet w układzie
SELECT st.class, count(*)
FROM planets p,
     stellar s,
     star_type st
WHERE p.stellar_name = s.stellar_name
  AND s.class = st.class
GROUP BY st.class
GO

-- Funkcja 2
-- Podana funkcja pozwala ustalić w jakich odległościach od danej gwiazdy (na podstawie masy) istnieje woda w stanie
-- ciekłym
CREATE OR ALTER FUNCTION get_habitable_zone(@mass float, @round_to int = 2, @result_type bit = NULL) RETURNS float AS
BEGIN
    DECLARE @times float;

    SET @times = (CASE
                      WHEN @result_type IS NULL THEN 1
                      WHEN @result_type = 0 THEN 0.5
                      WHEN @result_type = 1 THEN 1.6
        END)
    RETURN IIF(@round_to IS NOT NULL, round(SQRT(POWER(@mass, 3.5)) * @times, @round_to),
               SQRT(POWER(@mass, 3.5)) * @times)
END
GO

-- Zapytanie dla funkcji
SELECT stellar_name,
       dbo.get_habitable_zone(mass, 3, 0)       min_distance,
       dbo.get_habitable_zone(mass, 3, DEFAULT) mean_distance,
       dbo.get_habitable_zone(mass, 3, 1)       max_distance
FROM stellar,
     star_type
WHERE stellar.class = star_type.class
  AND max_temperature IS NOT NULL
  AND min_temperature IS NOT NULL;
GO

-- Zapytanie 5
-- Poszukajmy planet zdatnych do życia, czyli takich które znajdują się w ekosferze
SELECT stellar.stellar_name, COUNT(planet_name) planets_with_fluid_water
FROM planets,
     stellar
WHERE planets.stellar_name = stellar.stellar_name
  AND dbo.get_habitable_zone(stellar.mass, 3, 0) <= semi_major_axis
  AND semi_major_axis <= dbo.get_habitable_zone(stellar.mass, 3, 1)
GROUP BY stellar.stellar_name
GO

-- Zapytanie 6
-- Które odkrycie pozasłoneczne było najstarsze (pierwsze) i które obserwatorium tego dokonało
SELECT TOP 1 WITH TIES planet_name, date_of_discovery, concat(discovery_facility, ' by ', method)
FROM planets p,
     observatories o
WHERE p.observatory_id = o.observatory_id
  AND date_of_discovery IS NOT NULL
  AND stellar_name != 'Sun'
ORDER BY date_of_discovery
GO

-- Zapytanie 7
-- Policzenie ile jest planet dla danych gwiazd
SELECT stellar.stellar_name, count(*)
FROM planets,
     stellar
WHERE planets.stellar_name = stellar.stellar_name
GROUP BY stellar.stellar_name
GO

-- Funkcja 3
-- Korzystajac z prawa stefana-boltzmana oraz przyjmując że mamy doczynienia z ciałem doskonale czarnym
-- możemy policzyć ilość wypromineniowanej energii w jednostce m2
CREATE OR ALTER FUNCTION compute_radiated_power(@temp float)
    RETURNS float
AS
BEGIN
    DECLARE @stefan_boltzmann_constant float = 5.67036713E-8
    RETURN POWER(@temp, 4) * @stefan_boltzmann_constant
END
GO

SELECT stellar_name, temperature, ROUND(dbo.compute_radiated_power(temperature), 0) 'radiated power [w/m2]'
FROM stellar
GO

-- Zapytanie 8
SELECT moon_name,
       round(moons.mass / (planets.mass * 5.97219E+24), 4) planet_mass_to_moons,
       is_dwarf                                            host_planet_is_dwarf
FROM moons,
     planets
WHERE planets.planet_name = moons.planet_name
ORDER BY planet_mass_to_moons DESC

-- Zapytanie 9
-- Z ciekawości można sprawdzić jaka jest ilość księżyców dla konkretnych gwiazd
SELECT stellar.stellar_name, SUM(@@rowcount) number_of_moons
FROM moons,
     planets,
     stellar,
     star_type
WHERE stellar.class = star_type.class
  AND planets.stellar_name = stellar.stellar_name
  AND moons.planet_name = planets.planet_name
GROUP BY stellar.stellar_name
-- jak widać jedyne księżyce jakie udało się zaobserwować są w naszym Układzie Słonecznym

-- Zapytanie 10
-- Wyświetlenie wszystkich gwiazd, które mają więcej (lub tyle samo) odkrytych planet co Słońce
SELECT stellar.stellar_name, count(planets.planet_name) planets_numbers
FROM stellar,
     planets
WHERE planets.stellar_name = stellar.stellar_name
GROUP BY stellar.stellar_name
HAVING count(planets.planet_name) >= (SELECT count(*) FROM planets WHERE stellar_name = 'Sun')
GO

-- Procedura 2
-- Gdy potwierdzimy na 100% istnienie planety możemy ją przenieść z planet niepwierdzonych, podając jej nazwę
CREATE OR ALTER PROCEDURE move_planet_to_confirmed(@planet_name varchar(32)) AS
BEGIN
    IF @planet_name IN (SELECT planet_name FROM planets)
        RETURN

    BEGIN TRANSACTION;
    INSERT INTO planets (planet_name, mass, semi_major_axis, orbital_period, eccentricity, date_of_discovery, radius,
                         is_dwarf, stellar_name, planet_type_id, observatory_id)
    SELECT planet_name,
           mass,
           semi_major_axis,
           orbital_period,
           eccentricity,
           date_of_discovery,
           radius,
           is_dwarf,
           stellar_name,
           planet_type_id,
           observatory_id
    FROM unconfirmed_planets
    WHERE unconfirmed_planets.planet_name = @planet_name;

    DELETE FROM unconfirmed_planets WHERE unconfirmed_planets.planet_name = @planet_name;
    COMMIT;
    RETURN;
END
GO

EXECUTE move_planet_to_confirmed 'Planet Nine'
GO

-- Zapytanie 11
-- Postać przyjaźniejsza do odczytywania
SELECT planet_name,
       p.mass              mass,
       semi_major_axis,
       orbital_period,
       eccentricity,
       p.date_of_discovery date_of_discovery,
       p.radius            radius,
       is_dwarf,
       CONCAT(pt.type, ' ', pt.size),
       o.discovery_facility,
       o.method,
       p.stellar_name,
       temperature         stellar_temperature,
       s.mass              stellar_mass,
       age                 stellar_age,
       distance_to_sun,
       s.radius            stellar_radius,
       density             stellar_density,
       s.date_of_discovery stellar_date_of_discovery,
       class               stellar_class
FROM planets p
         LEFT JOIN stellar s ON s.stellar_name = p.stellar_name
         LEFT JOIN observatories o ON p.observatory_id = o.observatory_id
         LEFT JOIN planets_types pt ON p.planet_type_id = pt.planet_type_id
GO

-- Zapytanie 12
-- Lista planet karłowatych które mają księżyce
SELECT planets.planet_name
FROM moons,
     planets
WHERE moons.planet_name = planets.planet_name
  AND is_dwarf = 1
GROUP BY planets.planet_name
GO

-- Funkcja do zapytania 13
CREATE OR ALTER FUNCTION get_magnitude_number(@num float)
    RETURNS int
AS
BEGIN
    RETURN CAST(ROUND(LOG10(@num), 0) AS int)
END
GO

-- Zapytanie 13
-- Na podstawie takiego zapytania możemy znaleźć gwiazdy neutronowe/białe karły, tam gdzie |diff| < 1.
SELECT stellar_name,
       IIF(density IS NOT NULL, dbo.get_magnitude_number(density),
           dbo.get_magnitude_number(dbo.compute_density_for_star(radius, mass))) -
       dbo.get_magnitude_number(mean_density) diff,
       star_type.class
FROM stellar,
     star_type
WHERE star_type.mean_density IS NOT NULL
  AND radius IS NOT NULL
  AND mass IS NOT NULL
ORDER BY abs(density - mean_density)

-- Zapytanie 14
-- Która metoda wykrywania egzoplanet jest najskuteczniejsza
SELECT method, count(planet_name) number_of_discoveries
FROM observatories,
     planets
WHERE planets.observatory_id = observatories.observatory_id
GROUP BY method
ORDER BY number_of_discoveries DESC
GO

-- Zapytanie 15
-- Sprawdzenie średniego promienia i średniej masy w zdobywaniu wiedzy czy exoplanety są podobne do ziemi.
-- Porównywanie tylko planet będących typu skalistego.
SELECT avg(radius), avg(mass)
FROM planets,
     planets_types
WHERE radius IS NOT NULL
  AND planets.planet_type_id = planets_types.planet_type_id
  AND type = 'terrestrial'
GO