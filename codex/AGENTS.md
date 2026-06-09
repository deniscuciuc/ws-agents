# AGENTS.md

This file defines agent personas and analysis protocols for OpenAI Codex.
Primary use cases: **code analysis, architecture audit, and quality review**.

---

## General Principles

- Be precise and direct — no filler, no disclaimers
- When analysing code, always identify the problem first, then explain, then fix
- Output structured findings: numbered list with severity when reviewing multiple issues
- Severity levels: `[critical]` `[major]` `[minor]` `[suggestion]`
- Never change behaviour while refactoring — flag if a fix requires logic change

---

## .NET Backend Analysis

### Stack Context
ASP.NET Core Minimal API, MediatR/CQRS, FluentValidation, EF Core (writes) + Dapper (reads), .NET 8+

### Audit Checklist
- [ ] Endpoints are thin — no business logic in lambdas
- [ ] All handlers are sealed and use `ISender` (not `IMediator`)
- [ ] `TypedResults` used for all responses
- [ ] `ProblemDetails` returned on all errors
- [ ] Cancellation tokens passed through to all async calls
- [ ] No domain entities exposed in API responses
- [ ] Validation via pipeline behaviour, not inline

### Refactoring Rules
- Extract methods > 20 lines
- Replace primitive obsession with records or value objects
- Flatten nested conditionals with guard clauses
- Replace magic strings/numbers with enums or constants
- Use pattern matching over `if/else` chains
- `record` types for immutable DTOs

---

## .NET Security Audit

### Stack Context
ASP.NET Core 8+, JWT Bearer, OAuth 2.0, OWASP Top 10

### Audit Checklist
- [ ] Auth required on all non-public endpoints
- [ ] Authorisation policies applied per operation
- [ ] Input validated via FluentValidation (no manual validation)
- [ ] No sensitive data in URL parameters
- [ ] Rate limiting configured
- [ ] CORS restricted per origin, not `AllowAnyOrigin()`
- [ ] HTTPS enforced (HSTS + redirect)
- [ ] Security headers: CSP, X-Content-Type-Options, X-Frame-Options
- [ ] No SQL injection vectors (parameterised queries only)
- [ ] No mass assignment / over-posting
- [ ] Error responses generic (no stack traces in production)
- [ ] Dependencies checked for CVEs (`dotnet list package --vulnerable`)

---

## .NET Performance Audit

### Stack Context
ASP.NET Core 8+, EF Core, PostgreSQL, BenchmarkDotNet, OpenTelemetry

### Audit Checklist
- [ ] Async all the way — no sync-over-async (`.Result`, `.Wait()`)
- [ ] Cancellation tokens forwarded to all async calls
- [ ] DbContext pooling configured
- [ ] Queries use projection (`Select`) — no in-memory filtering
- [ ] N+1 queries detected and eliminated
- [ ] Response compression enabled (Brotli/GZip)
- [ ] Output caching on read-heavy endpoints
- [ ] Database indexes match query patterns
- [ ] No excessive allocations in hot paths

---

## .NET Integration Testing

### Stack Context
xUnit, WebApplicationFactory, Testcontainers for .NET, FluentAssertions, Respawn, WireMock

### Audit Checklist
- [ ] Tests use real infrastructure (Testcontainers), not in-memory mocks
- [ ] Database reseeded between tests (not container restart)
- [ ] Tests are idempotent and order-independent
- [ ] One test class per endpoint group
- [ ] Happy path tested for each endpoint
- [ ] Validation failures tested (400)
- [ ] Auth failures tested (401)
- [ ] Forbidden requests tested (403)
- [ ] Not found tested (404)
- [ ] Concurrency conflict handling tested

---

## PostgreSQL Analysis

### Audit Checklist
- [ ] No `SELECT *` in production queries
- [ ] Indexes exist for all `WHERE`, `JOIN ON`, `ORDER BY` columns
- [ ] Partial indexes used for filtered queries
- [ ] No N+1 query patterns
- [ ] `EXPLAIN (ANALYZE, BUFFERS)` reviewed for slow queries
- [ ] Unused indexes identified via `pg_stat_user_indexes`

### Analysis Output Format
For each query or schema issue:
1. **Problem** — what's wrong
2. **Explanation** — why it's slow or incorrect
3. **Fix** — corrected SQL
4. **Expected improvement** — scan type, row estimate change

---

## Python Analysis

### Stack Context
Python 3.11+, Pydantic v2, async SQLAlchemy, Prefect, polars/pandas

### Audit Checklist
- [ ] All functions have type hints
- [ ] No bare `except:` clauses
- [ ] No mutable default arguments
- [ ] No `print()` — `structlog` or `logging` used
- [ ] Pydantic models used for all external data contracts
- [ ] Async functions not mixing sync I/O
- [ ] Prefect tasks have `retries=2` on external I/O

---

## Frontend Architecture Review

### Stack Context
React 18+, TypeScript strict, Vite, shadcn/ui, Tailwind CSS, TanStack Query, Zustand

### Audit Checklist
- [ ] Feature-sliced directory structure — not flat by type
- [ ] No `useEffect` for data fetching (use TanStack Query)
- [ ] No `any` types
- [ ] Components < 150 lines
- [ ] Server state and client state not mixed in same store
- [ ] No prop drilling > 2 levels
- [ ] All components have explicit prop interfaces
- [ ] No inline styles
- [ ] Lazy loading for route-level code splitting
- [ ] Bundle size monitored

---

## Code Review

### Checklist
- [ ] Logic errors or incorrect conditionals
- [ ] Missing null/edge-case handling
- [ ] Resource leaks (connections, file handles)
- [ ] Unvalidated user input reaching sensitive operations
- [ ] Hardcoded secrets or credentials
- [ ] Missing cancellation/error handling
- [ ] Race conditions in async/concurrent code
- [ ] Inefficient algorithms or unnecessary allocations

---

## Distributed Debugging

### Methodology
1. **Reproduce** — get consistent reproduction or capture failure state
2. **Isolate** — determine which service/component is root cause
3. **Trace** — follow request flow across service boundaries (OpenTelemetry)
4. **Root cause** — identify specific code path or config issue
5. **Fix** — propose minimal targeted fix
6. **Verify** — confirm fix resolves the failure

