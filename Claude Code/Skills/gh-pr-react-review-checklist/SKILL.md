---
name: gh-pr-react-review-checklist
description: Check a GitHub Pull Request's JavaScript/TypeScript, React, and Next.js changes against a language, React, Next.js, and testing checklist using the gh CLI and provide a prioritized report.
disable-model-invocation: true
---

# GitHub PR React Review Checklist

Review a GitHub Pull Request using the `gh` CLI and check its JavaScript/TypeScript, React, and Next.js changes against the checklists below. This complements `gh-pr-code-review` (general correctness, security, clarity); it does not repeat that review.

## CRITICAL: MANDATORY FIRST STEPS

**YOU MUST follow these steps IN ORDER. DO NOT skip any step:**

### Step 1: Get PR Details (MANDATORY)

Use the `gh` CLI to gather PR information:

- **IF** user provides a PR number → Run `gh pr view <number> --json title,body,changedFiles,reviews,comments`
- **IF** no PR number provided → Run `gh pr view --json title,body,changedFiles,reviews,comments` to get the current branch's PR

DO NOT proceed without PR metadata.

### Step 2: Get Code Diff (MANDATORY)

Get the actual code changes using git:

1. Run `gh pr view <number> --json baseRefName,headRefName` to get the base and head branch names
2. Run `git fetch origin` to ensure remote refs are up to date
3. Run `git diff origin/<baseRefName>...origin/<headRefName>` to get all code changes

This is your primary source of truth for the actual code changes.

### Step 3: Get CI/CD Status (MANDATORY)

Run `gh pr checks <number>` to get CI/CD status.

**CRITICAL WARNINGS:**
- DO NOT attempt to review the PR without completing Steps 1-3 first
- DO NOT use context or memory — use ONLY the output from these commands
- DO NOT modify the PR

### Step 4: Additional Context (Optional)

You MAY read relevant files in the workspace for additional context if needed.

### Step 5: Check Scope (MANDATORY)

