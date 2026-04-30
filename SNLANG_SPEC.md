# SNlang — The SafarNow Language

**Version:** 0.2  
**Created by:** SafarNow  
**Paradigm:** Compiled, Strongly-Typed, Object-Oriented, Concurrent  
**Philosophy:** The speed of C, the OOP of Java, the simplicity of Go — with zero confusion.

SNlang compiles directly to native ARM64 machine code. No semicolons. Curly braces `{}` for blocks (easy transition to Java/C++). English-readable logic. Simplified pointers. The programmer builds everything from scratch using clean, powerful primitives.

---

## 1. Comments

```text
// This is a single-line comment

/*
   This is a multi-line comment.
   Use it for documentation.
*/
```

---

## 2. Data Types

SNlang enforces strict typing. Every variable must declare its type.

### Primitive Types

| Type       | Description                          | Example                  |
|------------|--------------------------------------|--------------------------|
| `int`      | Whole numbers (64-bit signed)        | `int age = 25`           |
| `dec(X)`   | Decimal with X digits precision      | `dec(2) price = 99.50`   |
| `str`      | Text / string of characters          | `str name = "Alice"`     |
| `bool`     | True or false                        | `bool active = true`     |
| `byte`     | Single byte (0–255)                  | `byte flag = 0xFF`       |

### Collection Types

| Type          | Description                             | Example                              |
|---------------|-----------------------------------------|--------------------------------------|
| `list<T>`     | Ordered collection of type T            | `list<int> scores = [90, 85, 70]`    |
| `map<K, V>`   | Key-value pairs                         | `map<str, int> ages = {"Bob": 30}`   |

### Special Types

| Type       | Description                          | Example                  |
|------------|--------------------------------------|--------------------------|
| `none`     | Represents no value / null           | `return none`            |
| `any`      | Accepts any type (use sparingly)     | `any data = 42`          |

---

## 3. Constants

Constants are immutable. Once set, they can never change.

```text
const int MAX_USERS = 1000
const str APP_NAME = "SafarNow"
const dec(2) TAX_RATE = 18.00
```

---

## 4. Variables & Assignment

```text
int count = 0
str greeting = "Hello"
bool isReady = false

// Reassignment (same type only — strict!)
count = 10        // OK
count = "hello"   // ERROR: type mismatch
```

---

## 5. Operators

### Arithmetic

| Operator | Description    | Example         |
|----------|----------------|-----------------|
| `+`      | Addition       | `x + y`         |
| `-`      | Subtraction    | `x - y`         |
| `*`      | Multiplication | `x * y`         |
| `/`      | Division       | `x / y`         |
| `%`      | Modulo         | `x % 2`         |
| `**`     | Power          | `x ** 3`        |

### Comparison

| Operator | Description          | Example       |
|----------|----------------------|---------------|
| `==`     | Equal to             | `x == 5`      |
| `!=`     | Not equal to         | `x != 5`      |
| `>`      | Greater than         | `x > 5`       |
| `<`      | Less than            | `x < 5`       |
| `>=`     | Greater or equal     | `x >= 5`      |
| `<=`     | Less or equal        | `x <= 5`      |

### Logical (English words, not symbols!)

| Operator | Description          | Example                    |
|----------|----------------------|----------------------------|
| `and`    | Both must be true    | `x > 0 and x < 100`       |
| `or`     | Either can be true   | `x == 0 or x == 1`        |
| `not`    | Negation             | `not isReady`              |

### Assignment Shortcuts

| Operator | Description           | Example      |
|----------|-----------------------|--------------|
| `+=`     | Add and assign        | `x += 5`     |
| `-=`     | Subtract and assign   | `x -= 5`     |
| `*=`     | Multiply and assign   | `x *= 2`     |
| `/=`     | Divide and assign     | `x /= 2`     |

---

## 6. Blocks — Curly Braces `{}`

