module.exports = {
  async up(db) {
    let filter = {"timeStarted": {"$lte": new Date(2022, 10, 17, 14)}, "latticeVersion": {"$exists": false}};
    let updateDoc = [{"$set":{"latticeVersion": "$mapVersion"}}];

    console.log(`Updating instances created prior to the November 17, 2022 Update...`);
    let result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    filter = {"timeStarted": {"$gt": new Date(2022, 10, 17, 14)}, "latticeVersion": {"$exists": false}, "zone": {"$ne": 2}};
    console.log(`Updating unversioned, non-Indar instances created after the November 17, 2022 Update...`);
    result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    filter = {"timeStarted": {"$gt": new Date(2022, 10, 17, 14)}, "latticeVersion": {"$exists": false}, "zone": 2};
    console.log(`Updating unversioned Indar instances created after the November 17, 2022 Update...`);
    updateDoc = [{"$set":{"latticeVersion": "1.1"}}];
    result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);
  },

  async down(db) {
    const updateDoc = [{"$unset": "latticeVersion"}];

    console.log(`Removing latticeVersions from all alert instances...\n`);
    const result = await db.collection("instance_metagame_territories").updateMany({}, updateDoc);
    console.log(`Updated ${result.modifiedCount} document(s)\n`);
  }
};
