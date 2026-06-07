const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("Hello from Node backend");
});

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    app: "my-api",
    message: "Backend is running on VPS",
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

app.listen(port, "127.0.0.1", () => {
  console.log(`Server running at http://127.0.0.1:${port}`);
});
