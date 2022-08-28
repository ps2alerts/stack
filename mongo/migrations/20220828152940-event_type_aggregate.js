const aggregateCollections = [
  "aggregate_global_characters",
  "aggregate_global_facility_controls",
  "aggregate_global_faction_combats",
  "aggregate_global_loadouts",
  "aggregate_global_outfits",
  "aggregate_global_vehicles",
  // "aggregate_global_vehicles_characters", // 13m+ records, fuck no
  "aggregate_global_victories",
  "aggregate_global_weapons",
  "aggregate_instance_characters",
  "aggregate_instance_combat_histories",
  "aggregate_instance_facility_controls",
  "aggregate_instance_faction_combats",
  "aggregate_instance_loadouts",
  "aggregate_instance_outfits",
  "aggregate_instance_vehicles",
  // "aggregate_instance_vehicles_characters", 23m+ records, fuck no
  "aggregate_instance_weapons",
]

module.exports = {
  async up(db, client) {
    let updateDoc = [{"$set":{"ps2AlertsEventType": 1}}];

    console.log(updateDoc);

    for (const collection of aggregateCollections) {
      console.log(`Setting event types for collection ${collection}...`)
      const result = await db.collection(collection).updateMany({}, updateDoc);
      console.log(`Updated ${result.modifiedCount} documents`);
    }
  },

  async down(db, client) {
    let updateDoc = [{"$unset":{"ps2AlertsEventType": 1}}];
    for (const collection of aggregateCollections) {
      await db.collection(collection).updateMany({}, updateDoc);
    }
    // TODO write the statements to rollback your migration (if possible)
    // Example:
    // await db.collection('albums').updateOne({artist: 'The Beatles'}, {$set: {blacklisted: false}});
  }
};
