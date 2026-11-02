// Run once after setup. Demonstrates create, read, update and delete.
{
    const catalogueDb = db.getSiblingDB("bookmania_p4");
    function check(condition, message) {
        if (!condition) { throw new Error(message); }
    }
    const businessBook = catalogueDb.books.findOne({ _id: 2 });
    check(catalogueDb.books.countDocuments({}) === 3 && businessBook !== null,
          "Expected three setup documents. Run setup first or inspect the existing state.");
    check(businessBook.attributes.edition === undefined,
          "CRUD update already performed. Review existing evidence; do not rerun blindly.");

    print("CREATE: temporary demonstration book");
    const created = catalogueDb.books.insertOne({
        _id: NumberInt(900001), isbn: "9789999000004", title: "Temporary Catalogue Demo", category: "Technology",
        authors: [{ name: "Demo Author" }],
        attributes: { language: "English", format: "paperback" }
    });
    check(created.acknowledged && catalogueDb.books.countDocuments({}) === 4, "Create failed");
    printjson(catalogueDb.books.findOne({ _id: 900001 }));

    print("READ: technology catalogue ordered by title (compound-index access pattern)");
    printjson(catalogueDb.books.find({ category: "Technology" }).sort({ title: 1 }).toArray());
    print("READ: embedded author lookup");
    printjson(catalogueDb.books.find({ "authors.name": "Sample Co-author" }).toArray());
    print("READ: books with an edition attribute");
    printjson(catalogueDb.books.find({ "attributes.edition": { $exists: true } }).toArray());

    print("UPDATE: add edition 2 to Sample Book 002 without changing other books");
    const updated = catalogueDb.books.updateOne({ _id: 2 }, { $set: { "attributes.edition": NumberInt(2) } });
    check(updated.matchedCount === 1 && updated.modifiedCount === 1, "Update failed");
    printjson(updated);
    printjson(catalogueDb.books.findOne({ _id: 2 }));

    print("DELETE: remove only the temporary demonstration book");
    const deleted = catalogueDb.books.deleteOne({ _id: 900001 });
    check(deleted.deletedCount === 1, "Delete failed");
    printjson(deleted);
    print("PASS: CRUD completed; three catalogue books remain.");
}
