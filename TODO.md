# MIZAN — TODO / Roadmap

Working checklist, grouped by milestone. Check items off as they're done;
add sub-items if a milestone turns out to need more granularity. Keep this
in sync with reality — if a design decision changes, update this file, not
just the code.

## 0. Project Setup
- [x] Spring Initializr skeleton generated
- [ ] Add missing dependencies to `pom.xml`: PostgreSQL driver, `flyway-core`
      + `flyway-database-postgresql`, Lombok, a JWT library, Testcontainers
      (postgres module + junit-jupiter)
- [ ] Initialize git repo, first commit
- [ ] `docker-compose.yml` with a Postgres service
- [ ] Base `application.yml`/`.properties` (datasource, JPA, Flyway config)

## 1. Schema & Entities
- [ ] `V1__init_schema.sql` — `users`, `stocks`, `holdings`,
      `price_snapshots`, `rebalance_logs` (with the `auto_review_enabled`
      column already on `users` before this migration ever runs)
- [ ] JPA entities for all 5 tables, enums as `EnumType.STRING`
- [ ] `ddl-auto=validate` — app boots clean against the Flyway-managed schema

## 2. Auth
- [ ] `User` entity implements Spring Security's user contract (roles, etc.)
- [ ] Password hashing (`PasswordEncoder`)
- [ ] JWT issuing + validation filter chain (stateless)
- [ ] `POST /api/auth/register`
- [ ] `POST /api/auth/login` → returns JWT
- [ ] Role-based method/endpoint security (ADMIN vs USER)

## 3. Stocks (ADMIN-managed catalog)
- [ ] Response DTOs (never return entities from controllers)
- [ ] `POST /api/stocks` (ADMIN)
- [ ] `PUT /api/stocks/{id}` (ADMIN)
- [ ] `DELETE /api/stocks/{id}` (ADMIN)
- [ ] `GET /api/stocks` — paginated
- [ ] `GET /api/stocks/search?sector=&compliant=&minPrice=&maxPrice=` —
      Specifications-based dynamic filter
- [ ] `GET /api/stocks/{id}`

## 4. Prices
- [ ] Price-lookup service sits behind an interface (for future live feed swap)
- [ ] `POST /api/prices` (ADMIN) — record a snapshot (unique per stock+date)
- [ ] `GET /api/prices/{stockId}/history`

## 5. Holdings
- [ ] `POST /api/holdings` — open a position
  - [ ] Max-2-open-holdings check (service layer, `@Transactional`)
  - [ ] Sharia-compliance check → 409 if non-compliant
  - [ ] 3rd open attempt → 409
- [ ] `POST /api/holdings/{id}/close` — close a position
- [ ] `GET /api/holdings` — current user's holdings, open + closed

## 6. Portfolio & Rebalancing
- [ ] `GET /api/portfolio/summary` — holdings + performance % + rebalance-due flag
- [ ] `POST /api/portfolio/review` — manual rebalance review log
- [ ] `PATCH /api/users/me/auto-review` — toggle `auto_review_enabled`
- [ ] `@Scheduled` job: auto-log `REVIEWED_NO_CHANGE` after 30+ days of
      inactivity, only for users with `auto_review_enabled = true`

## 7. Testing
- [ ] JUnit 5 unit tests for service-layer business rules (max-2, compliance)
- [ ] Testcontainers-backed integration tests (repositories, Flyway migration)
- [ ] Controller/security tests (auth required, role enforcement)

## 8. Docker, Docs & CI
- [ ] `docker-compose.yml` covers full local stack (app + Postgres)
- [ ] springdoc-openapi / Swagger UI reachable and endpoints documented
- [ ] GitHub Actions workflow: run tests on every push
- [ ] README "Getting Started" verified against a clean clone

## Stretch Goals (after MVP works end to end)
- [ ] File upload for trade confirmations
- [ ] Live EGX price feed behind the existing price-service interface
- [ ] Caching for repeated price/portfolio lookups
