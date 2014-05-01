RDataKit
========

Lightweight ORM Frameworks built upon CoreData

**Workign in progress**! Try out by one of followring means:

1. Clone my private cocoapod spec repo, and `pod install`
2. Clone this repo and hook up a local dependency in your local `Podfile` of your project


# Architecture


* RDataContext
    * Manifest of the core data stack
* RTraditonalDataContext
    * Data operations are synced across threads using notifications
* RNestedDataContext
    * Data operations are synced across threads using nested `NSManagedObjectContext`. Possibly causing deadlocks.
* RDataService
    * Subclass of `AFHTTPRequestOperationManager` of [AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking)
* RModel
    * Subclass or `NSManagedObject`
    * Helpers for dealing with remote RESTful API, like create `createWithObject:callback:`