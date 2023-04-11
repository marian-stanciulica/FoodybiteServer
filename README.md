# FoodybiteServer

This is the backend app I wrote in `Swift` using `Vapor` for the [Foodybite](https://github.com/Marian25/Foodybite) app.

## Installation Guide

### 1. Vapor
Install Vapor by running the following command in terminal:
```bash
brew install vapor
```

### 2. (Optional) Install Docker
If you don't have Docker already installed use the [link](https://www.docker.com/products/docker-desktop/) and follow the instructions to install it.

### 3. Dowload Postgres DB
Run the following command to download the postgres image in docker:
```bash
docker pull postgres
```

### 4. Run DB server
Go to the main directory of the project and run the following command:
```bash
docker run --name postgres -e POSTGRES_DB=vapor_database \
  -e POSTGRES_USER=vapor_username \
  -e POSTGRES_PASSWORD=vapor_password \
  -p 5432:5432 -d postgres
```

### 4. Run the project

## Routes

| Path | Method | Requires Authentication | Description |
|------|------|------|------|
| /auth/signUp | POST | NO | Creates an user in DB |
| /auth/login | POST | NO | Logs in the user with the given credentials |
| /auth/accessToken | POST | YES | Generates and returns new tokens |
| /auth/changePassword | POST | YES | Changes the password of the current user |
| /auth/account | POST | YES | Updates current account with new fields |
| /auth/account | DELETE | YES | Deletes current account |
| /auth/logout | POST | YES | Logs out the user |
| /review | POST | YES | Adds review in DB |
| /review | GET | YES | Returns all reviews of the current user |
| /review/:placeID | GET | YES | Returns reviews of the current user for a particular placeID |

## Credits

[Vapor Authentication Template](https://github.com/madsodgaard/vapor-auth-template#readme) by Mads Odgaard
