// In this file you can configure migrate-mongo

// For dev, whack this command in your terminal:
// export DBURL="mongodb://root:foobar@localhost:27017/ps2alerts?authSource=admin&readPreference=primary&directConnection=true&ssl=false"

const config = {
  mongodb: {
    url: process.env.DBURL ? process.env.DBURL : "mongodb://" + process.env.DBUSER + ":" + process.env.DBPASS + "@localhost:27017/" + process.env.DBNAME,

    options: {
      useNewUrlParser: true, // removes a deprecation warning when connecting
      useUnifiedTopology: true, // removes a deprecating warning when connecting
      //   connectTimeoutMS: 3600000, // increase connection timeout to 1 hour
      //   socketTimeoutMS: 3600000, // increase socket timeout to 1 hour
    }
  },

  // The migrations dir, can be an relative or absolute path. Only edit this when really necessary.
  migrationsDir: "migrations",

  // The mongodb collection where the applied changes are stored. Only edit this when really necessary.
  changelogCollectionName: "migrations",

  // The file extension to create migrations and search for in migration dir
  migrationFileExtension: ".js",

  moduleSystem: 'commonjs',

  // Enable the algorithm to create a checksum of the file contents and use that in the comparison to determin
  // if the file should be run.  Requires that scripts are coded to be run multiple times.
  useFileHash: false
};


// Return the config as a promise
module.exports = config;