---

## Git / Commit Analysis

### Conventional Commits Format
```
<type>(<scope>): <summary>
```
Types: `feat` `fix` `refactor` `perf` `chore` `docs` `test` `ci` `style`

### Commit Audit
- Summary: imperative, lowercase, ≤ 72 chars, no period
- Each commit = one logical change
- Breaking changes: `feat!:` or `BREAKING CHANGE:` footer

---

## GitLab CI/CD Analysis

### Audit Checklist
- [ ] No secrets hardcoded in `.gitlab-ci.yml`
- [ ] All jobs have explicit `rules:` (no implicit triggers)
- [ ] Jobs have `timeout` defined
- [ ] Artifacts have `expire_in`
- [ ] Shared logic extracted to `include:` templates
- [ ] Production deploy has `when: manual` gate
- [ ] Image versions are pinned (no `latest`)

---

## Docker Compose Analysis

### Audit Checklist
- [ ] All image versions pinned
- [ ] Health checks on all stateful services
- [ ] `restart: unless-stopped` on production services
- [ ] Named volumes for persistent data (no bind mounts for data)
- [ ] Services not running as root
- [ ] Internal network for services not needing external access
- [ ] Secrets not in committed `.env` files

---

## Open-Source Project Health

### Audit Checklist
- [ ] README explains what, why, how, and installation
- [ ] CONTRIBUTING.md with setup and PR instructions
- [ ] Issue templates (bug report, feature request)
- [ ] PR template with checklist
- [ ] LICENSE present and SPDX-compliant
- [ ] CI passes on all PRs before merge
- [ ] Dependencies kept up-to-date (Dependabot/Renovate)
- [ ] Release process documented or automated
- [ ] CHANGELOG maintained
- [ ] Stale bot configured

---

## Observability Engineering

### Stack Context
.NET, Serilog/ILogger, Prometheus-net, OpenTelemetry, structured logging

### Audit Checklist
- [ ] Structured logging with named properties (not string interpolation)
- [ ] No secrets, tokens, or PII logged
- [ ] Log levels correctly applied: Trace/Info/Warning/Error/Critical
- [ ] Metrics present: counters (events), histograms (duration), gauges (state)
- [ ] Instrumentation at middleware, handler, and data-access layers
- [ ] Logs and metrics aligned — error logs increment error counters
- [ ] Performance-aware — verbose logs not in hot paths
- [ ] Sensitive fields redacted from log output

---

## Web Scraping

### Stack Context
Playwright, CSS selectors, HTTP clients, HTML parsers, anti-bot countermeasures

### Audit Checklist
- [ ] Selectors tested on multiple pages (min 3)
- [ ] Explicit waits over sleep() for dynamic content
- [ ] Fallback selectors for unstable pages
- [ ] Error handling for all identified edge cases
- [ ] Rate limiting and anti-bot measures documented
- [ ] Pagination termination conditions defined
- [ ] No hardcoded values that change between pages

---

## Analytics Integration

### Stack Context
PostHog, Mixpanel, Google Analytics, feature flags

### Audit Checklist
- [ ] Event naming consistent (snake_case across the app)
- [ ] No sensitive data captured (passwords, tokens, PII)
- [ ] Tracking doesn't break core functionality
- [ ] Page views via router events, not useEffect
- [ ] Events captured in handlers, not in useEffect reacting to state
- [ ] Rapid events debounced or throttled
- [ ] Analytics client not initialized → queued or retried gracefully

---

## FastAPI Service Architecture

### Stack Context
FastAPI, Python 3.11+, Pydantic v2, SQLAlchemy async, Docker

### Audit Checklist
- [ ] Single responsibility — one service, one purpose
- [ ] Dependency injection for loose coupling
- [ ] Pydantic models for all request/response validation
- [ ] Health check endpoint (/health) present
- [ ] Structured logging configured
- [ ] Rate limiting on production endpoints
- [ ] CORS restricted per origin
- [ ] Environment-based configuration (no hardcoded values)
- [ ] Dockerfile with multi-stage build
- [ ] Tests for critical paths

---

## Python Database Optimization

### Stack Context
Python 3.11+, SQLAlchemy, asyncpg, PostgreSQL, Redis

### Audit Checklist
- [ ] No N+1 queries via SQLAlchemy lazy loading in loops
- [ ] Missing eager loading (joinedload, selectinload)
- [ ] SELECT * when only specific columns needed
- [ ] Missing indexes on foreign keys or filtered columns
- [ ] No pagination on unbounded queries
- [ ] Connection pool exhaustion or improper configuration
- [ ] Transactions spanning user interaction
- [ ] Sync DB calls in async context
- [ ] Missing caching for read-heavy, slow-changing data

---

## Grafana Monitoring

### Stack Context
Grafana, Prometheus, Loki, dashboards, alerting

### Audit Checklist
- [ ] Dashboards have clear hierarchy (system → app → business)
- [ ] Appropriate panel types for each metric type
- [ ] Dashboard variables for filtering (env, service, instance)
- [ ] Every dashboard has a description and owner
- [ ] Alert thresholds documented with runbook links
- [ ] Datasources validated and connected before building
- [ ] Time ranges and refresh intervals appropriate
- [ ] No data appearing → datasource connectivity checked first

---

## Infrastructure Operations

### Stack Context
Docker Compose, Ansible, OpenTofu, Traefik, Cloudflare, CI/CD

### Audit Checklist
- [ ] Infrastructure-as-code for all components
- [ ] All operations idempotent
- [ ] Secrets managed via env vars or vaults — never hardcoded
- [ ] SSH key-only access (no passwords)
- [ ] Firewall configured
- [ ] Automatic security updates enabled
- [ ] Containers not running as root
- [ ] TLS everywhere (Traefik or similar)
- [ ] Regular backup schedule with tested recovery
- [ ] Monitoring and alerting configured

---

## Cross-Stack Incident Diagnosis

### Stack Context
Docker, DNS, TLS, HTTP, cloud platforms, authentication

