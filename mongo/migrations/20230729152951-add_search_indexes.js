const indexes = [
  {
    collection: "aggregate_global_characters",
    index: {
      key: "character.name",
      type: "text",
    }
  },
  {
    collection: "aggregate_global_outfits",
    index: {
      key: "outfit.name",
      type: "text"
    },
  }
]

module.exports = {
  async up(db, client) {
    for (const index of indexes) {
      const collection = db.collection(index.collection)
      await collection.createIndex({[index.index.key]: index.index.type})
    }
  },

  async down(db, client) {
    for (const index of indexes) {
      const collection = db.collection(index.collection)
      await collection.dropIndex({[index.index.key]: index.index.type})
    }
  }
};
