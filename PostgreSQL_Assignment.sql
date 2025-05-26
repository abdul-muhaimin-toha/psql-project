CREATE TABLE IF NOT EXISTS rangers(
  ranger_id BIGSERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  region VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS species(
  species_id BIGSERIAL PRIMARY KEY,
  common_name VARCHAR(150) NOT NULL,
  scientific_name VARCHAR(150) NOT NULL,
  discovery_date DATE NOT NULL,
  conservation_status VARCHAR(20) CHECK(conservation_status = 'Endangered' OR conservation_status = 'Vulnerable') NOT NULL
);

CREATE TABLE IF NOT EXISTS sightings(
  sighting_id BIGSERIAL PRIMARY KEY,
  ranger_id BIGINT REFERENCES rangers(ranger_id) NOT NULL,
  species_id BIGINT REFERENCES species(species_id) NOT NULL,
  sighting_time TIMESTAMP NOT NULL,
  location VARCHAR(150) NOT NULL,
  notes TEXT

);

INSERT INTO rangers (name, region) VALUES
('Ava Creek', 'Crystal Forest'),
('Ben Ridge', 'Silver Lake'),
('Cleo Mist', 'Windy Highlands'),
('Dylan Grove', 'Dense Jungle'),
('Eve Bay', 'Golden Steppe'),
('Finn Rock', 'Shimmering Dunes'),
('Gina Field', 'Twilight Ridge'),
('Hugo Marsh', 'Echo Forest'),
('Ivy Stone', 'Frozen Fjord'),
('Jake Vale', 'Blooming Grove');

INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Striped Hyena', 'Hyaena hyaena', '1776-01-01', 'Endangered'),
('Desert Fox', 'Vulpes vulpes pusilla', '1811-01-01', 'Endangered'),
('Flying Squirrel', 'Petaurista philippensis', '1835-01-01', 'Endangered'),
('Mugger Crocodile', 'Crocodylus palustris', '1827-01-01', 'Endangered'),
('Indian Monitor', 'Varanus bengalensis', '1758-01-01', 'Vulnerable'),
('Jungle Cat', 'Felis chaus', '1831-01-01', 'Vulnerable'),
('Indian Hare', 'Lepus nigricollis', '1803-01-01', 'Vulnerable'),
('Wild Boar', 'Sus scrofa', '1799-01-01', 'Endangered'),
('Crested Serpent Eagle', 'Spilornis cheela', '1807-01-01', 'Vulnerable'),
('Hill Myna', 'Gracula religiosa', '1758-01-01', 'Vulnerable');

INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(5, 2, 'Ridge Top', '2025-05-17 16:04:00', NULL),
(9, 4, 'Canyon Trail', '2025-05-04 15:31:00', 'Tracks observed'),
(10, 8, 'Hill Edge', '2025-05-06 15:08:00', 'Tracks observed'),
(8, 5, 'Bay Corner', '2025-05-11 09:40:00', NULL),
(5, 5, 'River Bend', '2025-05-18 20:35:00', 'Feeding');


-- 1. Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers (name, region)
  VALUES('Derek Fox', 'Coastal Plains');


-- 2. Count unique species ever sighted.
SELECT COUNT(DISTINCT scientific_name) AS unique_species_count FROM species;

-- 3. Find all sightings where the location includes "Pass"
SELECT * FROM sightings WHERE location LIKE '%Pass%';

-- 4. List each ranger's name and their total number of sightings
SELECT rangers.name, count(*) AS total_sightings FROM sightings JOIN rangers USING("ranger_id") GROUP BY rangers.name;

-- 5. List species that have never been sighted
SELECT common_name FROM species LEFT JOIN sightings USING("species_id") WHERE sightings.species_id IS NULL;

-- 6. Show the most recent 2 sightings
SELECT common_name, sighting_time, name  FROM sightings LEFT JOIN species USING("species_id") LEFT JOIN rangers USING ("ranger_id") ORDER BY sighting_time DESC LIMIT 2;

-- 7. Update all species discovered before year 1800 to have status 'Historic'

ALTER TABLE species DROP CONSTRAINT IF EXISTS species_conservation_status_check;

ALTER TABLE species ADD CONSTRAINT species_conservation_status_check CHECK (conservation_status IN ('Endangered', 'Vulnerable', 'Historic'));

UPDATE species SET conservation_status = 'Historic' WHERE discovery_date < DATE '1800-01-01';

-- 8. Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'
SELECT sighting_id, CASE WHEN EXTRACT(HOUR FROM sighting_time) < 12 THEN 'Morning' WHEN EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 16 THEN 'Afternoon' ELSE 'Evening' END AS time_of_day FROM sightings;

-- 9. Delete rangers who have never sighted any species
DELETE FROM rangers WHERE ranger_id NOT IN (SELECT DISTINCT ranger_id FROM sightings);
