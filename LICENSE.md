# SNlang — Language Reference & License

<p align="center">
  <img src="SNicon.png" alt="SNlang Icon" width="200">
</p>

---

## A. ABOUT SNLANG
==================

**SNlang** is a programming language created from scratch by **Asish Kumar Sharma**.

### The Motive and Story

The core motive behind SNlang is to explore a lighter syntax for a natively compiled language while reducing repetitive boilerplate in common cases.

Some of the syntax choices in SNlang are:
- `blueprint` in place of `class`
- `from` in place of `extends`
- `ref<T>` for pointer-style values
- `input()` for console input
- Arrow return types such as `-> int` or `-> str`

`snc` is a small programming language compiler written in ARM64 assembly. It reads `.sn` source code and emits ARM64 assembly that can be assembled with `clang`. The source includes a platform macro layer for ARM64 Mach-O output and is currently validated for macOS on ARM64.

---

### Architecture

The compiler is split by responsibility:

- `src/main.s` — entry point, argument handling, source file loading
- `src/lexer.s` — cursor movement, whitespace, and comment skipping
- `src/parser.s` — statements, expressions, conditions, and blocks
- `src/vars.s` — variable storage, constants, assignment, and print records
- `src/codegen.s` — generated ARM64 assembly output
- `src/utils.s` — string matching, error reporting, and write helpers
- `src/data.s` — shared messages, keywords, buffers, and compiler state

The old single-file version is archived at `archive/snc.monolith.s`.

---

### Current Status

Current verified status for this repository:

- Builds on macOS ARM64
- `make assert` passes `200/200` must-pass checks
- `155/162` examples run; the remaining `7` are deliberate negative tests
- The project is a working hobby/portfolio language and compiler, not a self-hosting or production-ready toolchain

---

### Syntax

```sn
fn main() {
    int a = 10
    int b = 4
    int total = a + b * 3
    print(total)
    print(total - 2)
    print((a + b) * 3)
    bool ready = true
    str name = "Asish"
    str greeting = "Hello {name}!"  // String interpolation
    print(greeting)
    if (total >= 20) {
        print(1)
    } else {
        print(0)
    }
}
```

### Module System

SNlang supports module imports:

```sn
use math
use utils.string

fn main() {
    print("Modules loaded successfully")
}
```

### String Interpolation

```sn
fn main() {
    str name = "World"
    int count = 42
    str msg = "Hello {name}! Count: {count}"
    print(msg)  // Prints: Hello World! Count: 42
}
```

**Supported features today:**

- `fn main() { ... }`
- `int name = expression`, `let name = expression;`
- `print(expression)`, `printn(expression)` (no newline)
- Integer numbers, variables, arithmetic (`+`, `-`, `*`, `/`, `%`)
- Parentheses for grouped expressions
- Comparisons: `==`, `!=`, `>`, `<`, `>=`, `<=`
- `if`, `else if`, `else`, `while`, `for`, `for (item in list)`
- `stop`, `skip`
- `bool`, `true`, `false`, `byte`
- `str`, `const str`, `const int`, `const bool`
- String literals and string interpolation `"Hello {name}!"`
- `input("prompt")` for `str` input
- `use module.path` imports
- `match (...) { ... default { ... } }`
- Compound assignments: `+=`, `-=`, `*=`, `/=`, `%=`
- Exponent with `**`
- Functions with parameters and return values, nested and forward calls
- `list<T>` literals and `for in` iteration
- `none`, nullable `?` declarations, `otherwise`
- Default parameters
- Logical `and`, `or`, `not`
- Pointers (`ref<T>`), `alloc()`, `free()`, `value()`, `set()`
- `// line comments`, `/* block comments */`

---

## SNlang OOP Syntax (Zero Boilerplate)

### 1. Blueprints (Classes)

```sn
blueprint Point {
    int x
    int y

    fn print() {
        print("(" + self.x + ", " + self.y + ")")
    }
}
```

### 2. Creating Objects

| Type | Syntax | Variable Type |
| :--- | :--- | :--- |
| Heap | `new Point p(x: 10, y: 20)` | `ref<Point>` |
| Stack | `Point p(x: 10, y: 20)` | `Point` (value) |

```sn
new Point p(x: 10, y: 20)   // Heap allocation
p.print()

Point q(x: 5, y: 15)         // Stack allocation
q.print()
```

### 3. Contracts (Interfaces)

```sn
contract Drawable {
    fn draw()
}

blueprint Circle follows Drawable {
    fn draw() { print("Drawing Circle") }
}
```

