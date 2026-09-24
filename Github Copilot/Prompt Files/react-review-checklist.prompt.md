---
description: "React Review Checklist"
agent: agent
---

# React Review Checklist

## Goal

Provide a focused second-pass report for uncommitted JavaScript/TypeScript, React, and Next.js changes, checking them against the checklists below. This complements `local-code-review` (general correctness, security, clarity); it does not repeat that review. The report lists checklist items the developer should address.

## CRITICAL: MANDATORY FIRST STEP

**YOU MUST run `git diff HEAD` as your ABSOLUTE FIRST action before doing ANYTHING else.**

- DO NOT attempt to review code from context or memory
- DO NOT skip this step under any circumstances
- DO NOT proceed to the next step without running this command first
- DO NOT assume you know what changed

If you do not run `git diff HEAD` first, you are failing to follow instructions.

## Process

Follow these steps IN ORDER. DO NOT skip any step:

1. **STEP 1 - Get Changes via Git (MANDATORY):** Run `git diff HEAD` in the terminal to retrieve ALL uncommitted changes. This is your primary source of truth for what to review. You can read existing files in the current directory for additional context if needed.
2. **STEP 2 - Check Scope:** If the diff contains no JavaScript/TypeScript files (`.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `next.config.*`), output a single line saying there are no JavaScript/TypeScript changes to check, and stop.
3. **STEP 3 - Decide Which Checklists Apply:**
   - **TypeScript / JavaScript** and **Testing** - always apply.
   - **React** - apply when the changed files use React (JSX/TSX, hooks, `react` imports).
   - **Next.js** - apply only if `next` is a dependency in `package.json` (read it). Note the Next.js major version: caching and rendering defaults differ between versions, so judge caching items against the version the project uses. Apply App Router items to files under `app/`; for files under `pages/`, apply only the router-agnostic items.
4. **STEP 4 - Choose Review Mode:** Check the size of the diff with `git diff HEAD --shortstat`. If it touches more than 15 files or more than 800 changed lines, or the user asked for subagents, use **parallel subagents** as described in **Large Reviews: Parallel Subagents** below. Otherwise, or if the user asked not to use subagents, review it yourself in a single pass.
5. **STEP 5 - Generate The Report:** Review the changes against the applicable checklists and generate the report in markdown format. Only report items that actually appear in the diff. Rate each finding in terms of priority using the emoji system. Do not save the report in the filesystem. You should only output to chat.

## Instructions

1. This skill is report-only. Do NOT modify any files. The developer can run `local-code-review` if they want fixes applied.
2. Only review the lines that changed (and the code they directly affect). Do not audit pre-existing code that the diff did not touch.
3. You can read files in the current directory if you need more context (for example, `package.json`, `tsconfig.json`, or an existing test for the component).
4. When you give suggestions, please provide concrete example(s).
5. When suggesting changes related to a code block, please quote the code block.
6. In the report, you can also list a few questions if there are ambiguities.
7. **Only include files in the report that have specific suggestions or issues.** Do not create sections for files that look good with no changes needed.
8. Use judgment: a checklist item is a prompt to look, not a rule to enforce. Skip items that are not a real problem in context, and prefer a few well-explained findings over a long list of nitpicks.

## Large Reviews: Parallel Subagents

Follow this section only if you chose parallel subagents in the "Choose Review Mode" step. If you chose a single pass, ignore this section and review the changes yourself.

**Split the work.** Launch one subagent per applicable checklist from the "Decide Which Checklists Apply" step: TypeScript / JavaScript, React, Next.js, and Testing. If only one unit applies, do not use subagents - review it yourself.

**Brief each subagent.** Subagents do not see this conversation, so each prompt must be self-contained. Include:

- Its unit: the topic name and description, or the full text of its checklist section, copied from this file
- The exact command to get the diff (with branch names or the PR number filled in) and the list of changed files
- The rules: review only the changed lines (and the code they directly affect); read other files only for context; do not modify files, post comments or reviews, or run scanners; never repeat secret values - mask them
- The return format below

**Return format.** Ask each subagent to return only a list of findings, each with: file, lines, priority (using this skill's priority emojis), topic or checklist item, the issue or risk, the quoted code, and a suggested fix as a unified diff. If it finds nothing, it returns exactly `No findings`.

**How to launch them on this platform.** Use the `runSubagent` tool (part of the `agent` tool set), one call per unit, run in parallel. Wait for all of them to return before merging. If the tool is not available (for example, it is not enabled in the tools picker), use the fallback below.

**Merge the results.** Once every subagent has returned:

1. Check each finding against the diff yourself, and drop any that are not on changed lines or that you cannot confirm.
2. Merge duplicates: when several subagents flag the same file and lines, keep one finding with the highest priority and note all the topics.
3. Write a single report in the Report Format below, and mention in its opening description that the review was split across N subagents.
4. Only you continue after the report (for example, applying fixes). Subagents never edit files, so their work cannot conflict.

**Fall back instead of failing.** If this platform has no subagent tool, the tool is disabled, or launching fails, review everything yourself in a single pass as usual. If some subagents fail or return nothing usable, review those units yourself and continue. The review must always complete.

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

## Audience

1. The audience of this report is the PR reviewer. Please make sure it's easy to follow. Usually, the reviewer also doesn't have all the context.
2. Use emoji color-coding for priority levels:
   - 🟣 SHOULD FIX (purple) - Critical issues that must be addressed
   - 🔴 HIGH (red) - Important issues that should be addressed
   - 🟡 MEDIUM (yellow) - Nice-to-have improvements
   - 🟢 LOW (green) - Minor suggestions or style preferences

## Report Format

The report should follow this format:

Output the report as normal rendered markdown following the structure below. The code fence below only delimits the template - do not include it in your output or wrap your report in a code fence.

````markdown
# Description

(Describe what the JavaScript/TypeScript changes are about in one or two sentences, and which checklists applied, e.g. "TypeScript, React, Next.js 15 (App Router), Testing".)

# Specific Suggestions

1. File: (file 1 path)
   Priority: 🟣 SHOULD FIX
   Checklist item: (checklist and item name, e.g. "React: Effect used for derived state or events")
   Line 3-5:
   (suggestion here)

Suggested changes: (if there are any)
(suggested changes here - use Unified Diff)

2. File: (file 2 path)
   Priority: 🔴 HIGH
   Checklist item: (item name)
   Line 5-6:
   (suggestion here)

(Note: Only include files that have specific suggestions. Omit files with no issues.)

# General Suggestions

(If there are suggestions that are related to many files. List them here)

1. (Suggestion title here)
   Priority: 🟡 MEDIUM
   Checklist item: (item name)

File 1: (file path)
(Write what should be changed here)

File 2: (file_path)
(Write what should be changed here)

# Questions

(If there are questions for the PR owner, list them here)

# Conclusion

- Checklist result: (No issues found/Minor issues/Issues need attention)
- Blocking issues: (None/List them)
````

## Sources

This checklist is a distilled summary of ideas from the React documentation ([Rules of React](https://react.dev/reference/rules), [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)), the [Next.js documentation](https://nextjs.org/docs) (App Router, Server Actions, caching), [typescript-eslint](https://typescript-eslint.io/)'s strict and type-checked rule sets, Kent C. Dodds' [Common mistakes with React Testing Library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library), and Dan Vanderkam's *Effective TypeScript*. Consult them for the reasoning and worked examples behind each item.
