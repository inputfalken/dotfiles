## Workflow Orchestration
- Code, comments, app content: English only

## Core Principles
- **Simplicity First:** Every change simple. Min code impact
- **No Laziness:** Root cause. No temp fix. Senior dev standard
- **Minimal Impact:** Touch only needed. No side-effect bugs
- **Stay in scope:** Change specific fn/file → change ONLY that. No refactor around, rename elsewhere, dep updates, unasked "improve". Notice? Mention, don't do
- **Imutability** Prefer immutable. Mutable needed → explicit: normal `Person`, mutable `MutablePerson`. Skip method-level vars, prefix class-level
- **Minimal DB Queries** No redundant DB calls
- **Performance** Simple perf gain via min edits → apply
- **Early-Return** Always early return, error-first.

## C#

### Microsoft Documentation

MCP tools `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search` → MS docs + samples. May newer than training.

Native MS tech (C#, F#, ASP.NET Core, Microsoft.Extensions, NuGet, Entity Framework, `dotnet` runtime) → use for narrow research.

### Comments

- No explanatory comments in written/modified code. Keep existing, or non-obvious *why* (e.g. linked upstream bug/PR). Comment restate code → omit.

### Scope discipline

- Change only asked. No rename spread into EF/DB-scaffolded names, generated files, unrelated modules. No tests/loggers/helper scripts unless asked.
- Change looks like propagate further → STOP, list extra files for approval before edit.

### Naming conventions

- Standard .NET/BCL naming first. No invented verbs (e.g. Retrieve*, Subscribe*) for internal consistency.
- New type/verb prefix → grep solution for existing usages first. Avoid collisions.
- Domain/public service signature + naming rules in backend README → read before rename.

### Files & encoding

- UTF-8 **without BOM**. Preserve line endings (CRLF here).
- Write/Edit tools over Bash/PowerShell heredocs → heredocs mangle regexes + conn strings here.

### Core Principles

- **Bang Operator** No bang. `is`: `if ({boolean VALUE} is false)` not `if (!{boolean VALUE} )`
- **Async** Async overload exists → use
- **Local Static Functions** Prefer when possible, e.g. mapping applied multiple times from one caller.
- **Local Functions** Avoid → lambdas w/ closures.
- **CancelationToken** Always pass CancellationToken in async.
- **Syntax Sugar** Before modify, check latest C# syntax. Apply if 1-1 w/ another change
- **Nested Functions** 1 caller → nested fn. Static bonus → no side effects.
- **Sealed** Sealed whenever possible.
- **Minimal Accessiblity** Min accessibility modifier.
- **Object initializers** Over separate assigns.
  - Yes: `Cat cat = new() { Age = 10, Name = "Fluffy" };`
  - No: `var cat = new Cat(); cat.Age = 10; cat.Name = "Fluffy";`
  - Nested read-only prop → reuse instance: `Settings = { Theme = "Dark" }` (no `new`).
- **Collection initializers** Over separate adds.
  - List: `IReadOnlyCollection<int> x = [1, 2, 3];`
  - Objects: `List<Cat> cats = [new() { Name = "Sasha", Age = 14 }];`
  - Spread: `List<Cat> all = [.. cats, .. moreCats];`
  - Dict: `var n = new Dictionary<int, string> { [7] = "seven", [9] = "nine" };`
  - Read-only collection prop → omit `new List<>`: `Cats = { new Cat { Name = "Sasha" } }`.
- **Extension blocks (C# 14)** `extension(...)` block. No `this`-param. Group methods/props/ops per receiver. Host = non-nested non-generic static class.
- **Nested types (domain)** No prefix soup. Type belong to owner → nest. Scope = owner.
  - Yes: `Person.Address`
  - No: global `PersonAddress`
  - Default access `private`. Apply **Minimal Accessiblity** → widen only if proven outside caller.
  - Nested see owner privates. Full name = `Owner.Nested`.
  ```csharp
  public sealed record Person(string Name, Address Home, ImmutableArray<Contact> Contacts)
  {
      public sealed record Address(string Street, string City);

      public sealed record Contact(string Email, string PhoneNumber);
  }

  var p = new Person("Ada", new Person.Address("1 Rd", "Sthlm"), [new("ada@x.se", "123")]);
  ```
  - Rule: meaningless outside owner → nest. Reused elsewhere → top-level.
  - **Scope: domain layer only.** Domain = pure C#, no framework constraint → nest freely. Other layers (persistence/EF, serialization, API DTO, reflection tools) may break on nested → unknown/tool-specific limits. Outside domain → top-level unless verified safe.
- **Lightweight DTO** Small immutable carrier (few fields, no identity, no inheritance) → `readonly record struct`. Value semantics, no heap. Many fields / ref identity / nullable-by-ref → `sealed record`.


### Testing

.NET unit tests: `WhatToTest_Condition_Expectation` method name.
