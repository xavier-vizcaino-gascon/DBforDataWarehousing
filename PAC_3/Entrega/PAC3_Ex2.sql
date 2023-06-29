--Exercici 2

SET datestyle = YMD;   
SET search_path TO erp;	

--a
BEGIN WORK;

-- Table modification
ALTER TABLE
	erp.tb_refueling
	ADD COLUMN IF NOT EXISTS
		rf_cost NUMERIC(12,2) NOT NULL DEFAULT 0;

/*
Procedure: fn_calc_cost()
Author: Xavier Vizcaino
Creation date: 13-12-2022
Version: 1
Parameters: None
Description: Calculates the refuelling cost by obtaining,
the fuel price (on the refuelling date and for the vehicle's
fuel type) and multiplying by the total liters amount refilled.
The procedure is called by a trigger.
*/
CREATE OR REPLACE FUNCTION fn_calc_cost() RETURNS trigger AS $$
	-- Variables declaration
	DECLARE
		fuel_type erp.tb_cars.cars_fuel%TYPE;
		fuel_price erp.tb_fuel_price.fp_import%TYPE;
	-- Start
	BEGIN
		-- Get fuel type through query
		SELECT c.cars_fuel INTO fuel_type
		FROM erp.tb_cars c
		WHERE c.cars_registration=NEW.cars_registration;
		
		-- Get fuel price for that day & fuel type
		SELECT fp.fp_import INTO fuel_price
		FROM erp.tb_fuel_price fp
		WHERE fp.fp_fuel=fuel_type
		AND fp.fp_date=NEW.rf_date;
		
		-- Calculate refuelling cost
		NEW.rf_cost=NEW.rf_liters*fuel_price;
		RETURN NEW;
	-- End
	END;
$$ LANGUAGE plpgsql;
		
CREATE TRIGGER tg_refueling_cost
BEFORE INSERT ON erp.tb_refueling
FOR EACH ROW
EXECUTE PROCEDURE fn_calc_cost();

COMMIT WORK;

--b
BEGIN WORK;

-- User defined type
CREATE TYPE rf_details AS (
	car_function CHARACTER(20),
	rf_date DATE,
	rf_liters INTEGER,
	rf_cost NUMERIC(12,2));

/*
Procedure: fn_get_cost_by_car_type(date, date, char(20))
Author: Xavier Vizcaino
Creation date: 14-12-2022
Version: 1
Parameters: 
1. initial_date DATE: start date to consider in the reporting
2. final_date DATE: end date to consider in the reporting
3. car_function CHAR(20): vehicle main function [gerencia, reparto, comercial]
Description: Outputs all the refuelings perfomed by all vehicles under the
selected "car_function" for the given dates period.
*/
CREATE OR REPLACE FUNCTION fn_get_cost_by_car_type(initial_date DATE, final_date DATE, car_function CHARACTER(20))
RETURNS SETOF rf_details AS $$
	-- Variables declaration
	DECLARE
		rf_cursor erp.rf_details;
	-- Start
	BEGIN
		-- Exception conditions check
		IF length(car_function)>20 THEN
			RAISE EXCEPTION
			'Longitud excessiva del valor introduït per al tipus de variable';
		ELSE
			-- Loop for row output
			FOR rf_cursor IN
				SELECT
					c.cars_function,
					rf.rf_date,
					rf.rf_liters,
					rf.rf_cost
				FROM (
					erp.tb_cars c 
					NATURAL JOIN erp.tb_refueling rf)
				WHERE
					c.cars_function=car_function
					AND rf.rf_date BETWEEN initial_date AND final_date
				GROUP BY rf.rf_date, c.cars_function, rf.rf_liters, rf.rf_cost
				ORDER BY rf.rf_date, rf.rf_liters
			LOOP
			RETURN NEXT rf_cursor;
			END LOOP;
		END IF;
	RETURN;
	-- End
	END;
$$ LANGUAGE plpgsql;

COMMIT WORK;

--c
BEGIN WORK;

-- Table creation
CREATE TABLE IF NOT EXISTS erp.tb_invoice_cost_summary(
	cars_registration CHARACTER(10) NOT NULL,
	cars_fuel CHARACTER(10) NOT NULL,
	invoice_year INTEGER NOT NULL,
	invoice_quarter INTEGER NOT NULL,
	invoice_month CHARACTER(10) NOT NULL,
	total_liters INTEGER NOT NULL,
	total_cost NUMERIC(10,2) NOT NULL,
	number_of_lines INTEGER NOT NULL,
	timestamp TIMESTAMP NOT NULL
);

/*
Procedure: insert_summary()
Author: Xavier Vizcaino
Creation date: 15-12-2022
Version: 1
Parameters: None
Description: Inserts values into a table with liters, cost and number of lines
totalization by car's plate & invoice period (month)
*/
CREATE OR REPLACE FUNCTION insert_summary() RETURNS void AS $$
	-- Variables declaration
	DECLARE
		cars_registration erp.tb_invoice_cost_summary.cars_registration%TYPE; 
		cars_fuel erp.tb_invoice_cost_summary.cars_fuel%TYPE; 
		invoice_year erp.tb_invoice_cost_summary.invoice_year%TYPE;
		invoice_quarter erp.tb_invoice_cost_summary.invoice_quarter%TYPE;
		invoice_month erp.tb_invoice_cost_summary.invoice_month%TYPE;
		total_liters erp.tb_invoice_cost_summary.total_liters%TYPE;
		total_cost erp.tb_invoice_cost_summary.total_cost%TYPE;
		number_of_lines erp.tb_invoice_cost_summary.number_of_lines%TYPE;
	-- Start
	BEGIN
		FOR cars_registration, 
			cars_fuel, 
			invoice_year,
			invoice_quarter,
			invoice_month,
			total_liters,
			total_cost,
			number_of_lines 
			IN SELECT
				li.cars_registration, 
				c.cars_fuel, 
				EXTRACT(YEAR FROM i.inv_date_start) AS invoice_year,
				EXTRACT(QUARTER FROM i.inv_date_start) AS invoice_quarter, 
				TO_CHAR(i.inv_date_start, 'YYYY/MM') AS invoice_month,
				SUM(li.linv_liters) AS total_liters,
				SUM(li.linv_amount) AS total_cost,
				COUNT(c.cars_date_registration) AS number_of_lines
			FROM erp.tb_lines_invoice li
			NATURAL JOIN erp.tb_cars c
			JOIN erp.tb_invoice i
			ON i.inv_id = li.inv_id
			GROUP BY
				li.cars_registration,
				c.cars_fuel,
				invoice_year,
				invoice_quarter,
				invoice_month
			ORDER BY
				invoice_month
			LOOP
			-- Values insert into table
			INSERT INTO erp.tb_invoice_cost_summary (cars_registration, cars_fuel, invoice_year, invoice_quarter, invoice_month, total_liters, total_cost, number_of_lines, timestamp)
			VALUES (cars_registration, cars_fuel, invoice_year, invoice_quarter, invoice_month, total_liters, total_cost, number_of_lines, CURRENT_TIMESTAMP);
		END LOOP;
	-- End
	END;
$$ LANGUAGE plpgsql;

COMMIT WORK;