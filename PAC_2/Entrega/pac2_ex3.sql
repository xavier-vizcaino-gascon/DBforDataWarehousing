--Exercici 3

SET datestyle = YMD;   
SET search_path TO erp;	


--a
--vehicle 1
INSERT INTO 
	erp.tb_cars 
		(cars_registration,
		 cars_model,
		 cars_function,
		 cars_deposit,
		 cars_fuel,
		 cars_date_input,
		 cars_employee,
		 cars_date_registration)
	VALUES 
		('2233JMN',
		 'AUDI Q5',
		 'gerencia',
		 40,
		 'gasolina',
		 CURRENT_DATE,
		 'Carmen Sevilla Calvo',
		 to_date('16-03-2016','DD-MM-YYYY'));

--vehicle 2
INSERT INTO 
	erp.tb_cars 
		(cars_registration,
		 cars_model,
		 cars_function,
		 cars_deposit,
		 cars_fuel,
		 cars_date_input,
		 cars_employee,
		 cars_date_registration)
	VALUES 
		('7542LSN',
		 'AUDI A1',
		 'gerencia',
		 30,
		 DEFAULT,
		 CURRENT_DATE,
		 'Carlos Díaz Sevilla',
		 to_date('01-08-2021','DD-MM-YYYY'));

--vehicle 3
INSERT INTO 
	erp.tb_cars 
		(cars_registration,
		 cars_model,
		 cars_function,
		 cars_deposit,
		 cars_fuel,
		 cars_date_input,
		 cars_employee,
		 cars_date_registration)
	VALUES 
		('1974LBN',
		 'AUDI A3',
		 'gerencia',
		 35,
		 'gasoil',
		 CURRENT_DATE,
		 'Javier Díaz Sevilla',
		 to_date('30-09-2019','DD-MM-YYYY'));

--b
WITH refuelings_done AS(
	SELECT 
		c.cars_fuel,
		r.rf_date
	FROM 
		(erp.tb_refueling r
		NATURAL JOIN erp.tb_cars c)
		JOIN erp.tb_fuel_price f
		ON r.rf_date = f.fp_date
	GROUP BY 
		r.rf_date,
		c.cars_fuel
	ORDER BY
		r.rf_date DESC,
		c.cars_fuel ASC
)
DELETE FROM
	erp.tb_fuel_price fp
WHERE 
	(fp.fp_date,fp.fp_fuel) NOT IN(
		SELECT
			rd.rf_date,
			rd.cars_fuel
		FROM
			refuelings_done rd)
RETURNING *;

--c
ALTER TABLE
	erp.tb_fuel_price
	ADD COLUMN
		fp_import_without_vat NUMERIC(12,3);
UPDATE
	erp.tb_fuel_price
	SET
		fp_import_without_vat = fp_import/1.21;
ALTER TABLE
	erp.tb_fuel_price
ALTER COLUMN
	fp_import_without_vat
	SET NOT NULL
;

--d
ALTER TABLE
	erp.tb_cars
ADD CHECK(
		cars_function != 'gerencia'
		AND cars_employee IS NOT NULL
		OR cars_function = 'gerencia')
;

--e
CREATE ROLE new_user WITH PASSWORD '1234';

ALTER ROLE new_user LOGIN;

GRANT
	SELECT,
	INSERT,
	UPDATE
ON
	erp.tb_refueling
TO
	new_user
;

GRANT
	USAGE
ON SCHEMA
	erp
TO
	new_user
;