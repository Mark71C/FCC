#! /bin/bash

# Fix database in bash script
# Not the purpose of this exercise, but changes
# got lost too many times...

# Constants
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

 QUERY=$($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass")
 QUERY=$($PSQL "ALTER TABLE properties RENAME boiling_point TO boiling_point_celsius")
 QUERY=$($PSQL "ALTER TABLE properties RENAME melting_point TO melting_point_celsius")
 QUERY=$($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET not null")
 QUERY=$($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET not null")
 QUERY=$($PSQL "ALTER TABLE elements ADD UNIQUE(symbol)")
 QUERY=$($PSQL "ALTER TABLE elements ADD UNIQUE(name)")
 QUERY=$($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET not null")
 QUERY=$($PSQL "ALTER TABLE elements ALTER COLUMN name SET not null")
 QUERY=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY ("atomic_number") REFERENCES elements(atomic_number)")
 QUERY=$($PSQL "CREATE TABLE types (type_id SERIAL PRIMARY KEY, type VARCHAR(20) not null)")
 QUERY=$($PSQL "INSERT INTO types (type) VALUES ('metal'), ('nonmetal'), ('metalloid')")
 QUERY=$($PSQL "ALTER TABLE properties ADD COLUMN type_id INT not null default 0")
 QUERY=$($PSQL "UPDATE properties SET type_id = (SELECT type_id from types where types.type=properties.type)")
 QUERY=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY (type_id) REFERENCES types(type_id)")
 QUERY=$($PSQL "ALTER TABLE properties DROP COLUMN type")
 QUERY=$($PSQL "UPDATE elements SET symbol = UPPER(left(symbol, 1)) || right(symbol, -1)")
 QUERY=$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE decimal")
 QUERY=$($PSQL "UPDATE properties SET atomic_mass = CAST(REGEXP_REPLACE(CAST(atomic_mass AS TEXT), '0*$', '') AS NUMERIC)")
 QUERY=$($PSQL "INSERT INTO elements (atomic_number, symbol, name) values (9, 'F', 'Fluorine')")
 QUERY=$($PSQL "INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (9, 18.998, -220, -188.1, 2) ")
 QUERY=$($PSQL "INSERT INTO elements (atomic_number, symbol, name) values (10, 'Ne', 'Neon')")
 QUERY=$($PSQL "INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (10, 20.18, -248.6, -246.1, 2) ")
 QUERY=$($PSQL "DELETE FROM properties WHERE atomic_number = 1000")
 QUERY=$($PSQL "DELETE FROM elements WHERE atomic_number = 1000")

echo $QUERY


# Make dump of database:
#   pg_dump -cC --inserts -U freecodecamp periodic_table > periodic_table.sql
# Rebuild database:
#   psql -U postgres < periodic_table.sql