### Audit Checklist
- [ ] Infrastructure ruled out before diving into app code
- [ ] Simple things checked first: DNS, certificates, credentials
- [ ] Evidence correlated from multiple sources
- [ ] Error messages traced to origin (they can be misleading)
- [ ] Timing correlation with recent changes
- [ ] All layers investigated: app → container → config → network → auth → routing
- [ ] Scope established: all/some users, intermittent/consistent

---

## AI Platform Operations

### Stack Context
Open WebUI, MCP protocol, AI models, Docker

### Audit Checklist
- [ ] Default-deny for tool permissions
- [ ] Read operations separated from write operations
- [ ] Confirmation prompts for destructive operations
- [ ] Circuit breakers and timeouts on all tool calls
- [ ] All tool invocations logged for audit
- [ ] Graceful degradation when tools fail
- [ ] MCP servers tested with direct JSON-RPC before integration

---

## Python Security Audit

### Stack Context
FastAPI/Django, JWT, OAuth 2.0, OWASP Top 10

### Audit Checklist
- [ ] Auth on all non-public endpoints
- [ ] Permission checks per operation
- [ ] Pydantic input validation on all requests
- [ ] Rate limiting configured
- [ ] CORS restricted per origin
- [ ] HTTPS enforced with security headers
- [ ] No SQL injection vectors
- [ ] Error responses generic (no stack traces in production)
- [ ] Dependencies checked for CVEs

---

## Frontend Security Review

### Stack Context
React 18+/19, TypeScript, browser security, OWASP

### Audit Checklist
- [ ] No XSS vulnerabilities (dangerouslySetInnerHTML, unescaped content)
- [ ] CSP headers restrict inline scripts
- [ ] No sensitive data in localStorage/sessionStorage
- [ ] API keys not exposed in client bundles
- [ ] Dependencies audited (npm audit)
- [ ] Third-party scripts use SRI
- [ ] Auth tokens in httpOnly cookies, not localStorage

---

## Frontend Performance Audit

### Stack Context
React 18+/19, Vite, TanStack Query, Lighthouse, Web Vitals

### Audit Checklist
- [ ] Bundle size monitored with visualizer
- [ ] Route-level code splitting with lazy loading
- [ ] No unnecessary re-renders (profile before memoizing)
- [ ] Images lazy-loaded with explicit width/height
- [ ] TanStack Query stale/revalidate configured per use case
- [ ] Third-party scripts loaded async or deferred
- [ ] Core Web Vitals measured: LCP < 2.5s, FID < 100ms, CLS < 0.1
- [ ] Virtualization for large lists
- [ ] First load JS < 150KB gzipped

---

## Frontend Integration Testing

### Stack Context
Playwright, Vitest, Testing Library, MSW

### Audit Checklist
- [ ] Happy path for each page/feature
- [ ] Loading states displayed correctly
- [ ] Error states via MSW (API failure, network error)
- [ ] Empty states tested
- [ ] Auth flows (login, logout, protected routes)
- [ ] Form validation (required fields, invalid input)
- [ ] Responsive layouts tested (mobile, tablet, desktop)
- [ ] Accessibility checks (keyboard nav, screen reader)

---

## ETL Pipeline Architecture

### Stack Context
Python, PostgreSQL/TimescaleDB, Airflow/Prefect, CDC patterns

### Audit Checklist
- [ ] All pipeline stages are idempotent
- [ ] Transaction boundaries prevent partial failures
- [ ] Error handling with retry for transient failures
- [ ] Data validation at each stage (schema, null rates, row counts)
- [ ] Incremental loads preferred over full refresh
- [ ] Alerting on pipeline failures or SLA breaches
- [ ] Rollback and recovery procedures documented

---

## BI Analytics Architecture

### Stack Context
PostgreSQL, Metabase/Grafana, star schema, SQL analytics

### Audit Checklist
- [ ] Star schema: fact tables for measures, dim tables for attributes
- [ ] Consistent naming conventions (snake_case, dim_/fct_/agg_ prefixes)
- [ ] Idempotent transforms — same input, same output
- [ ] Queries use appropriate indexes (EXPLAIN ANALYZE verified)
- [ ] No full table scans on large tables
- [ ] Materialized views for slow-changing aggregate data
- [ ] Time-series queries use partitioning
- [ ] Read replicas for BI queries in production

---

## Release Notes

### Format
Keep a Changelog: Added, Changed, Fixed, Removed, Security, Deprecated
- Each entry links to PR or commit
- Present tense, imperative mood
- Focus on user/developer impact
- Breaking changes highlighted at top

---

## Output Format for Full Audits

When performing a full codebase audit, structure output as:

```
## Audit Report: <module or file name>

### Critical Issues
1. [critical] <description> — <file:line> — Fix: <fix>

### Major Issues
...

### Minor Issues / Suggestions
...

### Summary
- X critical, Y major, Z minor issues found
- Recommended priority: <what to fix first>
```











































## ai-platform-operator Analysis

### Stack Context
- Open WebUI (AI chat platform)
- MCP Protocol (Model Context Protocol)
- Docker Compose (deployment)
- Python (MCP server development)
- AI models (open-source, API-based)
- Prompt engineering and assistant design

### Rules
- **Reproducible deployments**: Infrastructure-as-code for all components
- **Least privilege**: Default-deny model for tool permissions
- **Layered safety**: Input validation → execution isolation → output sanitization
- **Auditability**: All tool invocations logged with sufficient detail
- **Graceful degradation**: Tool failures don't break the assistant

## analytics-integrator Analysis

### Stack Context
- PostHog / Mixpanel / Amplitude / Google Analytics
- Feature flags (PostHog, LaunchDarkly, Unleash)
- React hooks for analytics (usePostHog, useFeatureFlag)
- Event design and naming conventions
- User trait/property management

### Rules
- Event naming: snake_case, consistent across the application
- Capture meaningful user actions — not every interaction
- Include contextual properties (user segment, feature flag state, page URL, error details)
- Never let tracking break core functionality — handle errors gracefully
- Never capture sensitive data (passwords, tokens, PII)
- Batch related events when appropriate
- Events are verbs: `user_signup_completed`, `checkout_step_viewed`
- Properties are context: `plan_type`, `error_code`, `source_page`
- User traits are attributes: `role`, `plan_tier`, `signup_date`
- Avoid over-fetching: only collect properties that will be used
- **Page views**: Use router navigation events, not useEffect
- **Clicks/actions**: Capture in event handlers, not in useEffect reacting to state

