CREATE DATABASE planetsdatabase
GO

USE planetsdatabase
GO

CREATE TABLE star_type
(
    class           varchar NOT NULL PRIMARY KEY,
    min_temperature int,
    max_temperature int,
    CONSTRAINT check_temperature CHECK (min_temperature < max_temperature),
    mean_density    float,
)
GO

CREATE TABLE stellar
(
    stellar_name      varchar(32) NOT NULL PRIMARY KEY,
    temperature       int         NOT NULL,
    mass              float,
    age               float       NOT NULL,
    distance_to_sun   float,
    radius            float,
    density           float,
    date_of_discovery date,
    class             varchar FOREIGN KEY REFERENCES star_type (class)
)
GO

CREATE TABLE planets_types
(
    planet_type_id int IDENTITY (1,1) PRIMARY KEY,
    type           varchar(16),
    size           varchar(16)
)
GO

CREATE TABLE observatories
(
    observatory_id     int IDENTITY (1, 1) PRIMARY KEY,
    discovery_facility varchar(32),
    method             varchar(32)
)
GO

CREATE TABLE planets
(
    planet_name       varchar(32)        NOT NULL PRIMARY KEY,
    mass              float,
    semi_major_axis   float,
    orbital_period    float,
    eccentricity      float,
    date_of_discovery date,
    radius            float,
    is_dwarf          bit
        CONSTRAINT df_is_dwarf DEFAULT 0 NOT NULL,
    stellar_name      varchar(32) FOREIGN KEY REFERENCES stellar (stellar_name),
    planet_type_id    int FOREIGN KEY REFERENCES planets_types (planet_type_id),
    observatory_id    int FOREIGN KEY REFERENCES observatories (observatory_id)
)
GO

CREATE TABLE unconfirmed_planets
(
    planet_name       varchar(32)           NOT NULL PRIMARY KEY,
    mass              float,
    semi_major_axis   float,
    orbital_period    float,
    eccentricity      float,
    date_of_discovery date,
    radius            float,
    is_dwarf          bit
        CONSTRAINT df_is_dwarf_un DEFAULT 0 NOT NULL,
    stellar_name      varchar(32) FOREIGN KEY REFERENCES stellar (stellar_name),
    planet_type_id    int FOREIGN KEY REFERENCES planets_types (planet_type_id),
    observatory_id    int FOREIGN KEY REFERENCES observatories (observatory_id)
)
GO

CREATE TABLE moons
(
    moon_name         varchar(32) NOT NULL PRIMARY KEY,
    mass              float,
    semi_major_axis   float,
    orbital_period    float,
    eccentricity      float,
    date_of_discovery date,
    radius            float,
    planet_name       varchar(32) FOREIGN KEY REFERENCES planets (planet_name)
)
GO