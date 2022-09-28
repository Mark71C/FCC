#! /bin/bash


# Make dump of database:
   pg_dump -cC --inserts -U freecodecamp periodic_table > periodic_table.sql
# Rebuild database:
#   psql -U postgres < periodic_table.sql
