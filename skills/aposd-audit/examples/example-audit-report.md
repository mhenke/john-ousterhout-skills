# Design Health Score — src/services/

| # | Dimension | Score | Key Finding | Evidence |
|---|-----------|-------|-------------|----------|
| 1 | Pass-Through Proliferation | 2 | 4 pass-through methods | OrderService:42, PaymentService:88, UserService:15, NotificationService:33 |
| 2 | Information Duplication | 1 | "expired_at" threshold in 3 modules | order-service.js:87, expiry.js:12, config/orders.js:5 |
| 3 | Interface Documentation | 3 | 70% of public methods documented | 7/10 have JSDoc; OrderService.createOrder():55, UserService:12 undocumented |
| 4 | Naming Quality | 3 | 2 vague names | data (order-service.js:15), helper (lib/util.js:103) |
| 5 | Exception Discipline | 4 | 0 custom exceptions, no rethrows | — |
| **Total** | | **13/20** | **Acceptable** | |

## Tactical Tornado Risk

**Risk Level:** Medium — pass-through proliferation across the service layer is a systemic pattern (4 methods in 4 files doing the same thing).

## Executive Summary

- Design Health Score: **13/20** (Acceptable)
- Tactical Tornado Risk: **Medium**
- Total issues found: P0: 0, P1: 2, P2: 1, P3: 1
- Top 3 critical issues:
  1. **P1** — Pass-through methods in every service layer class (4 total across 4 files)
  2. **P1** — "expired_at" business rule duplicated in 3 independent modules
  3. **P2** — 2 vague names ("data", "helper") hide intent

## Detailed Findings by Severity

### [P1] Pass-through proliferation in service layer

- **Location**: OrderService (order-service.js:42), PaymentService (payment-service.js:88), UserService (user-service.js:15), NotificationService (notification-service.js:33)
- **Dimension**: Pass-Through Proliferation
- **Count**: 4 pass-through methods
- **Impact**: Each pass-through is noise — reader must check both the delegator and delegate to understand the actual behavior. Change amplification: renaming `fetchUserById` requires updating both OrderService.getUser() and UserService.fetchUserById().
- **Recommendation**: Remove OrderService.getUser() callers should use UserService.fetchUserById() directly. Apply the same treatment to the other 3 pass-throughs.

### [P1] Business rule duplication — order expiry

- **Location**: order-service.js:87, expiry.js:12, config/orders.js:5
- **Dimension**: Information Duplication
- **Count**: 3 instances of "expired_at" threshold logic
- **Impact**: Changing the expiry window requires finding and updating 3 files. Inconsistency risk: one file could be missed during maintenance.
- **Recommendation**: Define `ORDER_EXPIRY_DAYS = 30` in config/orders.js and import it in order-service.js and expiry.js.

### [P2] Vague naming — "data" parameter

- **Location**: order-service.js:15
- **Dimension**: Naming Quality
- **Count**: 1 instance of `data` as a function parameter
- **Impact**: Reader cannot tell what shape of data is expected without reading the full function body.
- **Recommendation**: Rename to `orderData` or `payload` depending on context.

### [P3] Vague naming — "helper" module

- **Location**: lib/util.js (module named "helper")
- **Dimension**: Naming Quality
- **Count**: 1 instance of `helper` as a module name
- **Impact**: "Helper" gives no indication of what the module does.
- **Recommendation**: Rename to `formatUtils` or `dateUtils` based on actual content.

## Patterns & Systemic Issues

- **Service layer pass-through pattern**: All 4 service classes (Order, Payment, User, Notification) follow the same anti-pattern of thin delegation to a repository layer. This suggests a shared design template is generating these methods.
- **Configuration dispersion**: Business rules are embedded in service logic rather than centralized. The "expired_at" threshold appears in 3 places; other rules may follow the same pattern.

## Positive Findings

- **Exception discipline (4/4)**: No custom exceptions and no catch-and-rethrow patterns. The codebase handles errors cleanly by letting them propagate to a boundary handler.
- **Documentation coverage (3/4)**: 70% of public methods are documented with JSDoc, which is well above typical for a service layer.

## Recommended Actions

1. **[P1]**: Remove pass-through methods in service layer. Callers should use repository methods directly. Files: order-service.js:42, payment-service.js:88, user-service.js:15, notification-service.js:33.
2. **[P1]**: Consolidate "expired_at" business rule into config/orders.js. Update importers: order-service.js:87, expiry.js:12.
3. **[P2]**: Rename `data` parameter to `orderData` in order-service.js:15.
4. **[P3]**: Rename `helper` module to `formatUtils` in lib/util.js.

To fix using APOSD design principles, load the `aposd` skill. It applies the 15 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected dimension so you can focus on one area at a time.

Re-run `aposd audit` after fixes to see your score improve.
