USE planetsdatabase

INSERT INTO star_type (class, min_temperature, max_temperature)
VALUES ('O', 30000, 250000),
       ('B', 10500, 30000),
       ('A', 7500, 10500),
       ('F', 6000, 7500),
       ('G', 5500, 6000),
       ('K', 4000, 5500),
       ('M', 2600, 4000)
GO

INSERT INTO star_type (class, mean_density)
VALUES ('D', 1.0E+9)


INSERT INTO stellar (stellar_name, temperature, mass, age, distance_to_sun, radius, density, date_of_discovery, class)
VALUES ('Sun', 5772, 1, 4.6, 0, 1, 1405.89, NULL, 'G'),
       ('Proxima Centauri', 3042, 0.1221, 4.85, 4.2465, 0.1542, NULL, '1915', 'M'),
       ('Barnard''s Star', 3134, 0.144, 10, 5.9577, 0.196, NULL, '1916', 'M'),
       ('Sirius A', 9940, 2.063, 0.228, 8.6, 1.711, NULL, '1844', 'A'),
       ('Sirius B', 25000, 1.018, 0.228, 8.6, 0.0084, NULL, '1844', 'D'),
       ('Tau Ceti', 5344, 0.783, 5.8, 11.905, 0.793, NULL, '1603', 'G'),
       ('Kepler-107', 5854, 1.238, 4.29, 1713.959, NULL, NULL, NULL, 'G'),
       ('KOI-351', 6080, 1.2, 2, 2840, 1.2, NULL, NULL, 'G')
GO

INSERT INTO planets_types (type, size)
VALUES ('terrestrial', 'normal'),
       ('terrestrial', 'giant'), -- Super-ziemie
       ('gas', 'giant'),
       ('gas', 'dwarf'),
       ('rogue', 'normal')
GO

INSERT INTO observatories (discovery_facility, method)
VALUES ('KELT', 'transit'),
       ('UKIT', 'transit'),
       ('WASP', 'transit'),
       ('TrES', 'transit'),
       ('Qatar', 'transit'),
       ('Paranal Observatory', 'transit'),
       ('Kepler', 'transit'),
       ('XO', 'transit'),
       ('TESS', 'transit'),
       ('Multiple Observatories', 'transit'),
       ('HATNet', 'transit'),
       ('CoRoT', 'transit'),
       ('K2', 'transit'),
       ('Keck Observatory', 'radial velocity'),
       ('Las Campanas Observatory', 'radial velocity'),
       ('ESO', 'radial velocity'),
       ('Kepler', 'transit and deep learning')
GO

INSERT INTO planets (planet_name, mass, semi_major_axis, orbital_period, eccentricity, date_of_discovery, radius,
                     stellar_name, planet_type_id, observatory_id)