## bi-analytics-architect Analysis

### Stack Context
- PostgreSQL / TimescaleDB (analytics database)
- SQL (analytical queries, window functions, CTEs)
- BI tools (Metabase, Grafana, Superset)
- Data modeling (star schema, snowflake, data vault)
- dbt for transformations
- ETL/ELT pipeline patterns

### Audit Checklist
- [ ] Queries use appropriate indexes (check with EXPLAIN ANALYZE)
- [ ] No full table scans on large tables
- [ ] Aggregations use materialized views for slow-changing data
- [ ] Time-series queries use partitioning (TimescaleDB hypertables)
- [ ] Window functions over correlated subqueries
- [ ] CTEs for readability, not performance (unless MATERIALIZED)
- [ ] Pagination or time-bounded queries — no unbounded result sets

## code-reviewer Analysis

### Audit Checklist
- [ ] Logic errors or incorrect assumptions in conditionals
- [ ] Missing null/edge-case handling
- [ ] Resource leaks (connections, file handles, streams)
- [ ] Unvalidated user input reaching sensitive operations
- [ ] Hardcoded secrets, tokens, or credentials
- [ ] Missing or insufficient cancellation/error handling
- [ ] Race conditions in async or concurrent code
- [ ] Inefficient algorithms or unnecessary allocations
- [ ] Missing or misleading log/error messages
- [ ] Test coverage for new logic paths

## cross-stack-incident-debugger Analysis

### Stack Context
- Linux (systemd, processes, filesystem)
- Docker / Docker Compose
- DNS, TLS/SSL, HTTP, TCP/IP
- Reverse proxies (Traefik, Nginx, Caddy)
- Cloud platforms (AWS, GCP, DigitalOcean, Hetzner)
- Authentication (OAuth, JWT, LDAP, Authentik)

### Rules
- Always rule out infrastructure before diving into app code
- Don't assume cloud defaults are configured correctly
- Check the simple things first: DNS, certificates, credentials
- Correlate evidence from multiple sources — don't trust one log
- Error messages can be misleading — trace to origin
- Stack traces show where exception was caught, not where bug is
- Intermittent issues: look for race conditions, timing, resource contention

## distributed-debugger Analysis

### Stack Context
- OpenTelemetry (traces, metrics, logs)
- Seq / Elastic / Grafana Loki for log aggregation
- Jaeger / Zipkin for distributed tracing
- Prometheus + Grafana for metrics
- Docker Compose for local reproduction

### Audit Checklist
- [ ] Check health endpoints of all services in the chain
- [ ] Search structured logs for correlation ID at each hop
- [ ] Check OpenTelemetry traces for span durations and errors
- [ ] Look for serialization errors at service boundaries
- [ ] Check database connection pool exhaustion
- [ ] Check for timeout differences between services
- [ ] Verify TLS certificates if using HTTPS between services
- [ ] Check for version mismatches in shared contracts/DTOs
- [ ] Verify retry/wait logic hasn't caused cascading failures
- [ ] Check if Docker Compose resource limits are hit (OOM, CPU throttling)

## docker-compose-expert Analysis

### Stack Context
- Docker Compose v2 (`docker compose`, not `docker-compose`)
- Traefik v3 as reverse proxy
- Ubuntu 24.04
- Named volumes for persistence
- Bridge networks for service isolation

### Rules
- One `compose.yml` per service group (not one giant file)
- Use `extends:` or `include:` for shared base configs
- Always pin image versions — no `latest`
- Health checks on every stateful service
- Restart policy: `unless-stopped` for production services
- Named volumes for databases and persistent data
- Bind mounts only for config files
- Never bind mount application code in production

## dotnet-api-architect Analysis

### Stack Context
- ASP.NET Core Minimal API (no Controllers)
- .NET 8+
- MediatR + CQRS pattern
- FluentValidation
- Carter or endpoint groups for organisation

### Rules
- Endpoints are thin — all logic lives in handlers
- One handler per use case (command or query)
- Request/response DTOs are explicit and named clearly
- Validation is declarative, never inline
- Never expose domain entities directly — always map to response models
- Route naming: `noun/verb` pattern avoided, prefer RESTful resource paths
- Use `TypedResults` for explicit response types
- Group endpoints by feature, not by HTTP method
- Always version APIs from day one (`/v1/...`)
- Return `ProblemDetails` on errors (RFC 7807)
- Prefer `IResult` return types with typed overloads

## dotnet-api-implementor Analysis

### Stack Context
- ASP.NET Core Minimal API
- MediatR (IRequest, IRequestHandler)
- FluentValidation (AbstractValidator<T>)
- Mapster or manual mapping (no AutoMapper)
- EF Core for writes, Dapper for reads

### Rules
- Always inject `ISender`, never `IMediator`
- Handlers are `sealed` by default
- Cancellation tokens are always passed through
- No `try/catch` in handlers — use pipeline behaviours
- Repository pattern only if persistence logic is complex

## dotnet-api-integration-test-architect Analysis

### Stack Context
- xUnit / NUnit
- WebApplicationFactory (Microsoft.AspNetCore.Mvc.Testing)
- Testcontainers for .NET (PostgreSQL, Redis, MS SQL, etc.)
- FluentAssertions or Shouldly
- Respawn for database reseeding
- WireMock / TestServer for HTTP stubbing

### Audit Checklist
- [ ] Happy path for each endpoint
- [ ] Validation failures (400 Bad Request)
- [ ] Auth failures (401 Unauthorized)
- [ ] Forbidden requests (403 Forbidden)
- [ ] Not found (404)
- [ ] Conflict / idempotency errors
- [ ] Pagination boundaries
- [ ] Database constraint violations
- [ ] Concurrency conflict handling

## dotnet-api-security-auditor Analysis

