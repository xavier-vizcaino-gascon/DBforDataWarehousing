--Exercici 2

SET search_path TO erp;	

--a
SELECT
	c.cars_registration,
	c.cars_model,
	c.cars_employee,
	c.cars_date_registration
FROM 
	erp.tb_cars c
WHERE
	c.cars_function = 'reparto'
ORDER BY 
	c.cars_date_registration DESC
;

--b
SELECT
	c.cars_employee,
	c.cars_model,
	g.gas_name,
	r.rf_date
FROM
	(erp.tb_cars c 
	NATURAL JOIN erp.tb_gas_station g)
	NATURAL JOIN erp.tb_refueling r
WHERE
	r.rf_date BETWEEN '2022/08/01' AND '2022/08/31'
	AND r.rf_liters = 41
ORDER BY
	c.cars_employee ASC,
	r.rf_date DESC
;

--c
SELECT
	c.cars_registration,
	c.cars_employee,
	SUM(r.rf_liters) AS total_liters
FROM
	erp.tb_cars c,
	erp.tb_refueling r
WHERE
	c.cars_registration = r.cars_registration
	AND c.cars_function = 'comercial'
GROUP BY 
	c.cars_registration
ORDER BY
	total_liters ASC
;

--d
WITH imports_refueling_SEP AS(
	SELECT 
		r.cars_registration,
		c.cars_model,
		c.cars_function,
		r.rf_liters,
		r.rf_date,
		r.rf_liters*p.fp_import as rf_import
	FROM
		(erp.tb_cars c
		NATURAL JOIN erp.tb_refueling r)
		JOIN erp.tb_fuel_price p
		ON r.rf_date = p.fp_date
		AND c.cars_fuel = p.fp_fuel
	WHERE 
		r.rf_date BETWEEN '2022/09/01' AND '2022/09/30'
		AND c.cars_function = 'reparto'
),
average_VITO AS(
	SELECT
		ir.cars_registration,
		AVG(ir.rf_import) AS rf_import_avg
	FROM
		imports_refueling_SEP ir
	WHERE
		ir.cars_model LIKE '%VITO'
	GROUP BY
		ir.cars_registration
),
average_vehicles AS(
	SELECT
		AVG(ir.rf_import) AS rf_import_avg
	FROM
		imports_refueling_SEP ir
)
SELECT
	vito.cars_registration,
	vito.rf_import_avg
FROM 
	average_vehicles vhl,
	average_VITO vito
WHERE
	vito.rf_import_avg < vhl.rf_import_avg
;

--e
SELECT
	r.cars_registration,
	r.gas_id,
	r.rf_date
FROM
	erp.tb_refueling r
WHERE
	r.rf_km ISNULL
	AND r.gas_id IN ('GS02', 'GS04', 'GS05')
ORDER BY
	r.cars_registration DESC,
	r.rf_date ASC
;