CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS foreign_server
	FOREIGN DATA WRAPPER postgres_fdw
	OPTIONS (host 'hh-pgsql-public.ebi.ac.uk', port '5432', dbname 'pfmegrnargs');
	
CREATE USER MAPPING IF NOT EXISTS FOR user 
     SERVER foreign_server
     OPTIONS (user 'reader', password 'NWDMCE5xdipIjRrp');
	 
CREATE FOREIGN TABLE foreign_table (
    taxid INTEGER,
	timestamp TIMESTAMP
)
	SERVER foreign_server
	OPTIONS (schema_name 'rnacen', table_name 'xref');

SELECT *
FROM foreign_table
LIMIT 20;