SNlang uses curly braces `{}` for all block scoping. This keeps the language familiar to anyone coming from or going to Java, C++, or Go. No semicolons are needed — each statement is one line.

```text
fn main() {
    print("Hello")
}
```

---

## 7. Control Flow

### If / Else If / Else

Parentheses are **required** around conditions. Curly braces define blocks.

```text
if (age >= 18 and age < 60) {
    print("Adult")
} else if (age >= 60) {
    print("Senior")
} else {
    print("Child")
}
```

### Match (Switch-Case Alternative)

Clean pattern matching. No `break` needed — only the matched arm executes.

```text
match (status) {
    "active" {
        print("User is active")
    }
    "banned" {
        print("User is banned")
    }
    default {
        print("Unknown status")
    }
}
```

---

## 8. Loops

### For Loop (Counted)

Uses the standard `for` keyword — easy to transfer skills to Java/C++.

```text
for (int i = 0, i < 10, i += 1) {
    print(i)
}
```

### For-In Loop (Iterate Collections)

Same `for` keyword with `in` to iterate over collections.

```text
list<str> fruits = ["Apple", "Mango", "Banana"]

for (fruit in fruits) {
    print(fruit)
}
```

### While Loop

```text
int attempts = 0

while (attempts < 3) {
    print("Trying...")
    attempts += 1
}
```

### Loop Control

| Keyword   | Description                         |
|-----------|-------------------------------------|
| `stop`    | Exits the loop immediately (break)  |
| `skip`    | Skips to next iteration (continue)  |

```text
for (num in [1, 2, 3, 4, 5]) {
    if (num == 3) {
        skip
    }
    if (num == 5) {
        stop
    }
    print(num)
}
// Output: 1, 2, 4
```

---

## 9. Functions

Use `fn` to declare functions. Return types are declared after `->`.

```text
fn greet(str name) -> str {
    return "Hello, " + name
}

fn add(int a, int b) -> int {
    return a + b
}

// Functions with no return value
fn logMessage(str msg) {
    print("[LOG] " + msg)
}
```

### Default Parameters

```text
fn connect(str host, int port = 8080) {
    print("Connecting to " + host)
}

connect("localhost")         // Uses port 8080
connect("localhost", 3000)   // Uses port 3000
```

### Multiple Return Values (like Go!)

```text
fn divide(int a, int b) -> (int, bool) {
    if (b == 0) {
        return (0, false)
    }
    return (a / b, true)
}

int result, bool ok = divide(10, 3)

if (not ok) {
    print("Division failed!")
}
```

---

## 10. Pointers & Addresses (Simplified)

SNlang gives you direct memory access like C, but makes it **much simpler and safer**. No confusing `*`, `&`, `->` juggling.

### Declaring a Pointer

Use `ref<T>` (reference) to declare a pointer to a type. It reads like English: "a reference to an int."

```text
int x = 42
ref<int> p = address(x)    // p holds the memory address of x
```

### Reading the Value at an Address

Use `value(p)` to dereference — get the data the pointer points to.

```text
int y = value(p)    // y = 42
```

### Writing to an Address

```text
set(p, 100)         // The memory at p now holds 100
print(value(p))     // 100
print(x)            // 100 — x changed because p points to x
```

### Pointer Arithmetic

Move through memory manually. Essential for building your own data structures.

```text
ref<byte> start = address(buffer)
ref<byte> next = start + 1      // Move 1 byte forward
ref<byte> tenth = start + 10    // Move 10 bytes forward

byte val = value(next)          // Read the byte at that address
```

### Allocating Raw Memory

Use `alloc(bytes)` to request raw memory from the system. Use `free(p)` to release it.

```text
ref<byte> block = alloc(1024)   // Allocate 1024 bytes

// Write to it
set(block, 0xFF)
set(block + 1, 0x00)

// Read from it
byte first = value(block)       // 0xFF

// Release when done
free(block)
```

### Why This Is Easier Than C

