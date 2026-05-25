# Worked Examples

## Example 1: Full Critique — ShoppingCartService.java

**Target:** `src/services/ShoppingCartService.java` (127 lines)

### Setup

```bash
node scripts/critique-storage.mjs slug "src/services/ShoppingCartService.java"
# Output: shopping-cart-service
```

### Assessment A: Strategic Thinker Findings

| # | Principle | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Strategic Over Tactical | PASS | `ShoppingCartService` (l12) delegates cart persistence to `CartRepository`, isolating storage from business logic |
| 2 | Deep Modules | VIOLATE | `addItem` body (l34-38) is `validateItem(); repo.save(cart); return Ok;` — three responsibilities in a shallow wrapper |
| 3 | Information Hiding | at-risk | `getTotal` (l56) exposes internal `List<LineItem>` via `.getItems()` getter, leaking cart structure |
| 7 | Better Together | at-risk | `PriceCalculator` and `TaxCalculator` are separate classes called in sequence — merging would reduce pass-through |
| 10 | Define Errors Out of Existence | VIOLATE | `addItem` (l34) returns `null` for "item not found" — callers must null-check everywhere |

**Priority Issues:**
- **P1**: `ShoppingCartService.addItem` (l34-38) conflates validation, persistence, and response formatting in one method
- **P2**: `ShoppingCartService.getTotal` (l56) returns raw `List<LineItem>` — callers must know the internals to compute totals
- **P2**: Null return from `addItem` forces defensive null checks across all call sites
- **P3**: `PriceCalculator` and `TaxCalculator` called in lockstep — sequential pass-through

### Assessment B: Tactical Tornado Findings

**Red flags found (ordered by severity):**

1. **Shallow Module** (HIGH) — `ShoppingCartService` is a pass-through to repository with thin wrappers:
   ```java
   // ShoppingCartService.java:34-38
   public Cart addItem(Cart cart, Item item) {
       validateItem(item);       // delegates
       repo.save(cart);          // delegates
       return cart;              // no abstraction added
   }
   ```

2. **Information Leakage** (MEDIUM) — Line item iteration logic duplicated:
   ```java
   // ShoppingCartService.java:56 — getTotal iterates items
   // CheckoutService.java:22 — also iterates items for shipping calc
   ```

3. **Special-General Mixture** (MEDIUM) — `CartValidator` contains special-case logic for "promo items" that should be in a policy class.

**Tactical Tornado Risk:** Medium — 3 flags found, 0 critical.

### Combined Critique Report

**Tactical Tornado Verdict:** Medium risk. Shallow module pattern dominates — `ShoppingCartService` delegates everything to `CartRepository` without adding abstraction value. Information leakage between `getTotal` and `CheckoutService.shippingCost` duplicates iteration logic.

**Design Principles Score: 13/18 pass** (3 at-risk, 2 violate)

| # | Principle | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Strategic Over Tactical | PASS | CartRepository isolates persistence (l12) |
| 2 | Deep Modules | VIOLATE | addItem is three ops in a shallow method (l34-38) |
| 3 | Information Hiding | at-risk | getItems() leaks List<LineItem> (l56) |
| 4 | Design General-Purpose | PASS | CartRepository.findByUserId is reusable across cart and order flows |
| 5 | Different Layer | PASS | Service vs Repository layers have distinct abstractions |
| 6 | Pull Complexity Downward | at-risk | addItem forces null-check burden on every caller |
| 7 | Better Together | at-risk | PriceCalculator + TaxCalculator called in lockstep |
| 8 | Choose Names | PASS | Naming is clear: addItem, removeItem, getTotal |
| 9 | Design for Reading | PASS | Method bodies are short and sequential |
| 10 | Define Errors Out of Existence | VIOLATE | null return instead of Optional or Result type |
| 11 | Better Together or Better Apart | PASS | CartItem is properly split from Cart |
| 12 | Design It Twice | N/A | Single-shot implementation — no alternative designs evident |
| 13 | Design for the Future | PASS | CartRepository abstracts storage, allowing future cache/DB swap |
| 14 | Increments Are Abstractions | at-risk | addItem mixes validation + persistence + response |
| 15 | Modify Strategically | PASS | Code shows evidence of prior refactoring (extracted CartRepository) |

**What's Working:**
1. Repository pattern cleanly separates storage — `CartRepository` (l12) abstracts the DB, reducing change amplification
2. Method naming is consistent and clear — `addItem`, `removeItem`, `getTotal` communicate intent at a glance
3. Single Responsibility is respected at class level — `ShoppingCartService` owns cart operations, `PaymentService` owns payments

**Priority Issues:**

- **P1: Shallow module in ShoppingCartService.addItem** (l34-38)
  - Principle: Deep Modules
  - Complexity symptom: Change amplification
  - Why: Adding a logging concern requires touching every method
  - Fix: Extract validation → `CartValidator.validate(cart, item)`, delegate persistence → `CartRepository.save(cart)`, keep `addItem` as the orchestration boundary

- **P2: Information leakage via getItems()** (l56)
  - Principle: Information Hiding
  - Complexity symptom: Cognitive load
  - Why: Every caller must know `List<LineItem>` structure
  - Fix: Add `getTotalPrice()`, `getItemCount()`, `getItemsByCategory()` methods so callers never touch the raw list

- **P2: Null return from addItem** (l34)
  - Principle: Define Errors Out of Existence
  - Complexity symptom: Unknown unknowns
  - Why: Callers may forget null check → NPE at runtime
  - Fix: Return `Optional<Cart>` or use a Result type

**Persona Walkthrough:**

*Tactical Tornado:* "If the Tactical Tornado wrote `ShoppingCartService`, they'd pile responsibilities into `addItem` — validation, persistence, response formatting — because adding a new line is faster than designing the abstraction. Three months later, every method has the same pattern and changing the validation logic requires touching all 7 methods."

*Strategic Thinker:* "If the Strategic Thinker were to redesign this, they'd pull the null-return problem into the type system — `CartRepository` returns `Optional<Cart>`, `addItem` returns a Result type. Callers can't forget to handle the error case because the compiler enforces it."

**Questions to Consider:**
- What if `PriceCalculator` and `TaxCalculator` were merged into a single `OrderCalculator` with a stable interface?
- Could the null-return error in `addItem` be eliminated by changing the contract to accept only valid pre-validated items?

### Persist Snapshot

```bash
# Compute trend score: 13/18 pass
APOSD_CRITIQUE_META='{"target":"src/services/ShoppingCartService.java","total_score":13,"p0_count":0,"p1_count":1,"p2_count":2,"p3_count":0}' \
  node scripts/critique-storage.mjs write shopping-cart-service /tmp/critique-body.md
```
