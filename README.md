Test task  “Currency converter”
You need to write an iOS application to convert currencies.
The minimum requirements for the application are:

A user can choose from 6 currencies: rubles (RUB), US dollars (USD), euro (EUR), British pound (GBP), Swiss franc (CHF), Chinese yuan (CNY).

The user selects an exchange rate pair (for example, USD/RUB) and enters the amount in the initial currency.

The application recalculates the amount in the destination currency based on the current exchange rate and shows the user the amount and the conversion rate.

The latest actual exchange rates should be saved in the application and used in case the client is offline or the rate receiving service returns an error.

The selected exchange rate pair is also saved and pre-filled when the app is later restarted.

How the application will be evaluated:

Application architecture (code decomposition into layers/components, use of architectural patterns)

Used libraries

Error handling

Code testability

Extras:

The appearance of the application does not matter, it is enough to implement a primitive UI. You can take a look at the similar apps published in the App Store as an example.

The resource Exchange Rates API can be used as an API to get current exchange rates (exchangeratesapi.io) or any other API provider.
