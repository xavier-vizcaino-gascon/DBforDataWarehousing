--a
SET search_path TO erp;
EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--b
--sense index / seq_scan = ON
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
SET enable_seqscan = on;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--sense index / seq_scan = OFF
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
SET enable_seqscan = off;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--amb Btree / seq_scan = ON
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
CREATE UNIQUE INDEX IF NOT EXISTS indexOnCars_Registration_btree
	ON tb_cars USING btree (cars_registration);
SET enable_seqscan = on;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--amb Btree / seq_scan = OFF
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
CREATE UNIQUE INDEX IF NOT EXISTS indexOnCars_Registration_btree
	ON tb_cars USING btree (cars_registration);
SET enable_seqscan = off;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--amb hash / seq_scan = ON
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
DROP INDEX IF EXISTS indexOnCars_Registration_btree CASCADE;
CREATE INDEX IF NOT EXISTS indexOnCars_Registration_hash
	ON tb_cars USING hash (cars_registration);
SET enable_seqscan = on;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;

--amb hash / seq_scan = OFF
SET search_path TO erp;

ALTER TABLE tb_cars DROP CONSTRAINT IF EXISTS pk_cars CASCADE;
DROP INDEX IF EXISTS indexOnCars_Registration_btree CASCADE;
CREATE INDEX IF NOT EXISTS indexOnCars_Registration_hash
	ON tb_cars USING hash (cars_registration);
SET enable_seqscan = off;

EXPLAIN
SELECT * FROM tb_refueling r INNER JOIN tb_cars c
ON c.cars_registration=r.cars_registration;