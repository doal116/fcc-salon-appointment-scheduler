#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Welcome to the salon ~~~"

MAIN_MENU(){
  #presenting the list of services
  echo -e "\nSelect a service:"
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  #picking a service
  read SERVICE_ID_SELECTED
  SERVICE_EXISTENCE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  #if service doesn't exist
  if [[ -z $SERVICE_EXISTENCE ]]
  then
    #send to main menu
    MAIN_MENU
  else
    #entering phone number
    echo -e "\nEnter you phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_EXISTENCE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    #if is already customer
    if [[ -z $CUSTOMER_EXISTENCE ]]
    then
      #if doesn't exist in customer table
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      ADDING_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      
      #appointment time
      echo -e "\nEnter time of appointment:"
      read SERVICE_TIME
      
      #Adding in appointment table
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      ADDING_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    else 
      #if already exist in db
      echo -e "\nEnter time of appointment:"
      read SERVICE_TIME
      
      #Adding in appointment table
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      ADDING_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      CUSTOMER_NAME_DB=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME_DB."
    fi
  fi
}

MAIN_MENU