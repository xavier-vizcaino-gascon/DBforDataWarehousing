--------------
--Exercici 1--
--------------
SET search_path to erp;

--Apartat 1

BEGIN WORK;

--Create sequence
CREATE SEQUENCE IF NOT EXISTS seq_cars_id INCREMENT BY 1 START WITH 100;

--Create column in tb_cars
ALTER TABLE erp.tb_cars ADD COLUMN IF NOT EXISTS cars_id INTEGER NOT NULL DEFAULT nextval('seq_cars_id');

--Create columns in tb_refueling & tb_lines_invoice
ALTER TABLE erp.tb_refueling ADD COLUMN IF NOT EXISTS cars_id INTEGER;
ALTER TABLE erp.tb_lines_invoice ADD COLUMN IF NOT EXISTS cars_id INTEGER;

--Populate cars_id in tb_refueling
WITH identifiers AS (
	SELECT c.cars_registration, c.cars_id
	FROM
		erp.tb_cars c
		JOIN erp.tb_refueling r
		ON c.cars_registration = r.cars_registration
)
UPDATE 
	erp.tb_refueling 
SET 
	cars_id = identifiers.cars_id
FROM 
	identifiers
WHERE
	erp.tb_refueling.cars_registration=identifiers.cars_registration;

--Populate cars_id in tb_lines_invoice
WITH identifiers AS (
	SELECT c.cars_registration, c.cars_id
	FROM
		erp.tb_cars c
		JOIN erp.tb_lines_invoice li
		ON c.cars_registration = li.cars_registration
)
UPDATE 
	erp.tb_lines_invoice
SET 
	cars_id = identifiers.cars_id
FROM 
	identifiers
WHERE
	erp.tb_lines_invoice.cars_registration=identifiers.cars_registration;

--Drop primary key constraint with cascade in tb_cars
ALTER TABLE erp.tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;

--Add new primary key in tb_cars
ALTER TABLE erp.tb_cars ADD PRIMARY KEY (cars_id);

--Add foreign keys in tb_refueling & tb_lines_invoice
ALTER TABLE erp.tb_refueling ADD CONSTRAINT fk_cars FOREIGN KEY (cars_id) REFERENCES erp.tb_cars (cars_id);
ALTER TABLE erp.tb_lines_invoice ADD CONSTRAINT fk_cars FOREIGN KEY (cars_id) REFERENCES erp.tb_cars (cars_id);

--Drop cars_registration columns
ALTER TABLE erp.tb_cars DROP COLUMN IF EXISTS cars_registration;
ALTER TABLE erp.tb_refueling DROP COLUMN IF EXISTS cars_registration;
ALTER TABLE erp.tb_lines_invoice DROP COLUMN IF EXISTS cars_registration;

COMMIT;


--Apartat 2

--1st CTE for joined table
WITH RECURSIVE ref_pump AS(
	SELECT
		p.pm_id,
		p.pm_descr,
		p.pm_parent_id,
		r.rf_liters
	FROM
		erp.tb_pump p LEFT JOIN erp.tb_refueling r
		ON (p.pm_id=r.pm_id)
--2nd CTE for recursive query
), pumps AS(
--Non recursive part
	SELECT
		pm_id,
		pm_descr,
		pm_parent_id,
		rf_liters,
		CAST (pm_descr AS TEXT) AS resultat
	FROM
		ref_pump
	WHERE
		pm_parent_id IS NULL
--Recursive part
	UNION ALL
	SELECT
		pp.pm_id,
		pp.pm_descr,
		pp.pm_parent_id,
		pp.rf_liters,
		CAST(pmp.resultat || '->' || pp.pm_descr AS TEXT) AS resultat
	FROM
		ref_pump pp
		INNER JOIN pumps pmp
		ON (pp.pm_parent_id = pmp.pm_id)
)
--Query
SELECT 
	pm_id,
	resultat,
	sum(rf_liters) AS total
FROM
	pumps
GROUP BY
	pm_id,
	resultat
HAVING sum(rf_liters)>300
ORDER BY
	pm_id;


--Apartat 3

--CTE for joining tables
WITH ref_cars AS(
	SELECT
		c.cars_registration,
		c.cars_model,
		r.gas_id,
		r.rf_date,
		r.rf_liters
	FROM
		erp.tb_cars c FULL OUTER JOIN erp.tb_refueling r
		ON (c.cars_registration=r.cars_registration)
)
-- Ranks & sum
SELECT 
	cars_registration,
	cars_model,
	RANK() OVER (PARTITION BY cars_registration 
				 ORDER BY gas_id,
				rf_date) AS position,
	gas_id,
	RANK() OVER (PARTITION BY cars_registration,
				 gas_id ORDER BY rf_date) AS position,
	rf_date,
	rf_liters,
	SUM(rf_liters) OVER (PARTITION BY cars_registration
						ORDER BY gas_id,
						rf_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum
	
FROM ref_cars
ORDER BY
	cars_registration,
	gas_id,
	rf_date;