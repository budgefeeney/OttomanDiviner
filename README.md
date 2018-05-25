# Ottoman Diviner of Sales Performance

This peculiarly named project provides a suite of services for helping retailers build out their apps.

Unique to this app is the integration of *micro-services* and *oracles*.

The micro-services (see the `services` folder) allow retailes to perform the usual CRUD operations, these are

 1. Products
 2. Demand
 3. Deliveries
 4. Inventory

The inventory service is automatically updated by chances to the demand and delivery-tracking services.

**Forecasters** are virtual users that regularly query these services themselves, and then put *predictions of the future*. Hence while one can make queries to the inventory process to see what stocks were like at a particular location two days ago, one can also issue the same command with a date *two days hence* and get a sensible answer.

This could then conceivably be integrated with other services to provide alerts to retail managers if it appeared, for example, that their delivery schedule would not keep track with demand.

A neat consequence of this "virtual clairvoyant user" idea is the fact that forecasters need not be implemented in the same language as the REST API, since both communicate via the databse.

The project layout is

 * `datasets` contains sample data from Kaggle
 * `services` contains the various microservice implementations
 * `forecasters` contains the various forecaster implementations
 * `infrastructure` contains the Terraform script necessary to build the infrastructure that hosts all parts of this project.




