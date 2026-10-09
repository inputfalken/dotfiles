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
- Change propagate further → STOP, list extra files, get approval before edit.

### Naming conventions

- Standard .NET/BCL naming first. No invented verbs (e.g. Retrieve*, Subscribe*) for internal consistency.
- New type/verb prefix → grep solution for existing usages first. Avoid collisions.

### Files & encoding

- UTF-8 **without BOM**. Preserve existing line endings.
- Write/Edit tools over Bash/PowerShell heredocs → heredocs mangle regexes + conn strings.

### Core Principles

- **Bang Operator** No bang. `is`: `if ({boolean VALUE} is false)` not `if (!{boolean VALUE} )`
- **Null Pattern** `is null` / `is not null` / `is { } x` (test + bind). No `== null` / `!= null`.
  - Yes: `if (item is { } x) Use(x);`
  - No: `if (item != null) Use(item);`
- **Expression Trees** Inside `Expression<>`/`IQueryable` lambdas patterns illegal (CS8122) → `== false`, `== null`. Never `!`. Outside → Bang/Null rules apply.
  - Yes: `.Where(x => x.IsDeleted == false)`
  - No: `.Where(x => x.IsDeleted is false)` / `.Where(x => !x.IsDeleted)`
- **Async** Async overload exists → use
- **Declarative** *What*, not *how*. LINQ/collection expressions over manual loops + mutable accumulators. Loop only when LINQ unreadable or proven slower.
  - Yes: `var adults = people.Where(p => p.Age >= 18).Select(p => p.Name);`
  - No: `var adults = new List<string>(); foreach (var p in people) { if (p.Age >= 18) adults.Add(p.Name); }`
- **Materialization** No `ToList()`/`ToArray()` unless intended. Keep `IEnumerable`/`IQueryable`/`IAsyncEnumerable` lazy → compose, materialize once at boundary (return, multiple enumeration, DB round-trip). EF: `ToListAsync` only when query final; stream via `IAsyncEnumerable` when consumer iterates once.
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
- **Closed Variants** `abstract record Base` + nested `sealed record Case(...) : Base`. Consume via switch expression, discard arm throws `InvalidOperationException`. Never `_ => default`, never `ArgumentOutOfRangeException`.
  - Yes: `public abstract record Shape { public sealed record Circle(double Radius) : Shape; public sealed record Rectangle(double Width, double Height) : Shape; }`
- **Enum Values** Serialized/persisted/contract enum → explicit int, start 1, `0` = unset. Blank line between members. Never renumber/delete used value → keep + `[Obsolete]`. Internal-only enum → implicit OK.
  - Yes: `enum Status { Active = 1, Archived = 2 }`
  - No: `enum Status { Active, Archived }`
- **Primary Constructors** Default. Explicit ctor only when field derived (options, factory). Interface members explicit `public`.
- **Generated Code** Never edit `<auto-generated>`/scaffolded files. Additions → sibling `partial` `<Type>.<Purpose>.cs`, same namespace.


### Testing

.NET unit tests: `WhatToTest_Condition_Expectation` method name.

## T-SQL

### Core principles

- **Declarative** *What*, not *how*. Set-based over row-by-row. CTEs + window fns (`ROW_NUMBER`, `SUM() OVER`, `LAG`/`LEAD`) over cursors, `WHILE` loops, temp-table shuffling.
  - Yes: `WITH Ranked AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY CreatedAt DESC) AS Rn FROM Orders) SELECT * FROM Ranked WHERE Rn = 1;`
  - No: cursor over customers → `SELECT TOP 1` per row.
- **Keywords** UPPERCASE. Identifiers as-named.
- **Not strict** Loop/procedural only when set-based unreadable or proven slower. Explain why in PR, not comment.
- **Naming** Plural PascalCase tables. Surrogate PK `Id INT IDENTITY(1,1)`. 1:1 child → owner key as PK + FK.
- **Named Constraints** Never system-named. `PK_<Table>`, `FK_<Child>_<Parent>`, `UQ_<Table>_<Col>`, `IX_<Table>_<Col>`, `DF_<Table>_<Col>`, `CK_<Table>_<Rule>`, `TR_<Table>_<Purpose>`. PK `PRIMARY KEY CLUSTERED`. Inline in `CREATE TABLE`. Rename table → rename its constraints.
  - Yes: `CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Foo_CreatedAt DEFAULT SYSUTCDATETIME()`
  - No: `CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()`
- **Rename In Place** `sp_rename` (`N'COLUMN'`/`N'INDEX'`/`N'OBJECT'`) over drop + recreate.