### Stack Context
- ASP.NET Core 8+ (Minimal API)
- Authentication: JWT Bearer, OAuth 2.0, OpenID Connect
- Authorization: policies, roles, resource-based
- Data protection, anti-forgery, CSP headers
- OWASP Top 10 for API security

### Audit Checklist
- [ ] Authentication required on all non-public endpoints (globally or per-endpoint)
- [ ] Authorization policies applied, not just authentication
- [ ] Role/permission checks on each operation, not just controller-level
- [ ] Input validated via FluentValidation — no manual validation in handlers
- [ ] No sensitive data in URL parameters (use request body for POST/PUT)
- [ ] Rate limiting configured (FixedWindow or TokenBucket)
- [ ] CORS configured per origin, not `AllowAnyOrigin()` in production
- [ ] HTTPS enforced (HSTS + redirect)
- [ ] Security headers: CSP, X-Content-Type-Options, X-Frame-Options
- [ ] No SQL injection vectors (parameterised queries/EF only)
- [ ] No mass assignment / over-posting (DTOs map only exposed fields)
- [ ] `Antiforgery` enabled for state-changing endpoints if using cookies
- [ ] API keys in production not committed or logged
- [ ] Error responses return generic messages (no stack traces in production)
- [ ] Dependency chain checked for known CVEs (`dotnet list package --vulnerable`)

## dotnet-backend-performance-auditor Analysis

### Stack Context
- BenchmarkDotNet for microbenchmarks
- dotnet-trace, dotnet-counters, dotnet-dump (dotnet diagnostics tools)
- Application Insights / OpenTelemetry
- SQL Server / PostgreSQL query analysis
- k6 / NBomber for load testing
- PerfView / Speedscope for flamegraphs

### Audit Checklist
- [ ] Async all the way — no sync-over-async (`.Result`, `.Wait()`, `Task.Run`)
- [ ] Cancellation tokens forwarded to all async calls
- [ ] No excessive allocations in hot paths (avoid LINQ in tight loops)
- [ ] DbContext pooling configured for ASP.NET Core
- [ ] Queries use projection (`Select`) — no `ToList()` followed by `Where` in memory
- [ ] N+1 query pattern detected and eliminated
- [ ] Compiled queries for repeated EF Core queries
- [ ] Response compression enabled (Brotli/GZip)
- [ ] Output caching configured for read-heavy endpoints
- [ ] Database indexes match query patterns
- [ ] Connection pooling configured on DB client
- [ ] Large object heap allocations minimised

## dotnet-clean-architecture-modernizer Analysis

### Stack Context
- ASP.NET Core Minimal API (legacy Controllers)
- MediatR + CQRS
- Clean Architecture / Hexagonal Architecture
- FluentValidation, ProblemDetails, TypedResults
- Modern C# features (records, pattern matching, primary constructors)

### Rules
- Extract methods and classes to reduce complexity
- Replace primitive obsession with value objects or records
- Eliminate code duplication
- Improve naming (variables, methods, classes)
- Remove dead code and commented-out blocks
- Flatten nested conditionals (guard clauses, early returns)
- Replace magic strings/numbers with constants or enums
- MVC Controllers → Minimal API endpoints
- Business logic in controllers → MediatR handlers
- Implicit status codes → TypedResults
- Inline validation → FluentValidation pipeline
- Fat services → command/query handlers

## dotnet-observability-engineer Analysis

### Stack Context
- ILogger / Serilog for structured logging
- Prometheus-net / OpenTelemetry for metrics
- OpenTelemetry for distributed tracing
- Seq / Elastic / Loki for log aggregation
- Jaeger / Zipkin for tracing
- Grafana for dashboarding

### Rules
- Structured logging with named properties — never string interpolation
- Metrics are actionable and label-aware — not noise
- Never log passwords, tokens, secrets, or full sensitive payloads
- Keep instrumentation overhead low — no excessive allocations in hot paths
- Logs and metrics are aligned — error logs increment error counters

## dotnet-refactorer Analysis

### Stack Context
- Modern C# (.NET 8+), general .NET patterns

### Rules
- Extract methods and classes to reduce complexity
- Replace primitive obsession with value objects or records
- Eliminate code duplication
- Improve naming (variables, methods, classes)
- Remove dead code and commented-out blocks
- Flatten nested conditionals (guard clauses, early returns)
- Replace magic strings/numbers with constants or enums
- One refactoring at a time — never mix refactor + feature
- Always preserve existing behaviour
- Prefer `record` types for immutable data
- Prefer `switch` expressions over `if/else` chains
- Use pattern matching where it improves clarity

## etl-pipeline-engineer Analysis

### Stack Context
- Python (pandas, polars, SQLAlchemy async)
- PostgreSQL / TimescaleDB
- Data pipeline tools (Airflow, Prefect, Dagster)
- Change Data Capture (CDC) patterns
- Slowly Changing Dimensions (SCD)
- BI tools (Metabase, Grafana)

### Audit Checklist
- [ ] All pipeline stages are idempotent
- [ ] Transaction boundaries prevent partial failures
- [ ] Error handling with retry logic for transient failures
- [ ] Alerting on pipeline failures or SLA breaches
- [ ] Data validation at each stage (schema, null rates, row counts)
- [ ] Rollback and recovery procedures documented
- [ ] Incremental loads preferred over full refresh where possible

## fastapi-service-architect Analysis

### Stack Context
- FastAPI, Python 3.11+
- Pydantic v2 (validation, serialization)
- SQLAlchemy (async), databases
- Dependency injection (FastAPI Depends)
- Containerization (Docker)
- Async patterns (asyncio, httpx, aiohttp)

### Audit Checklist
- [ ] Health check endpoint (/health)
- [ ] Structured logging (structlog or loguru)
- [ ] Request validation on all endpoints
- [ ] Consistent error response format
- [ ] Rate limiting on production endpoints
- [ ] CORS configured per origin
- [ ] Environment-based configuration (dev/staging/prod)
- [ ] Dockerfile with multi-stage build
- [ ] Tests for critical paths

## figma-to-code-designer Analysis

### Stack Context
- HTML5 (semantic elements)
- CSS (Grid, Flexbox, Custom Properties)
- Tailwind CSS / shadcn/ui / Bootstrap
- CSS methodologies (BEM, SMACSS) or project conventions
- WCAG 2.1 AA accessibility standards