| Task               | C Syntax                | SNlang Syntax            |
|--------------------|-------------------------|--------------------------|
| Declare pointer    | `int *p;`               | `ref<int> p`             |
| Get address        | `p = &x;`               | `p = address(x)`         |
| Read value         | `y = *p;`               | `y = value(p)`           |
| Write value        | `*p = 100;`             | `set(p, 100)`            |
| Pointer arithmetic | `*(p + 3) = 10;`        | `set(p + 3, 10)`         |
| Allocate memory    | `p = malloc(1024);`     | `p = alloc(1024)`        |
| Free memory        | `free(p);`              | `free(p)`                |

With this system, a programmer can build **any** data structure (linked lists, stacks, queues, trees, hash maps) from scratch — without fighting cryptic syntax.

---

## 11. Building Your Own Data Structures (Example)

SNlang does **not** provide built-in complex data structures. The programmer builds them using blueprints, pointers, and raw memory. Here is an example of a simple linked list node:

```text
blueprint Node {
    int data
    ref<Node>? next = none

    fn create(int data) {
        self.data = data
    }
}

fn main() {
    object a = Node(10)
    object b = Node(20)
    object c = Node(30)

    a.next = address(b)
    b.next = address(c)

    // Walk the list
    ref<Node>? current = address(a)
    while (current != none) {
        print(value(current).data)
        current = value(current).next
    }
    // Output: 10, 20, 30
}
```

---

## 12. Error Handling

Explicit error handling inspired by Go. No hidden exceptions. You always deal with errors.

```text
fn readFile(str path) -> (str, error) {
    if (not fileExists(path)) {
        return ("", error("File not found: " + path))
    }
    return (contents, none)
}

str data, error err = readFile("config.txt")

if (err != none) {
    print("Error: " + err.message)
} else {
    print(data)
}
```

### Panic (Unrecoverable Errors)

```text
fn mustConnect(str db) -> connection {
    connection conn, error err = openDB(db)
    if (err != none) {
        panic("Cannot start without database!")
    }
    return conn
}
```

---

## 13. Blueprints (OOP — Classes)

`blueprint` replaces the word `class`. Curly braces `{}` for the body.

```text
blueprint User {
    str name
    str email
    int age

    fn create(str name, str email, int age) {
        self.name = name
        self.email = email
        self.age = age
    }

    fn greet() -> str {
        return "Hi, I'm " + self.name
    }

    fn isAdult() -> bool {
        return (self.age >= 18)
    }
}
```

### Object Creation

```text
new User alice(name: "Alice", email: "alice@mail.com", age: 25)
print(alice.greet())

if (alice.isAdult()) {
    print("Access granted")
}
```

---

## 14. Inheritance

Use `from` to inherit from another blueprint.

```text
blueprint Animal {
    str species
    int legs

    fn describe() -> str {
        return self.species + " with " + cast(self.legs, str) + " legs"
    }
}

blueprint Dog from Animal {
    str breed

    fn bark() {
        print("Woof!")
    }
}
```

```text
new Dog rex(species: "Canine", legs: 4, breed: "Labrador")
print(rex.describe())
rex.bark()
```

---

## 15. Contracts (Interfaces)

`contract` defines a set of functions that a blueprint **must** implement.

```text
contract Drawable {
    fn draw()
    fn resize(int width, int height)
}

blueprint Circle follows Drawable {
    int radius

    fn draw() {
        print("Drawing circle with radius " + cast(self.radius, str))
    }

    fn resize(int width, int height) {
        self.radius = width / 2
    }
}
```

---

## 16. Access Control

| Keyword   | Description                                  |
|-----------|----------------------------------------------|
| `open`    | Accessible from anywhere (default)           |
| `closed`  | Only accessible within the blueprint itself   |
| `guarded` | Accessible by the blueprint and its children  |

```text
blueprint BankAccount {
    open str ownerName
    closed dec(2) balance = 0.00

    fn deposit(dec(2) amount) {
        self.balance += amount
    }

    fn getBalance() -> dec(2) {
        return self.balance
    }
}
```

