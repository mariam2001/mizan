# MIZAN

**MIZAN** (Arabic: "balance/scale") is a Spring Boot backend for tracking a
Sharia-compliant EGX (Egyptian Exchange) equity portfolio — opening and closing
positions, recording price snapshots, enforcing compliance and position-limit
rules, and flagging when a monthly rebalance review is due.

This is a learning project built to go deeper on Spring Boot fundamentals than
an earlier project (`library-api`, which used in-memory HTTP Basic auth and
static queries). MIZAN focuses on:

- JWT authentication with database-backed users and roles
- Dynamic, multi-filter search via JPA Specifications
- Schema managed by Flyway migrations from day one (no `ddl-auto=update`)
- Business rules enforced in the service layer, not the database
- Scheduled background jobs (`@Scheduled`)
- Containerized local dev (Docker + docker-compose) and CI (GitHub Actions)

## Status

🚧 Work in progress — see [TODO.md](TODO.md) for current progress and what's
left before the MVP is complete.

## Tech Stack

- Java 21, Spring Boot
- Spring Data JPA + Hibernate
- PostgreSQL
- Spring Security (JWT, stateless, DB-backed users)
- Flyway (schema migrations)
- Lombok
- springdoc-openapi (Swagger UI)
- JUnit 5 + Testcontainers
- Maven
- Docker + docker-compose
- GitHub Actions (CI)

## Domain Overview

| Entity | Purpose |
|---|---|
| `users` | Registered accounts, role (`USER`/`ADMIN`), auto-review preference |
| `stocks` | Stock catalog with sector and Sharia-compliance flag |
| `holdings` | A user's open/closed positions in a stock |
| `price_snapshots` | Manually recorded price history per stock |
| `rebalance_logs` | Audit trail of portfolio reviews (manual or auto) |

### Roles

- **ADMIN** — manages the stock catalog and records price snapshots.
- **USER** — manages their own holdings and portfolio reviews.

### Key Business Rules

- A user may have **at most 2 open holdings** at a time (enforced in the
  service layer inside a transaction, not as a DB constraint).
- Opening a position on a non-Sharia-compliant stock, or attempting a 3rd
  open holding, returns **409 Conflict**.
- All money fields are `BigDecimal` — never `double`/`float`.
- Status/action enums are persisted with `EnumType.STRING`, never `ORDINAL`.
- Rebalance review is manual by default; if a user opts into
  `auto_review_enabled`, a scheduled job may log a `REVIEWED_NO_CHANGE` entry
  after 30+ days of no manual review or holding changes.

## API Endpoints

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login` → returns JWT

### Stocks
- `POST /api/stocks` (ADMIN)
- `PUT /api/stocks/{id}` (ADMIN)
- `DELETE /api/stocks/{id}` (ADMIN)
- `GET /api/stocks` — paginated list
- `GET /api/stocks/search?sector=&compliant=&minPrice=&maxPrice=` — dynamic filter
- `GET /api/stocks/{id}`

### Prices
- `POST /api/prices` (ADMIN) — record a snapshot
- `GET /api/prices/{stockId}/history` — price history

### Holdings (scoped to the authenticated user)
- `POST /api/holdings` — open a position
- `POST /api/holdings/{id}/close` — close a position
- `GET /api/holdings` — list current user's holdings

### Portfolio
- `GET /api/portfolio/summary` — holdings + performance % + rebalance-due flag
- `POST /api/portfolio/review` — manually log a rebalance review
- `PATCH /api/users/me/auto-review` — toggle `auto_review_enabled`

## Getting Started

> ⚠️ Setup is still in progress — see [TODO.md](TODO.md). This section will
> be filled in as the environment comes online.

```bash
docker-compose up -d      # start Postgres
./mvnw spring-boot:run    # run the app
```

Once running, Swagger UI will be available at `/swagger-ui.html`.

## Design Decisions

- `spring.jpa.hibernate.ddl-auto=validate` — schema truth lives in Flyway
  migrations, never in Hibernate auto-DDL.
- Controllers never return entities directly — always response DTOs.
- Price lookups sit behind a service interface so a real EGX data feed can be
  swapped in later without touching calling code.
- Once a Flyway migration has run anywhere, it's never edited — a new one is
  added instead.

## Stretch Goals (post-MVP)

- File upload for trade confirmations (attach a receipt to a holding)
- Live EGX price feed (behind the existing price-service interface)
- Caching for repeated price/portfolio lookups
