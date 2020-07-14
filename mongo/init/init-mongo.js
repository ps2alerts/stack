db.createUser(
    {
        user: "ps2alerts",
        pwd: "foobar",
        roles: [
            {
                role: "readWrite",
                db: "ps2alerts"
            }
        ]
    }
)
