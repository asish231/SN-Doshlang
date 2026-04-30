# SNlang OOP Syntax & Progression

The goal of SNlang's object system is to be as simple as Go, but as powerful as Java, with zero boilerplate. 

## ✅ OOP Feature Completion Checklist
Here is a breakdown of all core Object-Oriented Programming principles and how SNlang handles them:

- [x] **Classes & Objects**: Handled via `blueprint` and the `new` keyword.
- [x] **Constructors**: Automatic named-argument constructors by default, with an optional `create` method for custom logic.
- [x] **Encapsulation**: Fully supported via `open` (public), `closed` (private), and `guarded` (protected) keywords.
- [x] **Inheritance**: Single inheritance supported using the `from` keyword.
- [x] **Polymorphism & Abstraction**: Handled safely via `contract` (interfaces) and the `follows` keyword.
- [x] **Method Overriding**: Child blueprints can override parent methods naturally.
- [x] **Multiple Inheritance**: Avoided by design to prevent the "Diamond Problem"; use multiple `contracts` instead.

---

## 1. Defining a Blueprint (Class)

In SNlang, we use the `blueprint` keyword. A blueprint defines the data layout and the behavior of a custom type.

```sn
blueprint Node {
    str name
    int value
    ref<Node>? next = none

    fn printNode() {
        print("Node: " + self.name)
    }
}
```

---

## 2. Creating an Object 

SNlang gives you two ways to create objects, prioritizing a clean, Java-like heap syntax. 

### A. The Standard Way (Heap Allocation)
Using the `new` keyword creates an object on the heap and returns a pointer (`ref<T>`). SNlang features **auto-dereferencing**, meaning you can use the dot operator `.` directly on pointers without needing `value()`.

```sn
new Node root(name: "Root", value: 42)

print(root.name)
root.printNode()
```

### B. Delayed Field Assignment
You can create an empty object and fill the fields later.

```sn
new Node myNode()

myNode.name = "Custom Node"
myNode.value = 100
```

### C. Stack Allocation (For extreme performance)
If an object is temporary and doesn't need to live past the current function, omit `new`. The system will automatically clean it up.

```sn
Node tempNode(name: "Temp", value: 1)
```

---

## 3. Custom Constructors

By default, SNlang gives you an automatic named-argument constructor. If you need custom initialization logic, define a `create` method.

```sn
blueprint Vector {
    int x
    int y
    int magnitude

    fn create(int x, int y) {
        self.x = x
        self.y = y
        self.magnitude = (x * x) + (y * y)
    }
}

new Vector v(3, 4)
```

---

## 4. Encapsulation (Access Control)

SNlang provides three levels of access control to protect your internal state.

*   `open`: Public (Default)
*   `closed`: Private (Only inside the blueprint)
*   `guarded`: Protected (Inside the blueprint and its children)

```sn
blueprint BankAccount {
    open str owner
    closed dec(2) balance = 0.00

    fn deposit(dec(2) amount) {
        self.balance += amount
    }
}
```

---

## 5. Inheritance & Method Overriding

SNlang supports single inheritance using the `from` keyword. A child blueprint inherits all fields and methods from its parent, and can override methods to change behavior.

```sn
blueprint Animal {
    str species
    
    fn speak() { 
        print("Some generic sound") 
    }
}

blueprint Dog from Animal {
    str breed
    
    fn speak() { 
        print("Woof!") 
    }
}

fn main() {
    new Dog rex(species: "Canine", breed: "Labrador")
    
    print(rex.species)
    rex.speak()
}
```

---

## 6. Polymorphism & Contracts (Interfaces)

To achieve polymorphism, SNlang uses the `contract` keyword. Contracts define what methods an object *must* have. Use `follows` to implement them.

```sn
contract Drawable {
    fn draw()
}

blueprint Circle follows Drawable {
    fn draw() { 
        print("Drawing Circle") 
    }
}

blueprint Square follows Drawable {
    fn draw() { 
        print("Drawing Square") 
    }
}

fn main() {
    new Circle c()
    new Square s()
    
    list<Drawable> shapes = [c, s]
    
    for (shape in shapes) {
        shape.draw()
    }
}
```

---

## 7. Memory & Pointers: Building a Linked List

Because `new` automatically returns a pointer, building complex, long-living data structures is incredibly clean.

```sn
blueprint ListNode {
    int data
    ref<ListNode>? next = none
}

fn main() {
    new ListNode head(data: 10)
    new ListNode second(data: 20)

    head.next = second

    ref<ListNode>? current = head
    while (current != none) {
        print(current.data)
        current = current.next
    }

    free(head)
    free(second)
}
```
