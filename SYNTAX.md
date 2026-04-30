# SNlang OOP Syntax (Simple & Powerful)

## 1. The Basics: Your First Object (Simple Syntax Example)
SNlang makes object creation trivial. Declare and use objects in two lines:

### Heap Object (Long-Lived, Reference)
```sn
new Point p()      // Create heap object (ref<Point>)
p.x = 10           // Set fields after creation
p.y = 20
print(p.x)         // Output: 10
```

### Stack Object (Temporary, Value)
```sn
Point q()          // Create stack object (value type)
q.x = 5
q.y = 15
print(q.y)         // Output: 15 (auto-cleaned when scope ends)
```

## 2. Creating Objects: Heap vs Stack
- **Heap**: Use `new` for objects that need to outlive their scope (data structures, shared state). Returns a reference (`ref<T>`).
- **Stack**: Omit `new` for temporary, high-performance objects. Automatically cleaned up when they go out of scope.

| Allocation | Syntax          | Variable Type   | Cleanup     |
| :--------- | :-------------- | :-------------- | :---------- |
| Heap       | `new Point p()` | `ref<Point>`    | Manual (`free(p)`) |
| Stack      | `Point p()`     | `Point` (value) | Automatic   |

## 3. Defining a Blueprint (Class)
Use `blueprint` to define a custom type. Specify fields (data) and methods (behavior).

```sn
blueprint Point {
    int x
    int y

    fn print() {
        print("(" + self.x + ", " + self.y + ")")
    }
}
```

### Field Rules:
- Types are required (`int`, `str`, etc.).
- Default values are optional (`int x = 0`).
- References: `ref<T>` (non-nullable) or `ref<T>?` (nullable, defaults to `none`).

## 4. Initialization
### A. Immediate (Named Arguments)
```sn
new Point p(x: 10, y: 20)  // Heap: set fields at creation
Point q(x: 5, y: 15)       // Stack: same syntax
```

### B. Delayed (Field Assignment After)
```sn
new Point r()              // Heap: empty object
r.x = 100
r.y = 200

Point s()                  // Stack: empty object
s.x = 300
s.y = 400
```

## 5. Custom Constructors (The `create` Method)
When you need custom logic during creation (e.g., calculated fields), define a `create` method. This disables the auto named-argument constructor.

```sn
blueprint Circle {
    int radius
    int area  // Calculated field

    fn create(int r) {
        self.radius = r
        self.area = 3 * r * r  // Simple approximation
    }
}

// Usage (positional args for create)
new Circle c(5)
print(c.area)  // Output: 75
```

## 6. Inheritance (Extending Blueprints)
Use `from` for single inheritance. Child blueprints inherit all accessible fields/methods.

```sn
blueprint Shape {
    str color
    fn describe() { print("A " + self.color + " shape") }
}

blueprint Square from Shape {
    int side

    fn area() -> int { return self.side * self.side }
}

// Usage
new Square sq(color: "Red", side: 4)
sq.describe()  // Output: A Red shape
print(sq.area()) // Output: 16
```

## 7. Polymorphism & Contracts (Interfaces)
Define contracts with `contract`, then implement them with `follows`. Enables treating different types uniformly.

```sn
contract Drawable {
    fn draw()
}

blueprint Circle follows Drawable {
    fn draw() { print("Drawing Circle") }
}

blueprint Square follows Drawable {
    fn draw() { print("Drawing Square") }
}

// Usage: group different types under one contract
fn main() {
    new Circle c()
    new Square s()
    list<Drawable> shapes = [c, s]
    for (shape in shapes) {
        shape.draw()
    }
}
```

## 8. Access Control (Encapsulation)
Control visibility with three modifiers:

| Modifier | Meaning                          |
| :------- | :------------------------------- |
| `open`   | Public (default): accessible everywhere |
| `closed` | Private: only inside the blueprint |
| `guarded`| Protected: inside blueprint and children |

```sn
blueprint BankAccount {
    open str owner
    closed dec(2) balance = 0.00  // Private

    fn deposit(dec(2) amount) {
        self.balance += amount  // OK: inside blueprint
    }
}

blueprint SavingsAccount from BankAccount {
    fn showBalance() {
        // print(self.balance)  // Error: closed, not accessible
        print("Owner: " + self.owner)  // OK: open, inherited
    }
}
```

## 9. Practical Example: Linked List
Heap allocation + optional references (`ref<T>?`) = clean linked structures.

```sn
blueprint ListNode {
    int data
    ref<ListNode>? next = none  // Optional next node
}

fn main() {
    // Heap nodes (auto ref<ListNode>)
    new ListNode head(data: 1)
    new ListNode second(data: 2)

    // Link: head.next is already a ref
    head.next = second

    // Traverse: check for none
    ref<ListNode>? current = head
    while (current != none) {
        print(current.data)
        current = current.next
    }

    // Cleanup
    free(head)
    free(second)
}
```

## 10. Polymorphism (One Name, Many Types)
Polymorphism lets the same code work with different types. SNlang supports it via contracts (interfaces).

```sn
// Different shapes, same method call
fn drawAll(list<Drawable> shapes) {
    for (shape in shapes) {
        shape.draw()  // Calls the right draw() for each type
    }
}

fn main() {
    new Circle c()
    new Square s()
    drawAll([c, s])  // Output: Drawing Circle \n Drawing Square
}
```

## 11. Threading & Concurrency
SPWN provides built-in concurrency with simple syntax.

### A. Spawning Threads
Use `spawn` to run code concurrently:

```sn
fn heavyTask() {
    for (i in 0..1000) {
        print("Working: " + i)
    }
}

// Spawns new thread, continues immediately
spawn heavyTask()
print("Main continues without waiting")
```