### 4. Inheritance

```sn
blueprint Animal {
    str species
    fn describe() { print("I am a " + self.species) }
}

blueprint Dog from Animal {
    str breed
    fn bark() { print("Woof!") }
}
```

### 5. Access Control

| Modifier | Scope |
| :--- | :--- |
| `open` | Public (default) |
| `closed` | Private (blueprint only) |
| `guarded` | Protected (blueprint + children) |

---

## SNlang Concurrency

Current concurrency support includes `spawn fn()`, `wait()`, typed bounded channels, and
typed pthread-backed tasks.
`wait()` joins all outstanding workers and returns the number joined. Channels support
`int`, `bool`, `byte`, and `str` payloads through `.send()`, `.receive()`, and `.close()`.

```sn
chan<int> jobs

fn worker() {
    jobs.send(42)
}

fn main() {
    spawn worker()
    print(jobs.receive())
    print(wait())
    jobs.close()
}
```

Typed tasks use `task<int|bool|str> t = async function()` and `await(t)`. The task API also
provides `task_state(t)`, `task_error(t)`, `task_wait(t, milliseconds)`, `cancel(t)`, and
worker-side `cancel_requested()`. A `scope { ... }` block joins all child tasks before
normal exit. The initial task form accepts zero-argument functions; cancellation is
cooperative, and cleanup-bypassing control flow is rejected inside a task scope.

```sn
fn worker() -> int {
    while (not cancel_requested()) {}
    return 7
}

fn main() {
    scope {
        task<int> work = async worker()
        if (not task_wait(work, 1)) { cancel(work) }
        print(await(work))
    }
}
```

The following forms are planned / not yet implemented: `spawn { ... }` blocks,
`spawn obj.method()`, and general language-level `lock` syntax.

### Joinable `spawn` example

```sn
fn worker() {
    print("Working in background")
}

fn main() {
    spawn worker()
    print(wait())
}
```

---

## SNlang Advanced Features

### Generics

```sn
blueprint Box<T> {
    T value
    fn get() -> T { return self.value }
}

new Box<int> intBox(value: 42)
new Box<str> strBox(value: "Hello")

print(intBox.get())   // 42
print(strBox.get())   // Hello
```

### Error Handling

```sn
fn divide(int a, int b) -> int {
    if (b == 0) { throw("Division by zero") }
    return a / b
}

fn safeDivide() {
    result = try divide(10, 0)
    catch (e) {
        print("Error: " + e)
        return 0
    }
    return result
}
```

### Memory & Ownership

```sn
fn printName(&str name) { print(name) }   // Borrow
fn consume(str s) { print(s) }            // Takes ownership

fn main() {
    str name = "Asish"
    printName(&name)    // Borrow: name still valid
    move consume(name)  // Move: ownership transferred
}
```

---

## How To Use It

Write a `.sn` file, then run `snc` to emit ARM64 assembly.

```sn
fn main() {
    int total = 0
    for (i in [1, 2, 3, 4, 5]) {
        if (i == 3) { skip }
        if (i == 5) { stop }
        total += i
    }
    print(total)
}
```

```sh
./snc your_file.sn > out.s
clang out.s -o out
./out
```

You can also explore the `examples/` directory:
- `examples/functions.sn`
- `examples/for_loop.sn`
- `examples/for_in_control.sn`
- `examples/function_scope_shadowing.sn`
- `examples/decimals.sn`
- `examples/test_combined.sn`

---

## Commands

| Command | Description |
| :--- | :--- |
| `make` | Build the compiler |
| `make run` | Emit assembly for the example |
| `make example` | Compile and run the example program |
| `make test` | Run the current language checks |

The repository does not include a local `build.ps1`; the available PowerShell helper is `scripts/remote_mac_build.ps1`, which connects to a Mac to perform the build.

Compile your own program:

```sh
./snc your_file.sn > /tmp/out.s
clang /tmp/out.s -o /tmp/out
/tmp/out
```

On Windows ARM64, the generated assembly expects COFF/Windows-style symbol resolution and `printf` naming automatically when the assembler target is Windows.

---

## Performance

SNlang produces **native ARM64 machine code** — no VM, no interpreter, just direct CPU instructions.

No benchmark figures or cross-language speed comparisons are currently verified in this document, so none are claimed here.

---

Built with ❤️ in ARM64 assembly by **Asish Kumar Sharma**

---