---

## 17. Modules & Imports

Every `.sn` file is a module. Import using `use`.

```text
// file: math_utils.sn
fn square(int x) -> int {
    return x ** 2
}
```

```text
// file: main.sn
use math_utils

int result = math_utils.square(5)
print(result)   // 25
```

### Multiple Module Imports

You can import multiple modules in a single file:

```text
use std.math
use utils.string
use io.file
use net.http

fn main() {
    print("All modules loaded!")
}
```

### Dotted Module Paths

Modules can be organized in hierarchical paths:

```text
use std.collections.list
use std.collections.map
use company.auth.jwt
use company.database.postgres
```

**Current Implementation Status:**
- ✅ `use module.path` syntax parsing
- ✅ Single and multiple module imports
- ✅ Dotted module paths (`use std.math.advanced`)
- ❌ Actual file loading and parsing (planned)
- ❌ Symbol resolution (imported functions not yet callable)
- ❌ Module search paths

### Standard Library Imports

```text
use std.io          // Input / Output
use std.math        // Math functions
use std.net         // Networking
use std.file        // File operations
use std.time        // Time and dates
use std.json        // JSON parsing
```

---

## 18. Concurrency / Threads

### Spawning Threads

```text
fn downloadFile(str url) {
    print("Downloading: " + url)
}

// Spawn new thread, continues immediately
spawn downloadFile("https://example.com/data.zip")
print("This runs immediately, no waiting!")
```

### Channels (Safe Communication)

```text
chan<str> messages

spawn {
    messages.send("Hello from thread!")
}

spawn {
    str msg = messages.receive()
    print(msg)
}
```

### Locks (Synchronization)

```text
lock counterLock
int counter = 0

fn increment() {
    lock(counterLock) {
        counter += 1
    }
}

spawn increment()
spawn increment()
print(counter)  // Output: 2
```

### Async/Await

```text
async fn slowTask() -> int {
    return 42
}

int result = await slowTask()
print(result)
```

---

## 19. Type Casting

Explicit only. No silent coercion — ever.

```text
int x = 42
dec(2) y = cast(x, dec(2))   // y = 42.00
str z = cast(x, str)         // z = "42"

str numStr = "100"
int num = cast(numStr, int)  // num = 100
```

---

## 20. Null Safety

A variable can only be `none` if you explicitly allow it with `?`.

```text
str name = "Alice"       // Can NEVER be none
str? nickname = none     // Allowed to be none

if (nickname != none) {
    print(nickname)
}

// Or use the 'otherwise' operator
print(nickname otherwise "No nickname")
```

---

## 21. String Operations

```text
str greeting = "Hello, World!"

int len = greeting.length           // 13
str sub = greeting.slice(0, 5)      // "Hello"
bool has = greeting.contains("World")  // true
str fixed = greeting.replace("World", "SNlang")
list<str> parts = greeting.split(", ")
str upper = greeting.upper()        // "HELLO, WORLD!"
str lower = greeting.lower()        // "hello, world!"

// String interpolation
str name = "Alice"
int age = 25
str msg = "My name is {name} and I am {age} years old"
```

---

## 22. Input / Output

```text
use std.io

print("Hello, SNlang!")

str userInput = input("Enter your name: ")
print("Welcome, " + userInput)
```

### File I/O

```text
use std.file

file.write("output.txt", "Hello from SNlang!")

str contents, error err = file.read("data.txt")
if (err != none) {
    print("Failed to read file")
}
```

---

## 23. Program Entry Point

Every SNlang program starts from a `main` function.

```text
fn main() {
    print("Welcome to SNlang!")
    int x = 10
    int y = 20
    print("Sum: " + cast(x + y, str))
}
```

---

## 24. Complete Example Program

