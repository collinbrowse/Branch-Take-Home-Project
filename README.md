# Branch To-Do App

Thanks for taking a look at my Branch To-Do app! I had a great time building it.

Below is a concise overview of the project, written in the spirit of a typical README. Rather than documenting every implementation detail here, I’m looking forward to discussing design decisions, trade-offs, and architectural choices in more depth during the next interview.

---

## Design

The design philosophy for this app was intentionally simple and user-focused:

- Adhere to the required architectural practices
- Keep visual and interaction design minimal
- Minimize the number of steps needed to complete a task
- Reduce cognitive load for common actions
- Ensure the UI feels natural and unobtrusive

---

## Development

### Architecture

- The project follows an MVVM architecture, as specified in the requirements
- Testability was treated as a first-class concern
- The app was built with scalability in mind
- Some trade-offs were made to balance scope and time constraints

### Folder Structure

- **Data**
  - **CoreData**
    - `BranchToDo.xcdatamodeld` — Core Data model for to-do items
    - `TodoDTO` — Network representation of demo to-do items
    - `TodoItem` — Domain model shared across layers
  - **Persistence**
    - `PersistenceController` — Core Data stack setup
  - **Repository**
    - `TodoRepository` — Serves `TodoItem` data to the view models
    - `MockRepository` — Mock repository used for unit testing

- **Networking**
  A lightweight networking layer for a RESTful backend, built using `URLSession`, `URLRequest`, and `URLResponse`.

- **Services**
  - `APIService` — Abstraction for performing network requests

- **Utilities**
  - `Errors` — Custom, domain-specific error types
  - `Extensions`
  - `Constants` — Centralized application constants
  - `TitleSanitizer` — Prevents invalid or malicious to-do input
  - `TodoErrorLogger` — Centralized error logging using the `Logger` API

- **Views**
  - `TodoScreen` — Root screen showing either the to-do list or an empty state
  - `ListView` — Displays a list of to-do items
  - `TodoItemView` — Renders a single to-do item
  - `TodoVM` — Provides view state and business logic
  - `ErrorView` — Presents user-friendly error messages

- **BranchToDoApp**
  - Application entry point
  - Owns the Core Data stack and coordinates data flow to views

#### Future Improvements

Given more time or a larger application scope, I would:
- Introduce a reusable `EmptyStateView`
- Revisit some constants and potentially group them under manager-style abstractions
- Add full VoiceOver support

---

## Testing

The testing strategy focuses on covering core functionality and critical paths:

- Full-stack integration tests (ViewModel → Repository → Core Data)
- Core Data repository tests
- Domain model conversion (Core Data ↔︎ `TodoItem`)
- Business logic tests (`TodoVM`)
- Error handling
- Title sanitization

---

## Other Considerations

- Supports Light and Dark Mode
- Supports multiple device orientations
- Targets iOS 26.1+
- Supports Dynamic Type
- Includes a custom app icon
