# Architecture

## Purpose

Describe the system's primary responsibilities and boundaries.

## Boundaries

| Boundary | Input | Output | Owner |
|---|---|---|---|
| Example: API Layer | HTTP request | DTO | api module |
| Example: Domain Layer | DTO | domain model | core module |
| Example: Persistence Layer | domain model | persisted record | store module |

## Data Shape Contracts

- Parse and validate external data at boundaries.
- Convert to internal typed models before crossing module boundaries.
- Keep boundary transformation logic centralized and testable.

## Module Ownership Rules

- One primary responsibility per module.
- No cross-layer shortcuts without explicit architecture update.
- New modules require ownership and boundary documentation.

## Execution Flow

1. Entry:
2. Boundary parse/validate:
3. Core execution:
4. Persistence/output:
5. Event/log emission:

## Refactor Checklist

- [ ] Boundary contracts unchanged or versioned.
- [ ] Ownership map still accurate.
- [ ] Integration tests cover boundary paths.
- [ ] Documentation updated in same change.
