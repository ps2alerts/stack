module.exports = {
  async up(db) {
    let filter = {"timeStarted": {"$lte": new Date(2022, 07, 13, 13)}, "mapVersion": {"$exists": false}};
    let updateDoc = [{"$set":{"mapVersion": "1.0"}}];

    console.log(`Updating instances created prior to the Surf and Storm Update...`);
    let result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    filter = {"timeStarted": {"$gt": new Date(2022, 07, 13, 13)}, "mapVersion": {"$exists": false}, "zone": {"$ne": 344}};
    console.log(`Updating unversioned, non-Oshur instances created after the Surf and Storm Update...`);
    result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    filter = {"timeStarted": {"$gt": new Date(2022, 07, 13, 13)}, "mapVersion": {"$exists": false}, "zone": 344};
    console.log(`Updating unversioned Oshur instances created after the Surf and Storm Update...`);
    updateDoc = [{"$set":{"mapVersion": "1.1"}}];
    result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);
  },

  async down(db) {
    const updateDoc = [{"$unset": "mapVersion"}];

    console.log(`Removing mapVersions from all alert instances...\n`);
    const result = await db.collection("instance_metagame_territories").updateMany({}, updateDoc);
    console.log(`Updated ${result.modifiedCount} document(s)\n`);
  }
};
