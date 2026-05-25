# Troubleshooting

| Problem | Cause | Fix |
|---------|-------|------|
| Skill doesn't trigger on refactoring | Description says "writing, reviewing, or modifying any code" | Verify the agent reads the skill description. Refactoring is "modifying" — trigger is correct. |
| Skill input is ambiguous | Task doesn't clearly match a design scenario | Falls through silently — no APOSD behavior applied. Normal agent behavior proceeds. |
| Skill cannot complete its task | Non-design task (e.g., "write a bash script") | Returns no output. Normal agent behavior takes over. |
| Agent over-applies all 15 rules rigidly | Treating principles as checklist instead of lens | Use the complexity lens: rules that reduce cognitive load in this context apply; rules that don't add value can be skipped. |
| Caller complexity not reduced after applying a rule | Rule was applied to the module body, not the interface | Revisit: if the caller's code didn't get simpler, the rule was applied at the wrong level. The interface contract must change. |
| Two principles conflict (e.g., General-Purpose vs Simplicity) | Principles have inherent tension | Resolve via the complexity lens: the option that reduces cognitive load more for future readers wins. Document the tradeoff. |
| User repeatedly rejects strategic recommendations | User has tactical time constraints | Document the tradeoff, proceed tactically, and note the deferred design debt. Do not keep re-proposing strategic alternatives. |
| Change invalidates an existing comment | Comment was tied to old design | Update the comment to reflect the new design. If the comment is now irrelevant, delete it. Comments near changed code must be accurate. |
| Multiple redesign rounds without convergence | Design exploration without evaluation criteria | Compare each alternative against the same criteria (interface simplicity, caller complexity, change impact). If no alternative is clearly better, the criteria are wrong — redefine them. |
