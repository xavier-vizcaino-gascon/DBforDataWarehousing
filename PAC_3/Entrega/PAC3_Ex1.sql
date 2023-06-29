--Exercici 1

SET datestyle = YMD;   
SET search_path TO erp;	

--a
BEGIN WORK;

-- Table modification
ALTER TABLE
	erp.tb_pump
	ADD COLUMN IF NOT EXISTS
		updated_dt_tm TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

/*
Procedure: update_tb_pump_timestamp()
Author: Xavier Vizcaino
Creation date: 12-12-2022
Version: 1
Parameters: None
Description: Adds current timestamp @ NEW.updated_dt_tm as timestamp,
returning trigger.
*/
CREATE OR REPLACE FUNCTION update_tb_pump_timestamp() RETURNS trigger AS $$
	-- Start
	BEGIN
		-- Field assignation
		NEW.updated_dt_tm = CURRENT_TIMESTAMP;
		RETURN NEW;
	-- End
	END;
$$ LANGUAGE plpgsql;
		
CREATE TRIGGER tb_pump_updates
BEFORE UPDATE ON erp.tb_pump
FOR EACH ROW
EXECUTE PROCEDURE update_tb_pump_timestamp();

COMMIT WORK;

--b
BEGIN WORK;

-- Table modification
ALTER TABLE
	erp.tb_lines_invoice
	ADD COLUMN IF NOT EXISTS
		line_updated_dt_tm VARCHAR(20);

/*
Procedure: fn_line_inserted()
Author: Xavier Vizcaino
Creation date: 12-12-2022
Version: 1
Parameters: None
Description: Adds current timestamp @ NEW.line_updated_dt_tm,
as char with specified date & time format, returning trigger.
*/
CREATE OR REPLACE FUNCTION fn_line_inserted() RETURNS trigger AS $$
	-- Start
	BEGIN
		-- Field assignation
		NEW.line_updated_dt_tm = TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI');
		RETURN NEW;
	--End
	END;
$$ LANGUAGE plpgsql;
		
CREATE TRIGGER tg_line_inserted
BEFORE INSERT OR UPDATE ON erp.tb_lines_invoice
FOR EACH ROW
EXECUTE PROCEDURE fn_line_inserted();

COMMIT WORK;

--c
BEGIN WORK;

-- Table modification
ALTER TABLE erp.tb_invoice
	ADD COLUMN IF NOT EXISTS inv_updated_dt DATE,
	ADD COLUMN IF NOT EXISTS inv_update_counter INTEGER DEFAULT 0,
	ADD COLUMN IF NOT EXISTS inv_insert_counter INTEGER DEFAULT 0;

/*
Procedure: fn_invoice_updated()
Author: Xavier Vizcaino
Creation date: 13-12-2022
Version: 1
Parameters: None
Description: Updates up to 3 fields in tb_invoice:
1. Data filed, date type with specified format
2. Counter for inserted lines
3. Counter for modificated lines,
the procedure is called by a trigger.
*/
CREATE OR REPLACE FUNCTION fn_invoice_updated() RETURNS trigger AS $$
	-- Start
	BEGIN
		-- Data field update
		UPDATE erp.tb_invoice
		SET inv_updated_dt = TO_DATE(NEW.line_updated_dt_tm,'YYYY-MM-DD')
		WHERE inv_id = NEW.inv_id;

		-- Insert counter (OLD is NULL)
		IF OLD IS NULL THEN
			UPDATE erp.tb_invoice
			SET inv_insert_counter = inv_insert_counter+1
			WHERE inv_id = NEW.inv_id;
		END IF;

		-- Modification counter (OLD not NULL & NEW<>OLD)
		IF OLD IS NOT NULL AND NEW IS DISTINCT FROM OLD THEN
			UPDATE erp.tb_invoice
			SET inv_update_counter = inv_update_counter+1
			WHERE inv_id = NEW.inv_id;
		END IF;
		RETURN NEW;	
	-- End
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_invoice_updated
AFTER INSERT OR UPDATE ON erp.tb_lines_invoice
FOR EACH ROW
EXECUTE PROCEDURE fn_invoice_updated();

COMMIT WORK;