<p align="center">
  <h3 align="center">E-Commerce App + AR Feature (Experimental)</h3>
</p>


This is a fork of [@Sameera-Perera](https://github.com/Sameera-Perera/)'s Flutter project, meant to experiment an implementation of an AR view for the products shown. It is also meant as a concept app that a plant nursery may consider building as a way to Digitally Transform their business. 

## Changes Made / Features Affected

* **Purchasing Items**: Items added to cart cannot be purchased as the hosted backend does not support the hardcoded products listing
* **AR View**: AR Views were only tested on iOS, Android usage may be unavailable

*Note: Non-exhaustive list*
## Added environment variables

Environment variables are defined in json format as a `env.json` file on the root directory.

| Key | Description |
|---|---|
| TITLE | The name tagged to the app |
| MODELSTORAGE | A link to your store of assets |


## Installation

```sh
flutter pub get
```

```sh
flutter run --dart-define-from-file=env.json --release
```

### [CREDITS TO THE ORIGINAL REPO](https://github.com/Sameera-Perera/Flutter-TDD-Clean-Architecture-E-Commerce-App.git)