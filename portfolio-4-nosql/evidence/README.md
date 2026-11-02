# Portfolio 4 evidence

## Implementation coverage

| Requirement | Evidence source |
|---|---|
| Same BookMania case study and document model | Main README, field dictionary, embedded document example and three sample documents in `00-setup.js`. |
| Practical NoSQL implementation | MongoDB collection validation, indexes and executable scripts `00`-`02`. |
| Example operations | Labelled create/read/update/delete output from `01-crud.js`. |
| Suitability explanation | Main README: variable attributes, embedded authors, trade-offs and PostgreSQL responsibilities. |

This is supplementary agent execution evidence, not the student's run. The student screenshots and confirmed run details are documented separately below.

## Student run and screenshot index

- MongoDB version: **8.3.4**, as reported by the student.
- Database/collection: **bookmania_p4.books**, visible in the Compass capture.
- Execution date: **2 November 2026** (Africa/Lagos).
- Interface: mongosh for execution and MongoDB Compass for catalogue inspection.

| Screenshot | What it demonstrates |
|---|---|
| [Sample documents](screenshots/sample-documents.png) | Three books in Compass, embedded authors and nested attributes. |
| [Create](screenshots/create.png) | The inserted temporary book, _id 900001. |
| [Category read](screenshots/read-1.png) | Technology books, including the temporary book, returned in title order. |
| [Nested-field reads](screenshots/read-2.png) | Lookup by embedded co-author and by the presence of an edition attribute. |
| [Update](screenshots/update.png) | matchedCount 1 and modifiedCount 1; Book 002 retains both authors and gains edition 2. |
| [Delete](screenshots/delete.png) | Acknowledged deletion with deletedCount 1. |
| [Indexes](screenshots/indexes.png) | Default _id index, unique isbn_unique and compound category_title index with the expected key definitions. |
| [Verification](screenshots/verification-pass.png) | All seven final verification checks passing. |
| [Final catalogue](screenshots/final-catalogue.png) | Three remaining books, Book 002's edition update and the differing embedded attributes. |

The screenshots demonstrate the model and all CRUD operations, with verified final state and index definitions. The [main README](../README.md) records the student's reflection on the failed load() attempt and successful direct shell execution. Retain the three JavaScript files as reproducible implementation evidence. The renamed final-catalogue.png removes the space from the original screenshot filename; its image content was not changed.
