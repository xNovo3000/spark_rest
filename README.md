# SparkREST

## A blazing-fast, single instance, sessionless RESTful API for Dart

This package was created after the deprecation of Aqueduct. It is designed to be more developer-friendly

---

### Package objectives

- Simple to use
- Lightweight
- Very low time-to-deploy

### Features

- Separate classes for each endpoint and method
- Fully-configurable middlewares that manages the request before and after reaches the endpoint
- Native performance: every API created with SparkREST can be compiled using Dart's AOT compiler
- Plugins: everyone can create and publish a plugin on pub.dev

### How to use

- This is not a production server; must be used with Nginx as a reverse-proxy (or every other server that has the reverse-proxy capability)
- This API is designed to be passionless and single threaded. If you have more CPU threads, you have to run multiple instances of your API and enable load balancing on your production server
