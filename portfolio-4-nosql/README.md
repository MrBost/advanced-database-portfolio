# Portfolio 4 - BookMania NoSQL document catalogue

This activity implements a **MongoDB document model** for the same BookMania case study. It covers the required NoSQL model, practical implementation and explanation of suitability. One document collection is sufficient; separate graph/key-value/column implementations are not required.

**Status:** completed and student-reviewed. Nine screenshots document the model, CRUD operations, indexes, all seven verification PASS checks and final catalogue. Student run details and reflection are recorded below; the original automated test remains separately attributed.

## Model

Database: `bookmania_p4`. Collection: `books`. Each document represents one catalogue book. Three synthetic books extend the first three records from Portfolio 1; they are not an automatic import of the SQL database.

| Field | Type and purpose |
|---|---|
| `_id` | Integer corresponding to the Portfolio 1 book_id for the three catalogue examples. |
| `isbn` | Unique 13-digit string identifying a book edition. |
| `title`, `category` | Search/display metadata. Category names are embedded rather than joined to a separate collection. |
| `authors` | Array of embedded objects, each containing a name; supports multiple authors. |
| `attributes` | Embedded object with optional edition, language, printed format, page count or illustrated flag. Fields can differ between books. |

Example document, represented in readable JavaScript notation:

```javascript
{
    _id: 2,
    isbn: "9780000000026",
    title: "Sample Book 002",
    category: "Business",
    authors: [{ name: "Sample Author 2" }, { name: "Sample Co-author" }],
    attributes: { language: "English", format: "hardcover" }
}
```

The setup script supplies all three documents and collection validation. Core fields and a nonempty author array are required; edition/page count must be positive integers when present. An ISBN unique index prevents duplicate catalogue entries. The compound `(category, title)` index matches category filtering followed by title sorting. With only three books, no performance improvement is claimed or benchmark required.

## Why documents fit BookMania

Book descriptions vary: a technical book can have an edition/page count, while an illustrated novel has different metadata. Optional fields avoid forcing every book into the same set of populated columns. Embedded authors and attributes are retrieved with the book in one document, matching catalogue reads and supporting several authors without a BookAuthor join.

The trade-off is duplicated author/category names. Shared author profiles or frequently changing author details could justify separate collections and references. Flexible documents still need validation and careful modelling; flexibility does not mean every document should have arbitrary structure.

PostgreSQL remains authoritative for orders, payments, stock and sale prices. MongoDB stores descriptive catalogue metadata, not a second stock balance. Matching IDs/ISBNs provide a conceptual link, but MongoDB does not enforce a foreign key to PostgreSQL. No cross-database synchronisation is implemented in this exercise. This keeps Portfolio 3's stock-concurrency rules separate from this catalogue demonstration.

## Run in mongosh

Requires a running MongoDB server and **mongosh**. pgAdmin runs PostgreSQL SQL and cannot execute these JavaScript files. Connect to your local MongoDB instance or use your configured connection URI. The scripts select `bookmania_p4` on that connected server.

From a terminal in this portfolio folder, for a local MongoDB server on its default port:

```powershell
mongosh "mongodb://localhost:27017" --file 00-setup.js
mongosh "mongodb://localhost:27017" --file 01-crud.js
mongosh "mongodb://localhost:27017" --file 02-verify.js
```

Alternatively, use mongosh interactively, including Compass's embedded shell if available, and load each file by its full local path, for example:

```javascript
load("C:/Users/kayode/Documents/BOST/PERSONAL/MIVA/Advanced Database Portfolio/portfolio-4-nosql/00-setup.js")
```

Load `01-crud.js` and `02-verify.js` in the same way, in that order. Separate shell sessions are also supported; this implementation uses persistent documents, not temporary views. Local variables are scoped within each file to avoid redeclaration errors.

| Script | Operation and expected result |
|---|---|
| `00-setup.js` | Create collection/validation/indexes and insert three books; print documents and index definitions. Run once. |
| `01-crud.js` | Create a temporary fourth book; read by category, embedded author and optional attribute; add edition 2 to Book 002; delete only the temporary book. Finish with three books. Run once. |
| `02-verify.js` | Read-only checks: three books, temporary book absent, edition update, embedded authors, optional illustrated metadata and both indexes. Expect seven PASS lines. Safe to repeat. |

Do not rerun setup over an existing `books` collection; it deliberately stops rather than deleting data. CRUD also checks for an already-completed update before writing. For a fresh repeat, choose a new dedicated database name consistently in all three files. These sequential CRUD operations are not one multi-document transaction: if an unexpected error interrupts the script, inspect the collection before retrying.

To inspect the results manually in mongosh:

```javascript
db.getSiblingDB("bookmania_p4").books.find().sort({ _id: 1 })
db.getSiblingDB("bookmania_p4").books.getIndexes()
```

## Evidence and student review

### My execution and results

I executed the activity on **2 November 2026** using **MongoDB 8.3.4**, database **bookmania_p4**, collection **books**. I inspected the catalogue in MongoDB Compass and executed the scripts in mongosh. The [evidence index](evidence/README.md) links my nine screenshots.

The temporary book was created and read successfully. The update matched and modified one document, adding edition 2 to Book 002. Deletion removed the temporary book, and all seven verification checks passed. The final catalogue contains three books with embedded authors and differing attributes. My index capture confirms the default _id index, the unique ISBN index and the compound category/title index.

### My challenge and lesson

Running the JavaScript files using `load()` failed in my environment. I worked around this by executing the script contents directly in mongosh. This allowed me to complete the operations and verify the results. The experience demonstrated that the same implementation can be executed as script contents in the shell when file loading is unavailable; I have not attributed the loading error to a specific cause.

The document model also shows how embedded authors and optional attributes support catalogue reads without requiring identical metadata for every book. This flexibility is balanced with validation and indexes, while stock, orders and payments remain in PostgreSQL.

### Separate automated validation

The agent test used a dedicated container, `bookmania-p4-validation`, with no published host port. It was stopped after testing, retaining the completed catalogue. It is not a dependency for your own local MongoDB run. To inspect that completed agent database, start the container and use `docker exec -it bookmania-p4-validation mongosh`; run the manual read commands above. Do not rerun setup/CRUD against that completed collection. For your own full run, use a fresh local `bookmania_p4` database, or change the dedicated database name consistently in all three scripts.

## Sources and AI assistance

- Miva Open University, MIT 8103 Advanced Database Systems CA, September Cohort 2026: Portfolio 4 deliverables.
- MongoDB: [Data modelling best practices](https://www.mongodb.com/docs/manual/data-modeling/best-practices/) and [writing mongosh scripts](https://www.mongodb.com/docs/mongodb-shell/write-scripts/), consulted 2 November 2026.

Codex assisted with the document model, scripts, documentation, initial automated testing and screenshot review. I executed the operations in mongosh, inspected the documents in Compass and supplied the CRUD, index and verification screenshots. Codex helped edit my reflection using my account of the file-loading difficulty and workaround. The automated MongoDB 8.2.2 log is separately attributed from my MongoDB 8.3.4 execution. I remain responsible for understanding and explaining the work. All documents contain synthetic data. The executable JavaScript is the implementation source; separate JSON sample files or Python helpers are unnecessary.