If the PR diff contains no JavaScript/TypeScript files (`.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `next.config.*`), output a single line saying there are no JavaScript/TypeScript changes to check, and stop.

### Step 6: Decide Which Checklists Apply (MANDATORY)

- **TypeScript / JavaScript** and **Testing** - always apply.
- **React** - apply when the changed files use React (JSX/TSX, hooks, `react` imports).
- **Next.js** - apply only if `next` is a dependency in `package.json` (read it from the workspace, or from the PR diff if it changed). Note the Next.js major version: caching and rendering defaults differ between versions, so judge caching items against the version the project uses. Apply App Router items to files under `app/`; for files under `pages/`, apply only the router-agnostic items.

### Step 7: Generate Report (MANDATORY)

Provide the review report directly in the chat (do NOT create files).

Review the PR's changes against the applicable checklists below. Only report items that actually appear in the diff.

**Response Guidelines:**

- This skill is report-only. Do NOT modify any files, and do NOT post comments or reviews to the PR
- Only review the lines the PR changed (and the code they directly affect). Do not audit pre-existing code that the PR did not touch
- Use judgment: a checklist item is a prompt to look, not a rule to enforce. Skip items that are not a real problem in context, and prefer a few well-explained findings over a long list of nitpicks
- Use concrete examples with code snippets
- Quote the original code when suggesting changes
- Provide suggested fixes using unified diff format (see below)
- Include up to 3 questions for the PR author if clarification is needed
- **Only include files in the report that have specific suggestions or issues.** Do not create sections for files that look good with no changes needed

---

## TypeScript / JavaScript Checklist (applies to any JS/TS code)

1. **Type escape hatches** - `any`, unchecked `as` casts, non-null `!`, or `@ts-ignore` hiding a real type problem. Fix: narrow the type, validate at the boundary, or use `@ts-expect-error` with a reason.
2. **Unvalidated external data** - API responses, `JSON.parse` results, form data, or URL params typed by assertion. Fix: parse and validate at the boundary (for example with a schema library such as zod).
3. **Floating promises / missing `await`** - Promises that are never awaited or handled, or `forEach(async ...)`. Fix: `await` them, use `Promise.all`, or use a `for...of` loop.
4. **Error handling** - `catch (e)` used as an `Error` without narrowing from `unknown`, or errors swallowed silently. Fix: narrow the error, then rethrow or surface it.
5. **Non-exhaustive unions** - `switch`/`if` chains over a union type with no exhaustiveness check. Fix: add a `never` check so new members fail to compile.
6. **Mutating shared data** - Mutating props, arguments, or module-level objects, or in-place `sort()`/`reverse()` on shared arrays. Fix: copy first (spread, `toSorted()`, `structuredClone`).
7. **Equality and truthiness bugs** - `==`, `if (count)` where `0` is valid, or `||` where `??` is meant. Fix: strict equality and explicit checks.
8. **Weak domain types** - Several booleans or free-form strings standing in for one state. Fix: a union type such as `'idle' | 'loading' | 'error'`.
9. **Bundle weight** - Whole-library imports (utility, icon, or date libraries) or a large dependency added for a small use. Fix: targeted imports or a lighter alternative.
10. **Dead code or leftover debugging** - `console.log`, `debugger`, commented-out code, or unused exports. Fix: delete it.

## React Checklist

1. **Effect used for derived state or events** - A `useEffect` that sets state from other props/state, or that reacts to something a user did. Fix: compute the value during render, or move the logic into the event handler.
2. **Effect dependencies** - Missing dependencies, a disabled `exhaustive-deps` lint rule, or stale closures. Fix: correct the dependency list or use functional state updates.
3. **Effect cleanup** - Subscriptions, timers, listeners, or fetches with no cleanup. Fix: return a cleanup function and cancel or ignore stale requests (`AbortController`).
4. **Rules of Hooks** - Hooks called conditionally, inside loops, or after an early return. Fix: call hooks unconditionally at the top level.
5. **Keys** - Index or random keys on lists that can reorder, insert, or delete. Fix: use a stable ID.
6. **State shape** - Duplicated or derivable state, or nested state updated by mutation. Fix: keep one source of truth, derive the rest, and update immutably.
7. **Memoization** - `useMemo`/`useCallback`/`memo` added with no measurable benefit, or expensive work re-run every render. Fix: remove it, or add it deliberately where it matters.
8. **Context overuse** - Frequently changing values in a broad context, re-rendering large trees. Fix: split the context or keep the state closer to where it is used.
9. **Oversized components** - One component mixing data fetching, state management, and large markup. Fix: extract child components or a custom hook.
10. **Controlled vs. uncontrolled inputs** - `value` with no `onChange`, or a value switching between `undefined` and a defined value. Fix: pick one model and initialize it.
11. **XSS** - `dangerouslySetInnerHTML`, or `href`/`src` built from user input (`javascript:` URLs). Fix: avoid it, or sanitize and validate the input.
12. **Accessibility** - Clickable `div`/`span`, inputs without labels, images without `alt`, or dialogs without focus management. Fix: semantic elements, labels, `alt` text, and focus handling.

## Next.js Checklist (only when `next` is a dependency)

1. **Client boundary too high** - `"use client"` on a layout, page, or large tree when only a small part is interactive. Fix: push the directive down to the interactive leaf component.
2. **Server code or secrets reaching the client** - Secrets or server-only modules imported into a client component, or relying on non-`NEXT_PUBLIC_` env vars in client code. Fix: keep that code server-side and guard it with the `server-only` package.
3. **Server Actions and route handlers as public endpoints** - No authentication or authorization check, no input validation, or trusting IDs sent from the client. Fix: authorize and validate inside every action and handler.
4. **Caching and revalidation** - A mutation with no `revalidatePath`/`revalidateTag`, per-user data rendered statically, or unintended dynamic rendering. Fix: set the caching behavior explicitly, based on the project's Next.js version.
5. **Request waterfalls** - Sequential `await`s of independent data. Fix: `Promise.all`, parallel fetches, or `Suspense` streaming.
6. **Hydration mismatches** - `Date.now()`, `Math.random()`, `window`, or `localStorage` read during render. Fix: move it into an effect or a client-only component.
7. **Route segment files** - New routes missing `loading.tsx`, `error.tsx`, or `not-found.tsx` where they are needed, or an `error.tsx` that is not a client component. Fix: add them.
8. **Framework built-ins** - Raw `<img>`, `<a>`, or manual `<head>` tags where `next/image`, `next/link`, or the Metadata API fit. Fix: use the built-in.
9. **Middleware** - Heavy logic or database calls in middleware, or middleware as the only authorization check. Fix: keep middleware light and re-check authorization where the data is accessed.
10. **Data fetching location** - Client-side `useEffect` + `fetch` for data a Server Component could load. Fix: fetch on the server and pass the data down.

## Testing Checklist

1. **Missing tests** - New components, hooks, or server actions with no tests, especially for error and empty states. Fix: add tests for the behavior.
2. **Queries** - `getByTestId` or class selectors where `getByRole` or `getByLabelText` would work. Fix: query the way a user finds the element.
3. **Testing implementation details** - Assertions on internal state, props, or call counts instead of rendered output. Fix: assert on what the user sees and does.
4. **Async handling** - `waitFor` wrapping a `getBy*` query instead of using `findBy*`, side effects inside `waitFor`, or ignored `act` warnings. Fix: use the async queries and resolve the warnings.
5. **Mocking** - Mocking internal modules or stubbing `fetch` ad hoc. Fix: mock at the network boundary (for example with MSW).
6. **Snapshots** - Large snapshots standing in for real assertions. Fix: assert on the specific output that matters.
7. **Flaky tests** - Real timers or dates, order dependence, or shared global state. Fix: fake timers, fixed dates, and reset state between tests.

---

## Unified Diff Format

When suggesting code changes, use unified diff format:

**Rules:**

- Include the file paths: `--- path/to/file` and `+++ path/to/file` (no timestamps or prefixes)
- Start each hunk with `@@` line indicating line numbers
- Mark removed lines with `-` prefix
- Mark added/new lines with `+` prefix
- Preserve exact indentation and spacing
- Include complete code blocks when editing functions/methods
- To move code: use 2 hunks (1 to delete, 1 to insert)
- To create new files: use `--- /dev/null` to `+++ path/to/new/file`

**Example:**

```diff
--- src/example.js
+++ src/example.js
@@ -10,3 +10,3 @@
 function calculate(x, y) {
-  return x + y;
+  return x * y;
 }
```

---

## Report Format

Structure your review report as follows:

Output the report as normal rendered markdown following the structure below. The code fence below only delimits the template - do not include it in your output or wrap your report in a code fence.

````markdown
# Pull Request React Review Checklist

**PR:** https://github.com/<repo>/pull/<number>

## Overview

Brief description of the JavaScript/TypeScript changes in this PR (one or two sentences), and which checklists applied (e.g. "TypeScript, React, Next.js 15 (App Router), Testing").

## File-Specific Suggestions

### 1. `app/dashboard/page.tsx`

**Priority:** 🔴 SHOULD FIX
**Lines:** 15-20
**Checklist item:** [checklist and item name, e.g. "Next.js: Request waterfalls"]

**Issue:** [Describe the problem]

**Current code:**

```tsx
// Quote the problematic code
```

**Suggested fix:**

```diff
--- app/dashboard/page.tsx
+++ app/dashboard/page.tsx
@@ -15,2 +15,2 @@
-// old code
+// new code
```

### 2. `components/SearchBox.tsx`

**Priority:** 🟡 MEDIUM
**Lines:** 8-10
**Checklist item:** [item name]

**Issue:** [Describe the problem]

[Continue for each file...]

## Cross-Cutting Concerns

### Effects Used to Sync Derived State

**Priority:** 🟡 MEDIUM
**Checklist item:** [item name]

Multiple files share the same problem:

**File:** `components/CartSummary.tsx`

```diff
[diff here]
```

**File:** `components/OrderTotals.tsx`

```diff
[diff here]
```

## Questions for PR Author

1. [Question about unclear logic or missing context]
2. [Question about test coverage]

## Conclusion

**Checklist result:** [No issues found ✅ | Minor issues ⚠️ | Issues need attention ❌]

**Blocking issues:** [None | List them]
````

---

## Priority Levels

Use emoji color-coding for priorities:

- 🟣 CRITICAL - Must fix before merge (security, data loss, breaking changes)
- 🔴 SHOULD FIX - Important issues (bugs, logic errors, significant problems)
- 🟡 MEDIUM - Improvements recommended (code quality, maintainability)
- 🟢 LOW - Nice to have (style, minor optimizations, suggestions)

## Sources

This checklist is a distilled summary of ideas from the React documentation ([Rules of React](https://react.dev/reference/rules), [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)), the [Next.js documentation](https://nextjs.org/docs) (App Router, Server Actions, caching), [typescript-eslint](https://typescript-eslint.io/)'s strict and type-checked rule sets, Kent C. Dodds' [Common mistakes with React Testing Library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library), and Dan Vanderkam's *Effective TypeScript*. Consult them for the reasoning and worked examples behind each item.
