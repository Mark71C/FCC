#! /bin/bash

# Periodic table app
# MC 2022-09-25
# Part of the Relational Database Certification (Beta)

# Constants
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# App title
#echo -e "\n~~~~ Periodic table app ~~~~"

# Store argument in a variable before entering a function!
FOUND="0"
ARG1=$1

MAIN_MENU() {
  # If you run ./element.sh, it should output Please provide an element as an argument. and finish running.
  if [ -z $ARG1 ] #[[ ! $1 ]]
  then
    echo "Please provide an element as an argument."
  else
    # If you run ./element.sh 1, ./element.sh H, or ./element.sh Hydrogen, it should output
    # Check if Number
    if [[ $ARG1 =~ ^[0-9]+$ ]]
    then
      # Now, check this number in DB
      NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $ARG1")
      if [[ $NUMBER ]]
      then
        FOUND="1"
      fi
    else
      # Check Symbol
      if [[ $ARG1 =~ ^[A-Z][A-Za-z]?$ ]]
      then
        # Now, check this symbol in DB
        NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ARG1' ")
        if [[ $NUMBER ]]
        then
          FOUND="1"
        fi
      else
        # Check Name
        if [[ $ARG1 =~ ^[A-Z][a-z]{2,}$ ]]
        then
          # Now, check this name in DB
          NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$ARG1' ")
          if [[ $NUMBER ]]
          then
            FOUND="1"
          fi
        #else
          #echo "Not a number/symbol/name"
        fi # check name
      fi # check symbol
    fi # check number

    # Print the feedback to the user
    if [ $FOUND = 0 ]
    then
      echo "I could not find that element in the database."
    else
      #OTP="The element with atomic number "$NUMBER
      #NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $NUMBER ")
      #OTP+=" is"$NAME
      #SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $NUMBER ")
      #SYMBOL=$(echo $SYMBOL | sed 's/^ *//g')  #Delete leading white space
      #OTP+=" ("$SYMBOL"). "
      #TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties ON properties.type_id = types.type_id WHERE properties.atomic_number = $NUMBER")
      #OTP+="It's a"$TYPE
      #MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $NUMBER")
      #OTP+=", with a mass of "$MASS" amu. "$NAME" has a melting point of"
      #MELT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $NUMBER")
      #OTP+=$MELT" celsius and a boiling point of "
      #BOIL=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $NUMBER")
      #OTP+=$BOIL" celsius."
      #echo $OTP

      #refactor this into ONE seclect statement:

      QRY=$($PSQL "SELECT name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements
                  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                  INNER JOIN types ON properties.type_id = types.type_id
                  WHERE elements.atomic_number = $NUMBER ")
      echo $QRY
      echo "$QRY" | while read NAME BAR SYMBOL BAR MASS BAR MELT BAR BOIL BAR TYPE
      do
        SYMBOL=$(echo $SYMBOL | sed 's/^ *//g')  #Delete leading white space
        echo "The element with atomic number"$NUMBER" is "$NAME" ("$SYMBOL"). It's a "$TYPE", with a mass of "$MASS" amu. "$NAME" has a melting point of "$MELT" celsius and a boiling point of "$BOIL" celsius."
      done
    fi
  fi # check input
}

MAIN_MENU
