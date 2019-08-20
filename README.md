# change

An early, in-progress of Changesets in Crystal. Inspired by Elixir's [Ecto Changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html).

What works:

  - `cast` with typecasting of primitive types (nil, booleans, string, ints, floats).
  - `validate_*` for making assertions about fields (currently only `validate_required`).
    - `valid?` method on the changeset to indicate overall validity.
    - `add_error` to add an error to the changeset and mark it as invalid.
  - `get_*` to inspect information about the changeset dynamically.
  - Schema definitions (but this is definitely going to change a lot soon).

Initial goals for this implementation include:

  - **Compile Performance:** minimal, linear/constant-time overhead with macros and generated code with respect to the number of usages.
  - **Type safety:** safe, automatic casting of data between types from any input type.
  - **Extensibility:** enabling user-defined types to be added without requiring modifications to the core

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     changeset:
       github: faultyserver/change
   ```

2. Run `shards install`


## Usage

This library is too early to have a documented API. In the meantime, check `example.cr` for an example usage.

