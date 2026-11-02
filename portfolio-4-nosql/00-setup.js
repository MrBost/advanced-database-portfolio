// mongosh script. Run once in the dedicated bookmania_p4 database.
// Braces keep variable declarations local when multiple files are loaded.
{
    const catalogueDb = db.getSiblingDB("bookmania_p4");
    if (catalogueDb.getCollectionInfos({ name: "books" }).length !== 0) {
        throw new Error("books already exists. Inspect the existing run; setup does not delete/reset data.");
    }

    catalogueDb.createCollection("books", {
        validator: {
            $jsonSchema: {
                bsonType: "object",
                required: ["_id", "isbn", "title", "category", "authors", "attributes"],
                properties: {
                    _id: { bsonType: "int" },
                    isbn: { bsonType: "string", pattern: "^[0-9]{13}$" },
                    title: { bsonType: "string", minLength: 1 },
                    category: { bsonType: "string", minLength: 1 },
                    authors: {
                        bsonType: "array", minItems: 1,
                        items: {
                            bsonType: "object", required: ["name"],
                            properties: { name: { bsonType: "string", minLength: 1 } }
                        }
                    },
                    attributes: {
                        bsonType: "object",
                        properties: {
                            edition: { bsonType: "int", minimum: 1 },
                            language: { bsonType: "string", minLength: 1 },
                            format: { enum: ["paperback", "hardcover"] },
                            pageCount: { bsonType: "int", minimum: 1 },
                            illustrated: { bsonType: "bool" }
                        }
                    }
                }
            }
        },
        validationLevel: "strict",
        validationAction: "error"
    });

    catalogueDb.books.createIndex({ isbn: 1 }, { unique: true, name: "isbn_unique" });
    catalogueDb.books.createIndex({ category: 1, title: 1 }, { name: "category_title" });

    // _id matches Portfolio 1 book_id for the first three synthetic books.
    // Metadata extends that sample catalogue; no SQL stock/prices are copied.
    catalogueDb.books.insertMany([
        {
            _id: NumberInt(1), isbn: "9780000000019", title: "Sample Book 001", category: "Technology",
            authors: [{ name: "Sample Author 1" }],
            attributes: { edition: NumberInt(2), language: "English", format: "paperback", pageCount: NumberInt(320) }
        },
        {
            _id: NumberInt(2), isbn: "9780000000026", title: "Sample Book 002", category: "Business",
            authors: [{ name: "Sample Author 2" }, { name: "Sample Co-author" }],
            attributes: { language: "English", format: "hardcover" }
        },
        {
            _id: NumberInt(3), isbn: "9780000000033", title: "Sample Book 003", category: "Fiction",
            authors: [{ name: "Sample Author 3" }],
            attributes: { language: "French", format: "paperback", illustrated: true }
        }
    ]);
    print("SETUP: BookMania document catalogue created; three sample documents.");
    printjson(catalogueDb.books.find().sort({ _id: 1 }).toArray());
    print("INDEXES:");
    printjson(catalogueDb.books.getIndexes());
}
