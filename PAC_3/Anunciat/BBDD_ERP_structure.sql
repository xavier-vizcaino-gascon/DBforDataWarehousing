  ------------------------------------------------------------------------------------------------
  --
  -- Create database
  --
  ------------------------------------------------------------------------------------------------
  
  -- CREATE DATABASE pec2;
 
  ------------------------------------------------------------------------------------------------
  --
  -- Drop tables
  --
  ------------------------------------------------------------------------------------------------
  DROP TABLE IF EXISTS erp.tb_refueling CASCADE;
  DROP TABLE IF EXISTS erp.tb_lines_invoice CASCADE;
  DROP TABLE IF EXISTS erp.tb_gas_station CASCADE;
  DROP TABLE IF EXISTS erp.tb_cars CASCADE;
  DROP TABLE IF EXISTS erp.tb_invoice CASCADE;
  DROP TABLE IF EXISTS erp.tb_pump CASCADE;
  DROP TABLE IF EXISTS erp.tb_fuel_price CASCADE;

 ------------------------------------------------------------------------------------------------
  --
  -- Drop schema
  --
  ------------------------------------------------------------------------------------------------
  DROP SCHEMA IF EXISTS erp;

------------------------------------------------------------------------------------------------
  --
  -- Create schema
  --
  ------------------------------------------------------------------------------------------------
  
  CREATE SCHEMA erp;

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_cars
  --
  ------------------------------------------------------------------------------------------------
  
  CREATE TABLE erp.tb_cars  (
    cars_registration		CHARACTER(7) NOT NULL,
    cars_model          	CHARACTER VARYING(50) NOT NULL,
    cars_function       	CHARACTER(20) NOT NULL,
    cars_deposit        	INT NOT NULL,
    cars_fuel				CHARACTER(10) DEFAULT 'gasoil' NOT NULL, 
    cars_date_input			DATE NOT NULL DEFAULT current_date,
    cars_employee			CHARACTER VARYING(50),
    cars_date_registration  DATE NOT NULL,
    CONSTRAINT pk_cars PRIMARY KEY (cars_registration)
  );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_gas_station
  --
  ------------------------------------------------------------------------------------------------

  CREATE TABLE erp.tb_gas_station   (
    gas_id					CHARACTER(5) NOT NULL,
    gas_name				CHARACTER VARYING(50) NOT NULL,
    CONSTRAINT pk_gas_station PRIMARY KEY (gas_id),
	CONSTRAINT u_gas_name  UNIQUE (gas_name)
  );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_fuel_price
  --
  ------------------------------------------------------------------------------------------------
 
  CREATE TABLE erp.tb_fuel_price   (
    fp_date					DATE NOT NULL,
    fp_fuel					CHARACTER(10) NOT NULL,
    fp_import				NUMERIC(12,3) NOT NULL,
    CONSTRAINT pk_fuel_price PRIMARY KEY (fp_date,fp_fuel)
  );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_pump
  --
  ------------------------------------------------------------------------------------------------

  CREATE TABLE erp.tb_pump   (
    pm_id				    INT NOT NULL,
    pm_parent_id			INT,
    gas_id					CHARACTER(5) NULL,
    pm_descr				CHARACTER VARYING(20) NOT NULL,
    CONSTRAINT pk_pump PRIMARY KEY (pm_id),
	CONSTRAINT u_pm_gas  UNIQUE (pm_id,gas_id),  
    CONSTRAINT fk_pump_parent_id FOREIGN KEY (pm_parent_id) REFERENCES erp.tb_pump (pm_id),
    CONSTRAINT fk_gas_station FOREIGN KEY (gas_id) REFERENCES erp.tb_gas_station (gas_id)
 );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_refueling
  --
  ------------------------------------------------------------------------------------------------

  CREATE TABLE erp.tb_refueling   (
    gas_id					CHARACTER(5) NOT NULL,
    cars_registration		CHARACTER(7) NOT NULL,
    pm_id					INT NOT NULL,
    rf_liters				INT NOT NULL,
    rf_date					DATE NOT NULL DEFAULT current_date,
    rf_km      				INT,
    CONSTRAINT fk_cars FOREIGN KEY (cars_registration) REFERENCES erp.tb_cars (cars_registration),
    CONSTRAINT fk_pump FOREIGN KEY (pm_id,gas_id) REFERENCES erp.tb_pump (pm_id,gas_id)
  );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_invoice
  --
  ------------------------------------------------------------------------------------------------


  CREATE TABLE erp.tb_invoice   (
    inv_id					INT NOT NULL,
    inv_num					CHARACTER(5) NOT NULL,
    inv_date_start 			DATE NOT NULL,
    inv_date_end 			DATE NOT NULL,	
    inv_amount				NUMERIC(12,2) NOT NULL,
    inv_liters_total		INT NOT NULL,
    CONSTRAINT pk_invoice PRIMARY KEY (inv_id)
  );

------------------------------------------------------------------------------------------------
  --
  -- Create table tb_lines_invoice
  --
  ------------------------------------------------------------------------------------------------

  CREATE TABLE erp.tb_lines_invoice  (
    inv_id				INT NOT NULL,
    linv_id				INT NOT NULL,
    cars_registration	CHARACTER(7) NOT NULL,
    gas_id				CHARACTER(5) NOT NULL,
    linv_liters			INT NOT NULL,
    linv_amount			NUMERIC(12,2) NOT NULL,
    CONSTRAINT pk_lines_invoice PRIMARY KEY (inv_id,linv_id),
    CONSTRAINT fk_gas_station FOREIGN KEY (gas_id) REFERENCES erp.tb_gas_station (gas_id),
    CONSTRAINT fk_cars FOREIGN KEY (cars_registration) REFERENCES erp.tb_cars (cars_registration),
	CONSTRAINT fk_invoice FOREIGN KEY (inv_id) REFERENCES erp.tb_invoice (inv_id)
  );

  