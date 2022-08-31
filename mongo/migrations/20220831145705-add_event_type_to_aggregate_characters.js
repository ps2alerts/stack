const aggregateCollections = [
  "aggregate_global_vehicles_characters",
  "aggregate_instance_vehicles_characters",
]

module.exports = {
  async up(db) {
    let updateDoc = [{"$set":{"ps2AlertsEventType": 1}}];

    console.log(updateDoc);

    for (const collection of aggregateCollections) {
      console.log(`Setting event types for collection ${collection}...`)
      const result = await db.collection(collection).updateMany({}, updateDoc);
      console.log(`Updated ${result.modifiedCount} documents`);
    }
  },

  async down(db) {
    let updateDoc = [{"$unset":{"ps2AlertsEventType": 1}}];
    for (const collection of aggregateCollections) {
      await db.collection(collection).updateMany({}, updateDoc);
    }
  }
};
