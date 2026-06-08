const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const port = process.env.PORT || 3000;
const HOST = process.env.HOST || "127.0.0.1";

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

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

app.get("/api/db-check", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW() AS now");
    res.json({
      status: "ok",
      database: "connected",
      now: result.rows[0].now,
    });
  } catch (error) {
    console.error("Database check failed:", error);
    res.status(500).json({
      status: "error",
      message: "Database connection failed",
    });
  }
});

app.get("/api/notes", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, title, created_at FROM notes ORDER BY id ASC"
    );

    res.json({
      status: "ok",
      data: result.rows,
    });
  } catch (error) {
    console.error("Failed to fetch notes:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to fetch notes",
    });
  }
});

app.post("/api/notes", async (req, res) => {
  try {
    const title = req.body?.title;

    if (!title) {
      return res.status(400).json({
        status: "error",
        message: "title is required",
      });
    }

    const result = await pool.query(
      "INSERT INTO notes (title) VALUES ($1) RETURNING id, title, created_at",
      [title]
    );

    res.status(201).json({
      status: "ok",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Failed to create note:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to create note",
    });
  }
});

app.listen(port, HOST, () => {
  console.log(`Server running at http://${HOST}:${port}`);
});
