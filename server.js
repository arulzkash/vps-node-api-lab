const express = require("express");

const app = express();
const port = process.env.PORT || 3000;
const HOST = process.env.HOST || "127.0.0.1";

app.get("/", (req, res) => {
  res.send("Hello from Node backend");
});

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    app: "my-api",
    message: "Backend is running from Git deploy flow",
  });
});

app.get("/api/info", (req, res) => {
  res.json({
    app: "my-api",
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    server_time: new Date().toISOString(),
  });
});

app.get("/api/version", (req, res) => {
  res.json({
    version: "1.0.1",
    deployed_from: "git deploy flow",
  });
});

app.listen(port, HOST, () => {
  console.log(`Server running at http://${HOST}:${port}`);
});
