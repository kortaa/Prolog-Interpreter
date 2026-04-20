# Prolog

An experimental Prolog-like interpreter written in OCaml with Dune and Menhir.

It provides an interactive REPL for entering queries, asserting clauses into an in-memory database, and exploring solutions through backtracking.

## Features

- Interactive command-line REPL.
- Facts and rules with atoms, variables, and compound terms.
- `assertz(...)` for adding clauses to the database at runtime.
- Query solving with substitution display for variable bindings.
- Backtracking through multiple solutions with `;`.

## Requirements

- OCaml
- Dune 3.10 or newer
- Menhir

Install project dependencies with opam before building.

## Build

```bash
opam install . --deps-only
dune build
```

## Run

```bash
dune exec prolog
```

## Using the REPL

The prompt accepts simple Prolog-style queries.

Example session:

```prolog
prolog ?- assertz(parent(john, mary)).
Saved

prolog ?- parent(john, X).
X = mary
```

If a query has more than one solution, press `;` to ask for the next solution or `.` to stop.

## Syntax

- Atoms start with a lowercase letter, such as `john` or `parent`.
- Variables start with an uppercase letter, such as `X` or `Person`.
- Compound terms look like `parent(john, mary)`.
- Queries end with a period.

## Project layout

- `bin/` - executable entry point and REPL.
- `lib/ast/` - term, clause, and query types.
- `lib/database/` - in-memory clause storage.
- `lib/errors/` - parse and runtime error types.
- `lib/evaluator/` - goal solving and backtracking.
- `lib/lexer/` - tokenization rules.
- `lib/parser/` - grammar definition.
- `lib/parser_interface/` - helpers for parsing strings and files.
- `lib/unify/` - unification logic.
- `test/` - test entry point.

## What should be on GitHub

Commit the source and project metadata:

- `bin/`
- `lib/`
- `test/`
- `dune-project`
- `prolog.opam`
- `README.md`
- `LICENSE`
- `.gitignore`

Do not commit generated or local-only files:

- `_build/`
- `.prolog_history`
- editor swap files or machine-specific caches

## Notes

The current `dune-project` and generated opam metadata still contain placeholder values for the package synopsis, description, homepage, documentation, and maintainer. Replace those before publishing the project publicly.