### Audit Checklist
- [ ] Visual accuracy against Figma design
- [ ] Semantic HTML structure
- [ ] CSS organized, commented, maintainable
- [ ] Responsive at all specified breakpoints
- [ ] WCAG 2.1 AA compliance (contrast, keyboard, screen reader)
- [ ] No unused CSS or inline styles
- [ ] Performance: CSS optimized, images properly sized
- [ ] Cross-browser compatibility in supported browsers

## frontend-architect Analysis

### Stack Context
- React 18+ / 19, TypeScript (strict)
- Vite, TanStack Router, TanStack Query, TanStack Table
- Zustand or Jotai for client state
- shadcn/ui, Radix UI primitives, Tailwind CSS v3/v4
- Playwright for E2E, Vitest for unit
- i18n with react-i18next or similar

### Audit Checklist
- [ ] Bundle size monitored (use `vite-bundle-visualizer`)
- [ ] Lazy loading for route-level code splitting
- [ ] No unnecessary re-renders (memo/useMemo where profile proves it)
- [ ] Images lazy-loaded with proper dimensions
- [ ] TanStack Query stale/revalidate configured per use case

## frontend-coverage-gap-analyst Analysis

### Stack Context
- Vitest + Testing Library
- Playwright (E2E)
- Istanbul/nyc (code coverage reporting)
- React DevTools (component tree analysis)

### Rules
- **Render branches**: Conditional rendering, ternary operators, guard clauses
- **State transitions**: useState, useReducer, context changes
- **Async flows**: Data fetching, loading states, error states
- **User interactions**: Click handlers, form submissions, keyboard events
- **Edge cases**: Empty data, error responses, boundary values
- **Responsive states**: Mobile, tablet, desktop breakpoints
- **Auth states**: Authenticated, anonymous, unauthorized

## frontend-integration-test-architect Analysis

### Stack Context
- Playwright (E2E and component testing)
- Vitest + Testing Library (component integration tests)
- MSW (Mock Service Worker for API mocking)
- TanStack Query testing utilities
- React Testing Library (user-centric queries)

### Audit Checklist
- [ ] Happy path for each page/feature
- [ ] Loading states displayed correctly
- [ ] Error states (API failure, network error)
- [ ] Empty states (no data, no results)
- [ ] Edge cases (large datasets, special characters)
- [ ] Auth flows (login, logout, protected routes)
- [ ] Form validation (required fields, invalid input)
- [ ] Navigation flows (route changes, breadcrumbs)
- [ ] Responsive layouts (mobile, tablet, desktop)
- [ ] Accessibility (keyboard nav, screen reader)

## frontend-performance-auditor Analysis

### Stack Context
- React 18+/19, TypeScript strict
- Vite / Webpack (bundler analysis)
- Lighthouse, Web Vitals (Core Web Vitals)
- TanStack Query, Zustand (state management)
- shadcn/ui, Tailwind CSS
- Vitest / Playwright (testing)

### Audit Checklist
- [ ] Bundle size monitored (vite-bundle-visualizer or webpack-bundle-analyzer)
- [ ] Route-level code splitting with lazy loading
- [ ] No unnecessary re-renders (React.memo/useMemo only where profiled)
- [ ] Images lazy-loaded with explicit width/height
- [ ] TanStack Query stale/revalidate configured per use case
- [ ] No large dependencies imported unnecessarily (tree-shaking verified)
- [ ] Fonts loaded with font-display: swap and subsetting
- [ ] CSS purged (Tailwind JIT handles this)
- [ ] Third-party scripts loaded asynchronously or deferred
- [ ] Core Web Vitals measured: LCP < 2.5s, FID < 100ms, CLS < 0.1
- [ ] API responses cached appropriately (TanStack Query cache)
- [ ] Virtualization for large lists (TanStack Virtual or react-window)

## frontend-security-reviewer Analysis

### Stack Context
- React 18+/19, TypeScript
- Browser security (CSP, CORS, SameSite cookies)
- OWASP Top 10 for web applications
- npm/yarn/pnpm (dependency auditing)

### Audit Checklist
- [ ] No XSS vulnerabilities (dangerouslySetInnerHTML, unescaped user content)
- [ ] CSP headers restrict inline scripts and external origins
- [ ] No sensitive data in localStorage/sessionStorage (tokens, PII)
- [ ] API tokens not exposed in client-side source code
- [ ] All API calls use HTTPS
- [ ] Form data validated client-side before submission
- [ ] No hardcoded secrets in client bundles
- [ ] Dependencies audited for known vulnerabilities (`npm audit`)
- [ ] Third-party scripts loaded with SRI (Subresource Integrity)
- [ ] Authentication tokens stored securely (httpOnly cookies preferred)
- [ ] Proper handling of user-generated content (sanitization)
- [ ] CORS credentials mode set correctly for auth requests

## github-cli-operator Analysis

### Stack Context
- gh CLI (GitHub CLI)
- GitHub REST API v3
- GitHub GraphQL API v4
- GitHub Actions

### Rules
- Prefer GraphQL for complex queries, REST for mutations
- Use `--json` flag for structured output (pipe to jq)
- Authenticate via `gh auth login` — never store tokens in config files
- Use `gh api` as fallback for operations not covered by built-in commands
- JQ for JSON processing: `gh pr view 123 --json files --jq '.files[].path'`

## gitlab-cicd Analysis

### Stack Context
- GitLab CI/CD (`.gitlab-ci.yml`)
- Docker + Docker Compose
- Traefik for reverse proxy
- Linux servers (Ubuntu 24.04)
- SSH-based deployments
- Telegram notifications

### Rules
- Use `include:` for shared templates — never duplicate pipeline logic
- Environments map to branches: `develop` → dev, `staging` → staging, `main` → prod (manual)
- Secrets via masked/protected CI variables — never hardcoded
- Docker images tagged with SemVer + build metadata
- Always define `only`/`rules` explicitly — no implicit triggers
- Use `needs:` for DAG-style parallelism where possible

## gitlab-cli-operator Analysis

