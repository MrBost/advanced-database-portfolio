// Read-only verification after CRUD. Can be repeated safely.
{
    const catalogueDb = db.getSiblingDB("bookmania_p4");
    function check(condition, message) {
        if (!condition) { throw new Error("FAIL: " + message); }
        print("PASS: " + message);
    }
    check(catalogueDb.books.countDocuments({}) === 3, "three final catalogue documents");
    check(catalogueDb.books.findOne({ _id: 900001 }) === null, "temporary document deleted");
    const businessBook = catalogueDb.books.findOne({ _id: 2 });
    check(businessBook !== null && Number(businessBook.attributes.edition) === 2, "edition update retained");
    check(businessBook.authors.length === 2, "embedded authors retained");
    check(catalogueDb.books.countDocuments({ "attributes.illustrated": true }) === 1,
          "optional illustrated attribute supported");
    const indexes = catalogueDb.books.getIndexes();
    check(indexes.some(i => i.name === "isbn_unique" && i.unique === true), "unique ISBN index exists");
    check(indexes.some(i => i.name === "category_title" && i.key.category === 1 && i.key.title === 1),
          "category/title index exists");
    print("FINAL CATALOGUE:");
    printjson(catalogueDb.books.find().sort({ _id: 1 }).toArray());
}
