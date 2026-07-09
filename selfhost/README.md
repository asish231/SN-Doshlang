# `selfhost/` — writing SNlang in SNlang

This directory holds the **first components of a self-hosted SNlang compiler** — i.e.
pieces of `snc` written *in SNlang itself* rather than in hand-written ARM64 assembly.
It is the start of the bootstrap plan in [`../SELF_HOSTING_ROADMAP.md`](../SELF_HOSTING_ROADMAP.md).

The current assembly compiler (`../snc`, ~24k lines of ARM64) is **Stage 0**: the trusted
seed. Everything here is compiled *by* Stage 0.

## What's here

| File | What it is | Roadmap milestone |
|---|---|---|
| `lexer.sn` | A **tokenizer for SNlang, written in SNlang** — reads a `.sn` file and dumps its tokens. | `M3` (started) |
| `sample.sn` | A small SNlang program used as input to the lexer. | — |

## Run it

```sh
make selfhost        # from the repo root
```

That compiles `lexer.sn` with the assembly `snc`, links the result with `clang`, and runs
it on `selfhost/sample.sn`. You can also run it on any `.sn` file:

```sh
./snc selfhost/lexer.sn > /tmp/lexer.s
clang /tmp/lexer.s -o /tmp/lexer
/tmp/lexer path/to/program.sn
```

Output is one token per line, `KIND<TAB>text`, followed by `tokens: N`:

```
ID	fn
ID	main
OP	(
OP	)
OP	{
ID	int
ID	x
OP	=
NUM	42
...
tokens: 79
```

Token kinds: `NUM` (integer), `ID` (identifier/keyword — the parser, not the lexer,
separates keywords), `STR` (string literal), `OP` (one- or two-char operator/punctuation,
including `->`, `==`, `!=`, `<=`, `>=`, `+=`, `++`, `&&`, `||`, `**`).

## Why this is a real milestone (and what it proves)

`lexer.sn` only uses features that are **verified working** in `snc`, and it demonstrates
that the language is now expressive enough to host a compiler front-end:

- `argc()` / `argv(i)` and `file_read(path)` — receive and read the source (added earlier).
- `s[i]`, `s.length()`, `s.slice(start, end)` — scan the source and extract lexemes.
- **`ord(c)`** — the ASCII code of a character, so the lexer can classify digits/letters/
  whitespace. This builtin was added specifically to unblock lexing: SNlang char indexing
  `s[i]` yields a **one-character string**, which by itself cannot be compared numerically.
- functions, `while`, `if`/`else`, `and`/`or`, integer arithmetic — the control flow.

## Known limitations (intentional, for this first stage)

- No float/decimal literal tokens (only integer `NUM`).
- No escape-sequence handling inside string literals (a `"` always closes the string).
- No comment skipping — `//` is tokenized as two `OP /` tokens.
- The lexer classifies `ID` for every identifier; keyword-vs-identifier is a parser concern.

These are the natural next steps for `M3`.

## What comes next

Per the roadmap: build a small SNlang compiler runtime (`M2`: growable vectors, a
string-keyed map, a buffered output writer), then a parser (`M4`), then an ARM64/macOS
emitter + driver (`M5`), then reach full behavioral parity (`M6`) and prove the
**stage1 ≡ stage2 fixed point** (`M7`) — at which point `snc` is self-hosted and new
targets (x86-64, Linux, Windows) become "add a backend", not "rewrite the compiler".
