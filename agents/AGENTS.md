## Workflow Orchestration
- Code, comments, app content: English only

## Core Principles
- **Simplicity First:** Every change simple. Min code impact
- **No Laziness:** Root causes. No temp fix. Senior dev standard
- **Minimal Impact:** Touch only needed. No side-effect bugs
- **Stay in scope:** Change specific fn/file? Change ONLY that. No refactor around, rename vars elsewhere, update deps, "improve" unasked. Notice? Mention — don't do
- **Imutability** Prefer immutable. Need mutable? Explicit — type normally `Person`, mutable `MutablePerson` mark diff. Skip method-level vars, prefix class-level
- **Minimal DB Queries** DB work? Avoid redundant calls
- **Performance** Added code w/ simple perf gain via min edits? Apply
- **Early-Return** Always early return, error-first.

## C#

### Microsoft Documentation

MCP tools `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search` — search/fetch MS docs + code samples. May newer than training.

Native MS tech (C#, F#, ASP.NET Core, Microsoft.Extensions, NuGet, Entity Framework, `dotnet` runtime) — use for narrow research.

### Core Principles

- **Bang Operator** No bang. Use `is` like `if ({boolean VALUE} is false)` not `if (!{boolean VALUE} )`
- **Async** Use async when avail — async overload exists, use it
- **Local Static Functions** Prefer when possible — e.g. mapping applied multiple times from one caller method.
- **Local Functions** Avoid — use lambdas w/ closures instead.
- **CancelationToken** Always pass CancellationToken in async exec.
- **Syntax Sugar** Before modify, check latest syntax (e.g. latest C#). Apply if 1-1 w/ another change
- **Nested Functions** Prefer nested fn if 1 caller intended. Bonus static → avoid side effects.
- **Sealed** Use sealed whenever possible.
- **Minimal Accessiblity** Use min accessibility modifier.
- **Object initializers** Prefer over separate assigns.
  - Yes: `Cat cat = new() { Age = 10, Name = "Fluffy" };`
  - No: `var cat = new Cat(); cat.Age = 10; cat.Name = "Fluffy";`
  - Nested read-only prop → reuse instance: `Settings = { Theme = "Dark" }` (no `new`).
- **Collection initializers** Prefer over separate adds.
  - List: `IReadOnlyCollection<int> x = [1, 2, 3];`
  - Objects: `List<Cat> cats = [new() { Name = "Sasha", Age = 14 }];`
  - Spread: `List<Cat> all = [.. cats, .. moreCats];`
  - Dict: `var n = new Dictionary<int, string> { [7] = "seven", [9] = "nine" };`
  - Read-only collection prop → omit `new List<>`: `Cats = { new Cat { Name = "Sasha" } }`.
- **Extension blocks (C# 14)** Use `extension(...)` block. No `this`-param. Group methods/props/ops per receiver. Host = non-nested non-generic static class.
- **Nested types (domain)** No prefix soup. Type belong to owner → nest. Scope = owner.
  - Yes: `Person.Address`
  - No: global `PersonAddress`
  - Default access = `private`. Apply **Minimal Accessiblity** above — widen only if proven caller outside.
  - Nested see owner privates. Full name = `Owner.Nested`.
  ```csharp
  public sealed class Person
  {
      public required string Name { get; init; }
      public required Address Home { get; init; }

      public sealed class Address
      {
          public required string Street { get; init; }
          public required string City { get; init; }
      }
  }

  var p = new Person { Name = "Ada", Home = new Person.Address { Street = "1 Rd", City = "Sthlm" } };
  ```
  - Rule of thumb: type meaningless outside owner → nest. Reused elsewhere → top-level.
  - **Scope: domain layer only.** Domain = pure C#, no framework constraint → nest freely. Other layers (persistence/EF, serialization, API DTO, reflection-driven tools) may break on nested types — unknown/tool-specific limits. Outside domain → top-level unless verified safe.


### Testing

.NET unit tests: `WhatToTest_Condition_Expectation` method name format.
