module.exports = {
  async up(db) {
    let filter = {"character.asp": true, "character.id": {"$ne": null}};
    let updateDoc = [{"$set":{"character.asp": 1, "character.adjustedBattleRank": {"$add": ["$character.battleRank", 120]}}}];

    console.log("Updating ASP = true characters...");
    const result = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    console.log("Updating ASP = false characters (Some of these are ASP2 but they should eventually be picked up by death events)...");
    filter["character.asp"] = false;
    updateDoc[0]["$set"]["character.adjustedBattleRank"]["$add"][1] = 0;
    updateDoc[0]["$set"]["character.asp"] = 0;
    const result2 = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result2.matchedCount} document(s) matched the filter, updated ${result2.modifiedCount} document(s)\n`);

    filter["character.asp"] = null;
    console.log("Updating ASP = null characters (PS4)...");
    const result3 = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result3.matchedCount} document(s) matched the filter, updated ${result3.modifiedCount} document(s)`);

    filter["character.asp"] = undefined;
    console.log("Updating ASP = undefined characters (PS4)...");
    const result4 = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result3.matchedCount} document(s) matched the filter, updated ${result4.modifiedCount} document(s)\n`);
  },

  async down(db) {
    let filter = {"character.asp": 1};
    let updateDoc = [{"$set": { "character.asp": true }}, {"$unset": "character.adjustedBattleRank"}];

    console.log("Reverting ASP1 characters...");
    const result = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result.matchedCount} document(s) matched the filter, updated ${result.modifiedCount} document(s)\n`);

    console.log("Reverting non-ASP and ASP2 characters...");
    filter = {$or: [{"character.asp": 0}, {"character.asp": 2}]};
    updateDoc[0]["$set"]["character.asp"] = false;
    const result2 = await db.collection("aggregate_global_characters").updateMany(filter, updateDoc);
    console.log(`${result2.matchedCount} document(s) matched the filter, updated ${result2.modifiedCount} document(s)`);
  }
};