## B. TERMS AND CONDITIONS FOR ACCESSING OR OTHERWISE USING SNLANG
===================================================================

# SNlang Open Source License
**Version 1.0 — 2026**
**Copyright © 2026 Asish Kumar Sharma. All rights reserved.**

---

## Preamble

The SNlang programming language was created and is owned by **Asish Kumar Sharma** (the "Creator"). This license is designed to keep SNlang open, free, and community-driven while protecting the Creator's intellectual ownership and providing a fair path to compensation when SNlang is used to generate significant commercial revenue.

This is a standalone open source license. It draws inspiration from the Apache License 2.0 in spirit but is an independent license document with its own distinct terms.

---

## Definitions

- **"SNlang"** refers to the programming language, its specification, design, compiler, standard library, toolchain, and all associated official software created by Asish Kumar Sharma.
- **"The Work"** refers to any component of SNlang made available under this License.
- **"You"** refers to any individual, company, or legal entity exercising rights under this License.
- **"Contribution"** refers to any modification, addition, bug fix, enhancement, or other work intentionally submitted for inclusion in the Work.
- **"Contributor"** refers to any person or entity that submits a Contribution.
- **"Commercial Use"** refers to use of SNlang in a product or service from which revenue is generated, directly or indirectly.
- **"Qualifying Revenue"** refers to gross annual revenue exceeding $100,000 USD directly attributable to SNlang-based products or services, including but not limited to: compilers, interpreters, IDEs, developer tools, or commercial applications built primarily in SNlang.

---

## 1. Grant of Rights

Subject to the terms and conditions of this License, the Creator hereby grants You a worldwide, royalty-free (subject to Section 4), non-exclusive, perpetual license to:

- **Use** the Work for any personal, educational, research, or commercial purpose;
- **Copy and distribute** the Work or any portion of it;
- **Modify** the Work and create derivative works based upon it;
- **Contribute** improvements, fixes, or extensions back to the official SNlang project.

---

## 2. Creator Attribution and Ownership

### 2.1 Sole Creator
Asish Kumar Sharma is the sole creator, designer, and intellectual owner of the SNlang programming language. This status is permanent and unconditional and cannot be altered by any modification, contribution, fork, or derivative work.

### 2.2 No Ownership Transfer
No Contributor, user, company, or entity — regardless of the extent of their contributions or modifications — may claim, assert, or represent themselves as the creator or owner of SNlang or any substantial portion of its original design.

### 2.3 Contributor Credit
Contributors are encouraged and welcome. Contributors retain credit for their specific contributions (e.g., "Contributor Name contributed X feature"), but such credit does not constitute or imply any ownership of or creation rights to SNlang itself.

### 2.4 End-User Attribution
You are **not required** to display the Creator's name in applications, products, or services you build *using* SNlang. However, any documentation, product description, or public communication that references the SNlang language itself must accurately identify Asish Kumar Sharma as its creator when authorship is mentioned.

---

## 3. Redistribution and Modifications

You may reproduce and distribute copies of the Work or derivative works thereof in any medium, with or without modifications, provided that You meet **all** of the following conditions:

1. You must retain, in all copies and substantial portions of the Work, the original copyright notice:
   > **Copyright © 2026 Asish Kumar Sharma**

2. You must include a copy of this License with every distribution.

3. Any modified files must carry prominent notices stating that You changed them and the date of the change.

4. Modified versions must not remove or obscure the identification of Asish Kumar Sharma as the original Creator of SNlang. A clearly visible statement such as *"Based on SNlang, originally created by Asish Kumar Sharma"* is required in modified distributions.

5. No modified version may claim to be the original SNlang. Modified distributions must use a clearly different name or clearly identify themselves as a fork or derivative.

6. You may not use the SNlang name, logo, or trademarks to endorse or promote your modified version without explicit written permission from the Creator (see Section 5).

---

## 4. Commercial Use and Revenue Share

### 4.1 Free Tier
SNlang may be used freely — including for commercial purposes — by any individual, company, or entity whose **Qualifying Revenue** does not exceed **$100,000 USD per calendar year**. No fee or payment is required under this tier.

### 4.2 Revenue Share Obligation
If You generate Qualifying Revenue exceeding **$100,000 USD** in any calendar year, You are required to pay the Creator a revenue share of **2% of gross Qualifying Revenue** for that year.