### B. Channels (Message Passing)
Use channels to communicate between threads:

```sn
// Create a channel for int values
chan<int> numbers

// Producer thread
spawn {
    for (i in 0..10) {
        numbers.send(i)  // Send value to channel
    }
    numbers.close()       // Close channel when done
}

// Consumer thread
spawn {
    while (numbers.open) {
        val = numbers.receive()  // Receive from channel
        print("Received: " + val)
    }
}
```

### C. Synchronization (Locks)
Use `lock` to protect shared data:

```sn
lock counterLock
int counter = 0

fn increment() {
    lock(counterLock) {
        counter += 1  // Only one thread at a time
    }
}

// Multiple threads safely increment
spawn increment()
spawn increment()
print(counter)  // Output: 2
```

## 12. Generics (Generic Types)
Use generics to write flexible, reusable code that works with any type.

### A. Generic Blueprints
```sn
blueprint Box<T> {
    T value  // T is a type parameter

    fn get() -> T { return self.value }
    fn set(T v) { self.value = v }
}

// Usage: specify type in angle brackets
new Box<int> intBox(value: 42)
new Box<str> strBox(value: "Hello")

print(intBox.get())  // Output: 42
print(strBox.get()) // Output: Hello
```

### B. Generic Methods
```sn
fn swap<T>(ref<T> a, ref<T> b) {
    temp = a.value
    a.value = b.value
    b.value = temp
}

fn first<T>(list<T> items) -> T {
    return items[0]
}
```

## 13. Error Handling & Exceptions
Use `try`, `catch`, and `throw` for error handling.

### A. Throwing Exceptions
```sn
fn divide(int a, int b) -> int {
    if (b == 0) {
        throw("Division by zero")  // Throw error message
    }
    return a / b
}
```

### B. Catching Errors
```sn
fn safeDivide() {
    result = try divide(10, 0)   // Try to execute
    catch (e) {
        print("Error: " + e)     // Handle error
        return 0                 // Return default on error
    }
    return result
}
```

### C. Option Type (Safe Null)
Use `Option<T>` to handle values that may not exist:

```sn
fn findUser(str name) -> Option<User> {
    if (name == "Asish") {
        return some(new User(name: "Asish"))  // Return wrapped value
    }
    return none                                  // Return nothing
}

fn main() {
    user = findUser("Asish")
    if (user.isSome()) {
        print(user.unwrap().name)  // Safe to access
    }
}
```

## 14. Collections & Iteration
SNlang provides built-in collection types.

### A. Lists
```sn
list<int> numbers = [1, 2, 3, 4, 5]

// Iterate with for
for (num in numbers) {
    print(num)
}

// Access by index
print(numbers[0])  // Output: 1
numbers.add(6)     // Add to end
numbers.remove(0) // Remove first
```

### B. Maps (Key-Value)
```sn
map<str, int> ages
ages["Alice"] = 25
ages["Bob"] = 30

print(ages["Alice"])  // Output: 25

for (name, age in ages) {
    print(name + " is " + age)
}
```

### C. Sets
```sn
set<str> names
names.add("Alice")
names.add("Bob")
names.add("Alice")  // Duplicate, ignored

print(names.contains("Alice"))  // Output: true
```

## 15. Async/Await (Non-Blocking Operations)
Use `async` and `await` for non-blocking operations (I/O, network, etc.).

```sn
async fn fetchData(str url) -> str {
    // Simulates network request
    result = await httpGet(url)
    return result
}

fn main() {
    // Async calls don't block
    data = async fetchData("https://api.example.com")
    
    // Do other work while waiting
    print("Fetching data...")
    
    // Await result when needed
    result = await data
    print("Got: " + result)
}
```

## 16. Memory Management & Ownership

### A. Ownership (Default)
Each value has a single owner. When owner goes out of scope, value is dropped:

```sn
fn createName() {
    str name = "Asish"   // name owns the string
}                       // name goes out of scope, memory freed
```

### B. Borrowing (References)
Use `&` to borrow without taking ownership:

```sn
fn printName(&str name) {
    print(name)  // Borrows, doesn't own
}

fn main() {
    str name = "Asish"
    printName(&name)   // Pass borrow
    print(name)       // Still valid after
}
```

### C. Moving Ownership
Use `move` to transfer ownership:

```sn
fn consume(str s) {
    print(s)  // Takes ownership
}

fn main() {
    str name = "Asish"
    move consume(name)  // Transfers ownership
    // print(name)       // Error: name no longer valid
}
```

## Quick Reference: Key Syntax
| Concept           | Syntax                          |
| :---------------- | :------------------------------ |
| **Blueprint**    | `blueprint Name { ... }`        |
| **Heap Object**  | `new Name var(args)`            |
| **Stack Object** | `Name var(args)`                |
| **Field Access** | `var.field` (auto-deref for refs) |
| **Method Call**   | `var.method(args)`              |
| **Inheritance** | `blueprint Child from Parent { ... }` |
| **Contract**      | `contract Name { fn method() }` |
| **Implements**   | `blueprint Name follows Contract { ... }` |
| **Access Control**| `open`, `closed`, `guarded` field/method |
| **Null**         | `none` (for optional refs)      |
| **Cleanup**      | `free(ref)` (heap only)          |
| **Thread**       | `spawn { ... }`                 |
| **Channel**      | `chan<T> name`                   |
| **Lock**         | `lock(name) { ... }`             |
| **Generic**      | `Blueprint<T> { ... }`           |
| **Try/Catch**    | `try { ... } catch(e) { ... }`   |
| **Async**        | `async fn name() { ... }`        |
| **Await**        | `await expression`               |
| **Borrow**       | `&var` (reference)              |
| **Move**         | `move var` (ownership transfer)  |
