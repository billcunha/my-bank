# MyBank

MyBank is a simple api to control bank accounts with users. It was written in [Phoenix](https://phoenixframework.org/) (v1.4.10).

## Description

The api provides functions to:
- Login using user data

POST to `http://[address]/api/v1/login` with `{"email": "", "password": ""}` in body

- Get the balance of the account

GET to `http://[address]/api/v1/account/:id`

- Transfer ammount of value to the target account

POST to `http://[address]/api/v1/account/:from_id/transfer/:to_id` with `{"value": ""}` in body

## Installation

Use the default guide on [Phoenix site](https://hexdocs.pm/phoenix/installation.html#content) to setup the enviroment.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate (`mix test`).

## Todo
- JWT Auth