### Stack Context
- glab CLI (GitLab CLI)
- GitLab REST API
- GitLab CI/CD (.gitlab-ci.yml)

### Rules
- Use `--output json` for structured output
- Authenticate via `glab auth login` — never store tokens in config files
- Use `glab api` for operations not covered by built-in commands
- Pipeline status checks before merge: `glab mr merge 123 --when-pipeline-succeeds`

## grafana-ops-architect Analysis

### Stack Context
- Grafana (dashboards, alerts, datasources)
- Prometheus (metrics), Loki (logs), Tempo (traces)
- PostgreSQL / TimescaleDB (BI queries)
- Infrastructure monitoring (node_exporter, cAdvisor)

### Rules
- Clear visual hierarchy: system → application → business metrics
- Appropriate panel types for each metric type (time series for trends, stats for current values, tables for lists)
- Logical organization with dashboard variables for filtering (environment, service, instance)
- Consistent color schemes and naming conventions
- Dashboard descriptions explaining purpose and owner
- Links to related dashboards and runbooks
- Define clear threshold-based alerts with severity levels
- Include runbook links in alert notifications
- Use alert grouping to reduce noise (same service, related metrics)
- Test alert conditions before enabling
- Set appropriate evaluation intervals and pending periods

## infrastructure-operator Analysis

### Stack Context
- Docker Compose (multi-service orchestration)
- Ansible (configuration management, server provisioning)
- OpenTofu / Terraform (cloud infrastructure)
- Traefik (reverse proxy, SSL/TLS)
- Cloudflare (DNS, CDN, DDoS protection)
- Authentik / Keycloak (authentication)

### Audit Checklist
- [ ] SSH key-only access (no password auth)
- [ ] Firewall configured (UFW/iptables/nftables)
- [ ] Fail2ban or similar intrusion prevention
- [ ] Automatic security updates configured
- [ ] Docker daemon in rootless mode or with restricted socket
- [ ] Containers not running as root
- [ ] TLS everywhere (Traefik or similar)
- [ ] Audit logging enabled
- [ ] Regular backup schedule with tested recovery
- [ ] Monitoring and alerting configured

## mcp-tools-operator Analysis

### Stack Context
- MCP protocol (stdio, SSE, streaming)
- JSON-RPC 2.0 messaging
- MCP servers: filesystem, GitHub, GitLab, Playwright, memory, context
- Configuration formats: JSON, TOML, YAML

### Audit Checklist
- [ ] Server binary or command available and executable
- [ ] Transport configured correctly (stdio args or SSE URL)
- [ ] Environment variables set for authentication
- [ ] Tool names don't conflict across servers
- [ ] Timeout set per tool (not global)
- [ ] Error handling: server crash → restart, not agent crash
- [ ] Rate limits respected for API-based tools
- [ ] Sensitive parameters redacted from logs

## opensource-maintainer Analysis

### Stack Context
- GitHub ecosystem (issues, PRs, discussions, actions)
- Semantic versioning
- Conventional commits
- CHANGELOG-driven releases

### Audit Checklist
- [ ] README explains what, why, how, and installation
- [ ] CONTRIBUTING.md with setup, test, and PR instructions
- [ ] Issue templates (bug report, feature request, question)
- [ ] PR template with checklist
- [ ] LICENSE file present and SPDX-compliant
- [ ] CI passes on all PRs before merge
- [ ] Dependencies kept up-to-date (Dependabot/Renovate)
- [ ] Release process documented or automated
- [ ] CHANGELOG maintained with keepachangelog format
- [ ] Stale bot configured to close old issues

## postgresql-expert Analysis

### Stack Context
- Query planning and `EXPLAIN (ANALYZE, BUFFERS)`
- Index types: B-tree, GIN, GiST, BRIN, partial, composite
- Index correlation and its effect on sequential vs index scans
- Statistics: `pg_stats`, `pg_statistic`, `ANALYZE`
- Cardinality estimation and planner behaviour
- VACUUM, AUTOVACUUM, bloat management

### Rules
- CTEs for readability on complex queries, not for performance isolation (unless `MATERIALIZED`)
- Prefer `EXISTS` over `IN` for subqueries with large sets
- Use `RETURNING` on writes to avoid extra round-trips
- Window functions over correlated subqueries
- Always specify column list — no `SELECT *` in production

## python-api-integration-test-architect Analysis

### Stack Context
- pytest, pytest-asyncio
- httpx (AsyncClient for API calls)
- Testcontainers for Python (PostgreSQL, Redis)
- pytest-docker or testcontainers for service dependencies
- pytest-mock or unittest.mock (for external HTTP stubs)
- Respawn or custom DB reseeding (table truncation)

### Audit Checklist
- [ ] Happy path for each endpoint
- [ ] Validation failures (422 for Pydantic)
- [ ] Auth failures (401 Unauthorized)
- [ ] Forbidden requests (403)
- [ ] Not found (404)
- [ ] Conflict / idempotency errors
- [ ] Pagination boundaries
- [ ] Database constraint violations
- [ ] Concurrency conflict handling

## python-api-security-auditor Analysis

### Stack Context
- FastAPI / Django REST Framework
- Authentication: JWT Bearer, OAuth 2.0, API keys
- Authorization: permissions, roles, scopes
- Pydantic validation
- OWASP Top 10 for API security

### Audit Checklist
- [ ] Authentication required on all non-public endpoints
- [ ] Authorization/permission checks per operation, not just view-level
- [ ] Input validated via Pydantic — no manual validation in views
- [ ] No sensitive data in URL parameters
- [ ] Rate limiting configured (slowapi or middleware)
- [ ] CORS configured per origin, not `allow_origins=["*"]`
- [ ] HTTPS enforced
- [ ] Security headers configured (CSP, X-Content-Type-Options)
- [ ] No SQL injection vectors (parameterised queries/ORM only)
- [ ] No mass assignment (Pydantic models only expose needed fields)
- [ ] Error responses return generic messages (no stack traces in prod)
- [ ] Dependencies checked for CVEs (`pip-audit` or `safety`)
- [ ] API keys in production not committed or logged

## python-backend-performance-auditor Analysis

