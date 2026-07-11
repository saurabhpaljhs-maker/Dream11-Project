const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.disable("x-powered-by");

app.get("/", (req, res) => {
  res.json({
    message: "DevOps Mega Project - App is live!",
    pod: process.env.HOSTNAME || "local",
    version: process.env.APP_VERSION || "1.0.0",
  });
});

app.get("/health", (req, res) => res.status(200).send("OK"));
app.get("/ready", (req, res) => res.status(200).send("READY"));

app.listen(PORT, () => console.log(`App listening on port ${PORT}`));
