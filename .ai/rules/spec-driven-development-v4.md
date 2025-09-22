---
description: "A high-precision, Spec-Driven Development (SDD) protocol. It mandates a complete upfront specification before entering a rigorous, test-driven implementation cycle."
alwaysApply: false
---
# AI Protocol: Spec-Driven Development (v4)
## An SDD-centric workflow integrating a Test-Driven implementation phase.

When a user invokes "Spec-Driven Development" or "SDD", you **MUST** adhere to the following protocol without deviation.

---

### Phase 1: Initiation & Naming

1.  **Propose & Confirm Name**: Analyze the request, propose a `kebab-case` feature name, and request user confirmation with the prompt: "Understood. Let's begin SDD. I suggest the feature name `[your-suggested-name]`. Is this correct?"
2.  **Await Confirmation**: **DO NOT** proceed until the name is explicitly approved by the user.

---

### Phase 2: Pre-flight Check

1.  **Verify Path**: Check for the existence of the directory `.ai/specs/[feature-name]/`.
2.  **Resolve Collision**: If the directory exists, prompt the user for resolution: "This spec already exists. How should we proceed? (**Overwrite** / **Choose New Name** / **Cancel**)."

---

### Phase 3: Specification Scaffolding

1.  **Create Artifacts**: Generate the complete specification structure:
    ```
    .ai/specs/[feature-name]/
    ├── requirements.md  # The 'What': User stories & acceptance criteria.
    ├── design.md        # The 'How': Technical architecture & data models.
    ├── testing.md       # The 'Proof': High-level testing strategy.
    ├── tasks.md         # The 'Plan': TDD-based implementation checklist.
    └── README.md        # The 'Knowledge Transfer': Final documentation.
    ```
2.  **Announce Creation**: State clearly: "The specification directory and artifacts have been created at `.ai/specs/[feature-name]/`."

---

### Phase 4: Specification Authoring & Lock-in

This phase **MUST** be completed in sequence. Do not proceed to the next file without explicit user approval on the current one.

1.  **`requirements.md`**: Draft user stories with actionable, measurable **Acceptance Criteria**. Request approval.
2.  **`design.md`**: Draft the technical design, detailing component architecture, data models, API contracts, and a **Deployment Strategy** (e.g., feature flagging). Request approval.
3.  **`testing.md`**: Draft the high-level test plan. Define the testing pyramid for this feature (e.g., "70% unit, 20% integration, 10% E2E") and identify primary test scenarios. Request approval.
4.  **`tasks.md`**: Decompose the approved design into a granular checklist framed for TDD.
    * *Task Structure Example:*
        * `[ ] 1. (Red) Write failing test for API endpoint authentication.`
        * `[ ] 2. (Green) Implement minimal auth logic to pass the test.`
        * `[ ] 3. (Refactor) Clean up auth logic and dependencies.`
5.  **Specification Lock-in**: After `tasks.md` is generated, ask for final sign-off on the entire plan: "📝 The full specification is now complete and staged for implementation. Do I have your final approval to begin the TDD cycle?"

---

### Phase 5: TDD Implementation Cycle

1.  **Initiate Cycle**: After approval, prompt the user: "⚙️ Lock-in confirmed. Commencing TDD cycle. Shall we begin with Task 1: **(Red) Write a failing test**?"
2.  **Execute & Track**: Address one task at a time. Upon successful completion of each task:
    * Edit `tasks.md` and replace `[ ]` with `[x]`.
    * Announce progress: "**Task complete.** The test suite is green. Now proceeding to: `[description of next task]`."

---

### Phase 6: Change Control Protocol

* If a user request deviates from the locked-in spec, you **MUST** pause implementation and invoke this protocol.
* State: "That request deviates from the approved specification. Per protocol, we must update the relevant spec document before resuming implementation. Please specify which document (`requirements.md`, `design.md`) needs to be amended."

---

### Phase 7: Finalization & Hand-off

1.  **Confirm Completion**: Once all tasks are marked `x`, announce: "🏁 **Implementation complete.** All tasks have been successfully executed."
2.  **Generate Documentation**: Prompt the user: "Shall I now generate the final documentation in `README.md` based on the spec and final implementation?"
3.  **Prepare for Review**: Generate a concise summary suitable for a Pull Request, linking to all spec files as the definitive source of truth for the changes.
4.  **Await Next Command**: Conclude with: "The feature is implemented, tested, and documented. Awaiting your next command."
