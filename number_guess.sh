#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~Number Guessing Game~~\n"

#Generate random number [1,1000]
SECRET_NUMBER=$((RANDOM%1000+1))
TRIES=0

#Get username 
echo -e "\nEnter your username:"
read USERNAME

#Check if user exits
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]
then 
  #New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  #Existing user
  IFS='|' read GAMES_PLAYED BEST_GAME <<< $USER_INFO
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Game start 
echo -e "\nGuess the secret number between 1 and 1000:"

while true; do
  read GUESS
  
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment tries
  ((TRIES++))

  # Check guess
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # Update user statistics
    if [[ -z $USER_INFO ]]
    then
      # First game for new user
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = 1, best_game = $TRIES WHERE username = '$USERNAME'")
    else
      # Update existing user
      if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]
      then
        UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $TRIES WHERE username = '$USERNAME'")
      else
        UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
      fi
    fi
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
