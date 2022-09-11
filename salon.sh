#! /bin/bash

# This is a salon app written in bash
#
# FreeCodeCamp 
#   excersize "Salon Appointment Scheduler"
#   part of the Relational Database Certification (Beta)

# Constants
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# App title
echo -e "\n~~~~ Welcome to our salon ~~~~"

# Preparation:
# - Empty all tables
#     EMPTY_TABLES=$($PSQL "TRUNCATE TABLE appointments, customers, services")
#     RESET_SERVICE_ID_SEQ=$($PSQL "ALTER SEQUENCE services_service_id_seq RESTART WITH 1")
#     FILL_SERVICES_TABLE=$($PSQL "INSERT INTO services (name) VALUES ('Cut hair'), ('Trim beard'), ('Color hair')")
#     FILL_SERVICES_TABLE=$($PSQL "INSERT INTO services (name) VALUES ('cut'), ('color'), ('perm'), ('style'), ('trim')")
# - Just empty tables with customers and oppointments
#     EMPTY_TABLES=$($PSQL "TRUNCATE TABLE appointments, customers")

MAIN_MENU() {
  # Message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nHow can we help you?\n"
  fi
  LIST_SERVICES  
} 

LIST_SERVICES() {
  # select services
  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # if no services can be selected (should not be a possibility!) 
  if [[ -z $LIST_OF_SERVICES ]]
  then
    # We can't help the customer!!! Give feedback to customer and Exit. 
    echo -e "Sorry, we can't help any customers right now. \nPlease try again later."
    EXIT
  else
    # display available services
    echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
    # ask for input (service)
    read SERVICE_ID_SELECTED
    # if input is pos int and in list with id's
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number. Please choose again:"
    else
      CHECK_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      # if not available
      if [[ -z $CHECK_SERVICE_ID ]]
      then
        # send to main menu
        MAIN_MENU "That service is not available. Please choose again:"
      else
        # go to CUSTOMER
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        CUSTOMER
      fi
    fi

  # else: return to MAIN_MENU with error message
  fi
} 

CUSTOMER() {
  # Ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
 
  # If number not known
  if [[ -z $CUSTOMER_ID ]]
  then
    # Ask for name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Add customer
    INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
#  else
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # Go to APPOINTMENT
  APPOINTMENT
}

APPOINTMENT() {
  # Ask for time
  echo -e "\nOK,$CUSTOMER_NAME. You chose:$SERVICE_NAME. At what time?"
  read SERVICE_TIME
  # If empty: Go to Main_MENU
  # If right time-format
    # Add appointment
    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
#    echo $INSERT_APPOINTMENT
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."

  # Else: Ask for time again.
}

EXIT() {
  echo -e "\nHope to see you soon!\n"
}

# Now, start the menu
MAIN_MENU