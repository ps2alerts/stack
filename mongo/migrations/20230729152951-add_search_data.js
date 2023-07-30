const collections = [
  "aggregate_global_characters",
  "aggregate_global_outfits"
]

const filter = {bracket: 0, ps2AlertsEventType: 1}

module.exports = {
  async up(db, client) {
    for (const table of collections) {
      console.log(`Updating ${table} to add searchIndexed data... (grab a snickers this is gonna take ages)`)
      const collection = db.collection(table)
      const countDocuments = await collection.countDocuments(filter)
      console.log(`Detected ${countDocuments} documents to update...`);
      await collection.updateMany(filter, {$set: {searchIndexed: false}})
    }
  },

  async down(db, client) {
    for (const table of collections) {
      const collection = db.collection(table)
      console.log(`Updating ${table} to remove searchIndexed data...`)

      await collection.updateMany({}, {$unset: {searchIndexed: ""}})
    }
  }
};
