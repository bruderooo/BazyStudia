use planetsdatabase
GO

-- Wyzwalacz 1
-- Jeśli dodany planete do planet niepotwierdzonych, ale wszystnie pola będą różne od null, czyli wiemy wszystko o planecie
-- a to znaczy że jest potwierdzona, więc zostaje przeniesiona do planet potwierdzonych
CREATE OR ALTER TRIGGER auto_confirm
    ON unconfirmed_planets
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @name varchar(32)
    DECLARE my_cursor CURSOR FOR SELECT DISTINCT planet_name
                                 FROM inserted
                                 WHERE mass IS NOT NULL
                                   AND semi_major_axis IS NOT NULL
                                   AND orbital_period IS NOT NULL
                                   AND eccentricity IS NOT NULL
                                   AND date_of_discovery IS NOT NULL
                                   AND radius IS NOT NULL
                                   AND stellar_name IS NOT NULL
                                   AND planet_type_id IS NOT NULL
                                   AND observatory_id IS NOT NULL
    OPEN my_cursor
    FETCH NEXT FROM my_cursor INTO @name
    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXECUTE move_planet_to_confirmed @name
            FETCH NEXT FROM my_cursor INTO @name
        END
    CLOSE my_cursor
    DEALLOCATE my_cursor
END
GO

UPDATE unconfirmed_planets
SET mass            = 2.3,
    semi_major_axis = 0.107,
    orbital_period  = 14.44912,
    eccentricity    = 0,
    radius          = 1.32,
    planet_type_id  = 1,
    observatory_id  = 17
WHERE planet_name = 'KOI-351 i'
GO

SELECT * FROM planets WHERE planet_name = 'KOI-351 i'
GO

SELECT * FROM unconfirmed_planets WHERE planet_name = 'KOI-351 i'
GO

-- Wyzwalacz 2
-- Jeśli dodana planeta nie ma podanej gwiazdy oraz nie ma podanego typu to jest oznaczana
-- jako planeta samotna.
CREATE OR ALTER TRIGGER alone_planet
    ON planets
    AFTER INSERT
    AS
BEGIN
    UPDATE planets
    SET planet_type_id = 5
    WHERE stellar_name IS NULL
      AND planet_type_id IS NULL
      AND planet_name IN (SELECT planet_name FROM inserted);
END
GO


INSERT INTO planets (planet_name)
VALUES ('alone planet :('),
       ('OGLE-2016-BLG-1928');
GO

SELECT * FROM planets WHERE planet_type_id = 5
GO


-- Wyzwalacz 3
-- niestety nie udało się żadnego fajnego wymyślić