### 4.3 What Counts as Qualifying Revenue
Qualifying Revenue includes revenue from:
- Compilers, interpreters, or toolchains for SNlang sold commercially;
- IDEs or developer tools whose primary feature is SNlang support;
- Commercial applications or SaaS products built **primarily** in SNlang;
- Consulting, training, or services offered specifically around SNlang.

Qualifying Revenue **does not** include revenue from products that merely happen to use SNlang as a minor or incidental component.

### 4.4 Payment Terms
- Revenue share payments shall be made **quarterly**, within **30 days** of the end of each calendar quarter.
- Payments shall be accompanied by a written statement of gross Qualifying Revenue for the applicable period.
- Detailed accounting records must be provided to the Creator upon reasonable written request.
- Contact the Creator at the address in Section 9 to arrange payment.

### 4.5 Audit Rights
The Creator reserves the right, upon 30 days' written notice, to audit relevant financial records of any entity believed to have Qualifying Revenue, no more than once per calendar year.

---

## 5. Trademark and Branding

### 5.1 Trademarks
"SNlang" and any associated logos or marks are trademarks of Asish Kumar Sharma.

### 5.2 Permitted Uses
You may use the name "SNlang" without prior permission for:
- Describing compatibility with or support for SNlang;
- Educational content, tutorials, and documentation;
- Accurate attribution in software that uses SNlang;
- Academic research and publications.

### 5.3 Uses Requiring Explicit Permission
The following uses require prior written permission from the Creator:
- Using "SNlang" in a company name, product name, or service name;
- Creating a derivative language whose name is substantially similar to "SNlang";
- Using SNlang logos or branding in marketing or promotional materials.

---

## 6. Contributions

### 6.1 Submission
By submitting a Contribution to the SNlang project, You grant the Creator a perpetual, worldwide, non-exclusive, royalty-free, irrevocable license to use, reproduce, modify, distribute, and sublicense your Contribution as part of SNlang.

### 6.2 You retain credit
Contributors retain recognition for their specific contributions. The Creator commits to maintaining contributor acknowledgment in the project's records.

### 6.3 Acceptance
Acceptance of Contributions is at the Creator's sole discretion. Submission does not guarantee inclusion in the official project.

### 6.4 Representation
By submitting a Contribution, You represent that You have the legal right to make the Contribution and that it does not violate any third-party rights.

---

## 7. Patent Rights

Subject to the terms of this License, each Contributor grants You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable patent license to make, use, sell, offer to sell, import, and otherwise transfer the Work, solely for use in compliance with this License.

If You institute patent litigation against any entity alleging that the Work constitutes patent infringement, any patent licenses granted to You under this License for the Work shall terminate automatically as of the date such litigation is filed.

> **Note:** The Creator does not currently hold registered patents over SNlang. No representation is made that the Work is free from third-party patent claims.

---

## 8. Termination

Your rights under this License terminate automatically and without notice if You:

- Fail to comply with any term of this License;
- Fail to make required revenue share payments within the prescribed period;
- Falsely claim ownership or creation rights to SNlang;
- Institute patent litigation against the Creator or Contributors in relation to the Work.

Upon termination, You must cease all use and distribution of the Work. Sections 2, 5, 6, 8, 9, 10, and 11 survive termination.

---

## 9. Disclaimer of Warranty

THE WORK IS PROVIDED **"AS IS"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE WORK IS WITH YOU. SHOULD THE WORK PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

---

## 10. Limitation of Liability

IN NO EVENT SHALL ASISH KUMAR SHARMA OR ANY CONTRIBUTOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE OR INABILITY TO USE THE WORK, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

---

## 11. Contact

For all license matters, including revenue share arrangements, commercial licensing inquiries, trademark permission requests, and contribution agreements, please contact:

**Asish Kumar Sharma**
📧 [your-email@example.com]

---

## Summary (Non-Binding)

| What You Want To Do | Allowed? |
|---|---|
| Use SNlang for personal projects | ✅ Free |
| Use SNlang in a commercial product (< $100k/yr revenue) | ✅ Free |
| Use SNlang in a commercial product (> $100k/yr revenue) | ✅ With 2% revenue share |
| Modify SNlang and distribute your version | ✅ With attribution |
| Contribute to the official SNlang project | ✅ Welcome |
| Claim you created SNlang | ❌ Never |
| Use "SNlang" in your product's name | ❌ Requires permission |
| Remove Asish Kumar Sharma's copyright notice | ❌ Never |

*This summary is for quick reference only. The full license terms above are legally binding.*

---

*SNlang Open Source License v1.0 — Created 2026 by Asish Kumar Sharma*