VALUES ('Earth', 1, 1, 365.25, 0.0167086, NULL, 1, 'Sun', 1, NULL),
       ('Mercury', 0.055, 0.3871, 87.97, 0.2056307, NULL, 0.3825, 'Sun', 1, NULL),
       ('Venus', 0.815, 0.7233, 224.701, 0.0067732, NULL, 0.9488, 'Sun', 1, NULL),
       ('Mars', 0.107, 1.5237, 686.98, 0.09341233, NULL, 0.53260, 'Sun', 1, NULL),
       ('Jupiter', 317.8, 5.2044, 4332.59, 0.0489, NULL, 10.517, 'Sun', 3, NULL),
       ('Saturn', 95.159, 9.5826, 10759.22, 0.0565, NULL, 9, 'Sun', 3, NULL),

       ('Kepler-107 b', 3.51, 0.0423, 3.18, 0, '2014', 1.536, 'Kepler-107', 1, 7),
       ('Kepler-107 c', 9.39, 0.0565, 4.90, 0, '2014', 1.597, 'Kepler-107', 1, 7),
       ('Kepler-107 d', 3.8, 0.078, 7.96, 0, '2014', 0.86, 'Kepler-107', 1, 7),
       ('Kepler-107 e', 8.6, 0.1177, 14.75, 0, '2014', 2.903, 'Kepler-107', 1, 7),

       ('Proxima Centauri b', 1.173, 0.04857, 11.184, 0.109, NULL, 1.15, 'Proxima Centauri', 1, 16),

       ('KOI-351 b', 2.27, 0.074, 7.008151, 0, '2013', 1.31, 'KOI-351', 1, 7),
       ('KOI-351 c', 1.81, 0.089, 8.719375, 0, '2013', 1.19, 'KOI-351', 1, 7),
       ('KOI-351 d', 8.6, 0.32, 59.73667, 0, '2013', 2.87, 'KOI-351', 2, 7),
       ('KOI-351 e', 7.56, 0.42, 91.93913, 0, '2013', 2.66, 'KOI-351', 2, 7),
       ('KOI-351 f', 8.65, 0.48, 124.9144, 0.01, '2013', 2.88, 'KOI-351', 2, 7),
       ('KOI-351 g', 254, 0.71, 210.60697, 0.049, '2013', 8.1, 'KOI-351', 3, 7),
       ('KOI-351 h', 381, 1.01, 331.60059, 0.011, '2013', 11.3, 'KOI-351', 3, 7)
GO

INSERT INTO planets (planet_name, mass, semi_major_axis, orbital_period, eccentricity, date_of_discovery, radius,
                     is_dwarf, stellar_name, planet_type_id, observatory_id)
VALUES ('Pluto', 0.00218, 39.482, 90.56, 0.2488, '1930', 0.1868, 1, 'Sun', 1, NULL)

INSERT INTO unconfirmed_planets (planet_name, stellar_name, date_of_discovery)
VALUES ('Planet Nine', 'Sun', NULL),
       ('KOI-351 i', 'KOI-351', '2017')
GO

INSERT INTO moons (moon_name, mass, semi_major_axis, orbital_period, eccentricity, date_of_discovery, radius,
                   planet_name)
VALUES ('Moon', 7.347E+22, 384403, 27.3, 0.055, NULL, 1737.5, 'Earth'),
       ('Phobos', 1.08E+16, 9377, 7.66, 0.0151, '1877-08-18', 11.1, 'Mars'),
       ('Deimos', 2E+15, 23460, 30.35, 0.00033, '1877-08-12', 6.3, 'Mars'),
       ('Ganymede', 14.82E+22, 1070400, 7.15, 0.0013, '1610-01-07', 2634.1, 'Jupiter'),
       ('Io', 8.9E+22, 421700, 1.77, 0.0041, '1610-01-08', 1821.5, 'Jupiter'),
       ('Europa', 4.8E+22, 671034, 3.55, 0.009, '1610-01-08', 1571, 'Jupiter'),
       ('Callisto', 10.8E+22, 1882709, 16.69, 0.0074, '1610-01-07', 2410.5, 'Jupiter'),
       ('Mimas', 4E+19, 185.539, 0.9, 0.0196, '1789-09-17', 198, 'Saturn'),
       ('Enceladus', 1.1E+20, 237.948, 1.4, 0.0047, '1789-08-28', 252, 'Saturn'),
       ('Tethys', 6.2E+20, 294619, 1.9, 0.0001, '1684-03-21', 531, 'Saturn'),
       ('Dione', 1E+21, 377396, 2.73, 0.0022, '1684-03-21', 561.5, 'Saturn'),
       ('Rhea', 2.306E+21, 527108, 4.5, 0.0013, '1672-12-23', 763.5, 'Saturn'),
       ('Titan', 1.345E+23, 2574.73, 15.9, 0.02888, '1655-03-25', 2524.5, 'Saturn'),
       ('Iapetus', 1.8E+21, 3560820, 79, 0.0276812, '1671-10-25', 735, 'Saturn'),
       ('Charon', 1.586E+21, 17536, 6.3872, 0.0022, '1978', 606, 'Pluto')
GO