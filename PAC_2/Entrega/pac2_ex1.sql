--Exercici 1

-- Create database
/*CREATE DATABASE pac2*/

-- Create schema

CREATE SCHEMA erp;
SET search_path TO erp;

-- Create tables
BEGIN WORK;

CREATE TABLE tb_cars(
	cars_registration CHARACTER(7),
	cars_model CHARACTER VARYING(50) NOT NULL,
	cars_function CHARACTER(20) NOT NULL,
	cars_deposit INTEGER NOT NULL,
	cars_fuel CHARACTER(10) NOT NULL DEFAULT 'gasoil',
	cars_date_input DATE NOT NULL DEFAULT CURRENT_DATE,
	cars_employee CHARACTER VARYING (50),
	cars_date_registration DATE NOT NULL,
	PRIMARY KEY(cars_registration)
);

CREATE TABLE tb_gas_station(
	gas_id CHARACTER(5),
	gas_name CHARACTER VARYING(50) NOT NULL,
	PRIMARY KEY(gas_id),
	UNIQUE(gas_name)
);

CREATE TABLE tb_pump(
	pm_id INTEGER,
	pm_parent_id INTEGER,
	gas_id CHARACTER(5),
	pm_descr CHARACTER VARYING(20) NOT NULL,
	PRIMARY KEY (pm_id),
	UNIQUE (gas_id, pm_id),
	FOREIGN KEY (pm_parent_id) REFERENCES tb_pump(pm_id),
	FOREIGN KEY (gas_id) REFERENCES tb_gas_station(gas_id)
);

CREATE TABLE tb_fuel_price(
	fp_date DATE,
	fp_fuel CHARACTER(10),
	fp_import NUMERIC(12,3) NOT NULL,
	PRIMARY KEY (fp_date, fp_fuel)
);

CREATE TABLE tb_refueling(
	gas_id CHARACTER(5),
	cars_registration CHARACTER(7),
	pm_id INTEGER,
	rf_liters INTEGER NOT NULL,
	rf_date DATE NOT NULL DEFAULT CURRENT_DATE,
	rf_km INTEGER,
	FOREIGN KEY (gas_id) REFERENCES tb_gas_station(gas_id),
	FOREIGN KEY (cars_registration) REFERENCES tb_cars(cars_registration),
	FOREIGN KEY (pm_id) REFERENCES tb_pump(pm_id)
);

CREATE TABLE tb_invoice(
	inv_id INTEGER,
	inv_num CHARACTER(5) NOT NULL,
	inv_date_start DATE NOT NULL,
	inv_date_end DATE NOT NULL,
	inv_amount NUMERIC(12,2) NOT NULL,
	inv_liters_total INTEGER NOT NULL,
	PRIMARY KEY (inv_id)
);

CREATE TABLE tb_lines_invoice(
	inv_id INTEGER,
	linv_id INTEGER,
	cars_registration CHARACTER(7),
	gas_id CHARACTER(5),
	linv_liters INTEGER NOT NULL,
	linv_amount NUMERIC(12,2) NOT NULL,
	PRIMARY KEY (inv_id, linv_id),
	FOREIGN KEY (inv_id) REFERENCES tb_invoice(inv_id),
	FOREIGN KEY (cars_registration) REFERENCES tb_cars(cars_registration),
	FOREIGN KEY (gas_id) REFERENCES tb_gas_station(gas_id)
);

COMMIT WORK;