# FoodybiteServer

## Requests

| Path | Method | Requires Authentication | Purpose |
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
