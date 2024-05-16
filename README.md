# Pg-TypeId

## An implementation of TypeId for Postgres

TypeId is a type-safe, globally unique identifier format inspired by Stripe's IDs, designed to be sortable, unique and type-safe.

This implementation of TypeId does some modification to the base TypeId specification by replacing the random UUID part of the TypeId in favor of a sortable ULID

This implement of TypeId consists of two parts a `Type` prefix and a `ULID` suffix, separated by an underscore.

- ```pseudo
  user_01HXYG96MV7WS0E2KW4ZCGP3KZ
  └──┘ └────────────────────────┘
  Type          ULID
  ```

- **Type Prefix**
  - The type prefix is a string of up to 63 characters in lowercase snake_case ASCII (a-z and underscore). It indicates the type of entity the TypeId represents (e.g., user, post, etc.). This helps prevent accidental misuse of IDs and aids in understanding the entity type.
- **ULID Suffix**
  - Following the underscore is a 26-character string that represents a ULID. This part ensures the TypeId's global uniqueness and this also makes TypeId's sortable.

This implementations TypeId offers a modern and efficient way to handle globally unique identifiers in a type-safe manner, with enhanced sorting capabilities.
