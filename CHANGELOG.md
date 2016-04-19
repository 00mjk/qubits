## Changelog

### 0.1.0
- Remove `commands` from options passed to `Flow`
- Add `Repository::delete` method
- `EventStore` constructor function accepts an object with override methods
- `Flow` works with command handlers that return promises for events
- `Repository` works with event stores that return promises in `EventStore::getEvents`
