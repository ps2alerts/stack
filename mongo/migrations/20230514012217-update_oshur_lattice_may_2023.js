module.exports = {
  async up(db) {
    const filter = {"timeStarted": {"$gte": new Date(2023, 4, 17, 14)}, "zone": 344, "latticeVersion": {"$ne": "1.3"}, "mapVersion": {"$ne": "1.2"}};
    const updateDoc = [{"$set":{"latticeVersion": "1.3", "mapVersion": "1.2"}}];

    let result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);
  },

  async down(db) {
    const filter = {"timeStarted": {"$gte": new Date(2023, 4, 17, 14)}, "zone": 344, "latticeVersion": "1.3", "mapVersion": "1.2"};
    const updateDoc = [{"$set":{"latticeVersion": "1.2", "mapVersion": "1.1"}}];

    let result = await db.collection("instance_metagame_territories").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);
  }
};
