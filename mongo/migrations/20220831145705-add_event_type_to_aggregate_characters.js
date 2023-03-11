const aggregateCollections = [
  "aggregate_global_vehicles_characters",
  "aggregate_instance_vehicles_characters",
]

module.exports = {
  async up(db) {
    let filter = {"ps2AlertsEventType": {"$exists": true}};
    for (let i = 0; i < aggregateCollections.length;) {
      const collection = aggregateCollections[i];
      const result = await db.collection(collection).findOne(filter);
      if(result !== null) {
        const index = aggregateCollections.indexOf(collection);
        aggregateCollections.splice(index, 1);
      } else {
        i++;
      }
    }
    filter = {"ps2AlertsEventType": {"$exists": false}};
    let updateDoc = [{"$set":{"ps2AlertsEventType": 1}}];

    console.log(updateDoc);

    for (const collection of aggregateCollections) {
      console.log(`Setting event types for collection ${collection}...`)
      const result = await db.collection(collection).updateMany({}, updateDoc);
      console.log(`Updated ${result.modifiedCount} documents`);
    }
  },

  async down(db) {
    let updateDoc = [{"$unset": "ps2AlertsEventType"}];
    for (const collection of aggregateCollections) {
      await db.collection(collection).updateMany({}, updateDoc);
    }
  }
};