```text
use std.io

const str APP_NAME = "SNlang Demo"
const dec(2) TAX_RATE = 18.00

contract Printable {
    fn display() -> str
}

blueprint Product follows Printable {
    str name
    dec(2) price
    int quantity

    fn create(str name, dec(2) price, int quantity) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }

    fn totalPrice() -> dec(2) {
        dec(2) subtotal = self.price * cast(self.quantity, dec(2))
        dec(2) tax = subtotal * TAX_RATE / 100.00
        return subtotal + tax
    }

    fn display() -> str {
        return self.name + " — $" + cast(self.totalPrice(), str)
    }
}

blueprint DigitalProduct from Product {
    str downloadURL

    fn display() -> str {
        return self.name + " [Digital] — $" + cast(self.totalPrice(), str)
    }
}

fn main() {
    print("=== " + APP_NAME + " ===")

    object laptop = Product("Laptop", 999.99, 1)
    object ebook = DigitalProduct(
        name: "SNlang Guide",
        price: 29.99,
        quantity: 1,
        downloadURL: "https://safarnow.com/snlang-guide"
    )

    list<Product> cart = [laptop, ebook]

    for (item in cart) {
        print(item.display())
    }

    dec(2) total = 0.00
    for (item in cart) {
        total += item.totalPrice()
    }

    print("Total: $" + cast(total, str))

    str? coupon = none
    str discount = coupon otherwise "No coupon applied"
    print(discount)

    if (total > 500.00) {
        print("Free shipping!")
    } else {
        print("Shipping: $9.99")
    }
}
```

---

## Quick Reference Card

| Feature          | SNlang Syntax                    | Java / C++ / Go           |
|------------------|----------------------------------|----------------------------|
| Variable         | `int x = 5`                      | `int x = 5;`              |
| Constant         | `const int X = 5`                | `final int X = 5;`        |
| Function         | `fn add(int a, int b) -> int {`  | `int add(int a, int b) {` |
| Class            | `blueprint User {`               | `class User {`             |
| Interface        | `contract Drawable {`            | `interface Drawable {`     |
| Inheritance      | `blueprint Dog from Animal {`    | `class Dog extends Animal` |
| Implements       | `blueprint X follows Y {`        | `class X implements Y {`   |
| If               | `if (x > 5) {`                   | `if (x > 5) {`            |
| For Loop         | `for (int i=0, i<10, i+=1) {`   | `for(int i=0;i<10;i++) {` |
| For Each         | `for (x in list) {`             | `for (auto x : list) {`   |
| Switch           | `match (x) {`                   | `switch(x) {`              |
| Pointer          | `ref<int> p`                     | `int *p`                   |
| Get address      | `address(x)`                     | `&x`                       |
| Dereference      | `value(p)`                       | `*p`                       |
| Write to ptr     | `set(p, 100)`                    | `*p = 100`                 |
| Allocate         | `alloc(1024)`                    | `malloc(1024)`             |
| Free             | `free(p)`                        | `free(p)`                  |
| Thread           | `thread fn work() {`            | `new Thread(...)`          |
| Null check       | `str? x = none`                  | `String x = null;`        |
| Null fallback    | `x otherwise "default"`          | `x ?? "default"`           |
| Cast             | `cast(x, str)`                   | `(String) x`               |
| Import           | `use std.io`                     | `import java.io.*`         |
| Print            | `print("hi")`                    | `System.out.println("hi")` |
| Logical AND      | `and`                            | `&&`                       |
| Logical OR       | `or`                             | `\|\|`                     |
| Logical NOT      | `not`                            | `!`                        |
| Break            | `stop`                           | `break`                    |
| Continue         | `skip`                           | `continue`                 |
| Public           | `open`                           | `public`                   |
| Private          | `closed`                         | `private`                  |
| Protected        | `guarded`                        | `protected`                |

---

## File Extension

All SNlang source files use the **`.sn`** extension.

```
main.sn
utils.sn
models.sn
```

---

*SNlang — Built by SafarNow. Code should be simple, strict, and fast.*
