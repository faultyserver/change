# changeset

An early, in-progress of Changesets in Crystal. Inspired by Elixir's [Ecto Changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html).

Initial goals for this implementation include:

  - **Compile Performance:** minimal, linear/constant-time overhead with macros and generated code with respect to the number of usages.
  - **Type safety:** safe, automatic casting of data between types from any input type.
  - **Extensibility:** enabling user-defined types to be added without requiring modifications to the core

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     changeset:
       github: faultyserver/changeset
   ```

2. Run `shards install`


## Usage

This library is too early to have a documented API. In the meantime, check `example.cr` for an example usage.

