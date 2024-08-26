#!/bin/bash
echo -e "\n~~ Welcome to my salon !!! ~~\n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_ID_SELECTED=""

DISPLAY_AVAILABLE_SERVICES(){
  
  echo "Here are the services I offer:"
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    if [[ $NAME != "name" ]]
    then
      echo $SERVICE_ID")" $NAME
    fi
  done 
  
  echo "-------"
  echo "0) exit"
}

READ_SERVICE_OPTION(){
  
  echo -e "\nWhat would you like (name or ID)?"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == 0 || $SERVICE_ID_SELECTED == "exit" ]]
  then
    echo -e "\nThanks for stopping in. Have a great day !\n"
    exit 1
  fi

  if [[ $SERVICE_ID_SELECTED =~ [1-9]+ ]]
  then
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  else
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_ID_SELECTED'")
  fi
}

while [[ -z $SERVICE_ID_SELECTED ]]
do
  DISPLAY_AVAILABLE_SERVICES
  READ_SERVICE_OPTION
done


while [[ ! $CUSTOMER_PHONE =~ [0-9] ]]
do
  echo -e "\nWhat's your phone number (min. 1 digit)?:"
  read CUSTOMER_PHONE
done

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record of your phone, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ $//g')
FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ $//g')

echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."