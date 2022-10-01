#! /bin/bash

# Number guessing game
# Final Project of freeCodeCamp's Relational Database Certificatie
# MC
# Start:    2022-09-30
# Finished: 2022-10-xx

# Constants
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"


MAIN() {
  # Declare & Initialize variables
  USERNAME=""
  BEST_GAME=1000
  NUMBER_OF_GUESSES=1 

  echo -e "\n~~~~ Number guessing game ~~~~"
  # Get user's name
  ASK_NAME
  # Generate random number
  RND_NUM=$((1 + $RANDOM % 1000))
  # echo $RND_NUM
  GAME
  NUMBER_FOUND
}


ASK_NAME() {
  USERNAME=""
  # Ask for name
  echo -e "\nEnter your username:"
  while [ "$USERNAME" == "" ]
  do
    read INPUT_NAME
    SIZE=${#INPUT_NAME} 

    if [ $SIZE -eq 0 ]
    then
      echo "No input. Please enter your name."
    else
      if [ $SIZE -gt 22 ]
      then
        echo -e "Name is too long (max 22 characters).\nPlease enter a shorter name."
      else 
        USERNAME=$INPUT_NAME
      fi
    fi
  done

  # Check name in DB
  CHECK_NAME=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")
  if [[ -z $CHECK_NAME ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_NAME=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 1000)")
  else
    # Username found in DB!
    [[ $CHECK_NAME =~ (^[^|]+)[|]([0-9]+)[|]([0-9]+$) ]]
    #echo "${BASH_REMATCH[0]}"
    USERNAME="${BASH_REMATCH[1]}"
    GAMES_PLAYED="${BASH_REMATCH[2]}"
    BEST_GAME="${BASH_REMATCH[3]}"

# THIS DOESN'T WORK: FUNCTION is executed in a shell and variables are not shared!
#    echo $CHECK_NAME | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
#    do
#      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
#    done

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}


GAME() {
  echo "Guess the secret number between 1 and 1000:"
  GUESSED=0
  until [[ GUESSED -eq 1 ]]
  do
    read NUMBER_INPUT
    # check if it is a number
    if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]
    then 
      echo "That is not an integer, guess again:"
    else
      if [[ $NUMBER_INPUT -gt $RND_NUM ]]
      then
        echo "It's lower than that, guess again:"
        let "NUMBER_OF_GUESSES += 1"
      else
        if [[ $NUMBER_INPUT -lt $RND_NUM ]]
        then
          echo "It's higher than that, guess again:"
          let "NUMBER_OF_GUESSES += 1"
        else
          # GUESSED IT !!!!!!
          GUESSED=1
        fi
      fi
    fi
  done
}


NUMBER_FOUND() {
  # Update User Data
  let "GAMES_PLAYED += 1"
  if [ $BEST_GAME -gt $NUMBER_OF_GUESSES ]
  then 
    let "BEST_GAME = $NUMBER_OF_GUESSES"
  fi

  UPDATE_USER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
  # Final print
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RND_NUM. Nice job!"
}


# Now, start the show
MAIN