### Stack Context
- Python 3.11+ (asyncio, profiling)
- FastAPI / Starlette (async framework)
- SQLAlchemy (async), asyncpg, psycopg3
- Redis / Memcached (caching)
- Profiling (py-spy, cProfile, async-profiler)
- Load testing (locust, k6)

### Audit Checklist
- [ ] Async all the way for I/O-bound operations
- [ ] No blocking calls in async context (use run_in_executor for sync code)
- [ ] Connection pooling configured for database and HTTP clients
- [ ] Queries use proper projections (no SELECT *)
- [ ] N+1 query pattern detected via SQLAlchemy relationships
- [ ] Missing eager loading (joinedload, selectinload)
- [ ] Response compression enabled (Brotli/GZip middleware)
- [ ] Caching configured for read-heavy endpoints (Redis/memoization)
- [ ] Database indexes match query patterns
- [ ] Pagination on all list endpoints
- [ ] No excessive allocations in hot paths
- [ ] Background tasks use proper asyncio patterns

## python-clean-architecture-modernizer Analysis

### Stack Context
- Python 3.11+ (type hints, async/await, dataclasses, match statements)
- FastAPI / Flask / Django
- SQLAlchemy (async), Pydantic v2
- Dependency injection (FastAPI Depends, custom containers)
- Clean Architecture / Hexagonal Architecture

### Rules
- One refactoring at a time — never mix refactor + feature
- Preserve existing behaviour unless bug fix explicitly required
- Prefer incremental improvements over large rewrites
- Maintain testability and dependency inversion
- Keep public contracts stable unless allowed to change

## python-data-engineer Analysis

### Stack Context
- Python 3.11+
- pandas / polars for transformation
- SQLAlchemy (async) for DB access
- Prefect for orchestration
- psycopg3 / asyncpg for PostgreSQL
- pydantic v2 for data validation and schemas

### Rules
- Use polars for large datasets (> 100k rows)
- Use pandas for compatibility or small datasets
- Validate with pydantic before loading
- Bulk inserts with `COPY` or `executemany`
- Always use transactions for multi-step loads
- Idempotent loads — upsert over insert where possible
- One task = one responsibility
- Flow parameters are typed and documented
- Use `result_storage` for large intermediate results
- Always add `retries=2` on external I/O tasks

## python-database-optimizer Analysis

### Stack Context
- Python 3.11+, SQLAlchemy (async), asyncpg, psycopg3
- PostgreSQL (query planning, indexing, partitioning)
- Migration tools (Alembic)
- Caching (Redis, application-level)
- Connection pooling (pgbouncer, SQLAlchemy pool)

### Audit Checklist
- [ ] N+1 queries detected via SQLAlchemy lazy loading in loops
- [ ] Missing eager loading (joinedload, selectinload) for relationships
- [ ] Fetching entire rows when only specific columns needed
- [ ] Missing indexes on foreign keys or frequently filtered columns
- [ ] No pagination on unbounded queries
- [ ] Connection pool exhaustion or improper configuration
- [ ] Scattered database logic without centralization
- [ ] Transaction scope too large causing lock contention
- [ ] Bulk operations not using SQLAlchemy bulk_insert/bulk_update
- [ ] Missing caching for read-heavy, slow-changing data

## python-refactorer Analysis

### Stack Context
- Python 3.11+ (type hints, async/await, dataclasses, match statements)
- FastAPI / Flask / Django
- SQLAlchemy, Pydantic v2
- Testing (pytest, pytest-asyncio)

### Audit Checklist
- [ ] All I/O-bound operations use async/await
- [ ] No `.result()` or blocking calls in async context
- [ ] Database sessions use async SQLAlchemy
- [ ] HTTP clients use httpx.AsyncClient or aiohttp
- [ ] Connection pools are async-compatible
- [ ] Background tasks use proper asyncio patterns (create_task, gather)

## react-developer Analysis

### Stack Context
- React 18+
- TypeScript (strict mode)
- Vite
- shadcn/ui + Radix UI primitives
- Tailwind CSS v3
- TanStack Query (server state)

### Rules
- Functional components only — no class components
- Props interfaces defined with `interface`, not `type` for objects
- One component per file, named export preferred
- Keep components < 150 lines — extract if larger
- Co-locate styles, tests, and types with component
- Server state → TanStack Query (`useQuery`, `useMutation`)
- Global UI state → Zustand
- Form state → React Hook Form
- Local ephemeral state → `useState`
- Never mix server and client state in same store
- Tailwind utility classes — no inline styles
- shadcn/ui for all base components (Button, Input, Dialog, etc.)

## release-notes-writer Analysis

### Rules
- Categories: Added, Changed, Fixed, Removed, Security, Deprecated
- Each entry links to the relevant PR or commit
- Present tense, imperative mood
- Group logically — don't list commits in chronological order
- Focus on user/developer impact, not implementation detail
- Breaking changes highlighted at the top with migration notes

## web-scraper-architect Analysis

### Stack Context
- Playwright (for page analysis and automation)
- CSS selectors, XPath, data attributes
- HTTP clients (aiohttp, httpx, requests)
- HTML parsers (BeautifulSoup, lxml, HtmlAgilityPack)
- Structured data extraction (JSON, CSV, schemas)

### Audit Checklist
- [ ] Page structure analyzed from minimum 3 distinct pages
- [ ] All selectors tested and verified stable
- [ ] Error handling for all identified edge cases
- [ ] Anti-bot considerations documented
- [ ] Integration tests covering happy path + critical edge cases
- [ ] No hardcoded values that change between pages (IDs, timestamps)
- [ ] Rate limiting and throttle configuration documented

## commit-writer Analysis

### Stack Context
- git CLI
- conventional commits
- CLI tools (gh, glab)

### Audit Checklist
- [ ] {'Type matches the change': 'feat, fix, refactor, chore, docs, test, ci, perf'}
- [ ] Scope is lowercase and matches module/file pattern
- [ ] Summary ≤ 72 chars, imperative mood, no period
- [ ] Body explains **why** when non-obvious
- [ ] Breaking changes have `BREAKING CHANGE:` footer or `!` after type
- [ ] No unrelated changes in the same commit
