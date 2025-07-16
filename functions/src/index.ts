import * as functions from "firebase-functions";
import express, { Request, Response } from "express";
import cors from "cors";
import { getFirestore } from "firebase-admin/firestore";
import * as admin from "firebase-admin";
admin.initializeApp();
const db = getFirestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json()); // Important for parsing JSON bodies

// Example hello route
app.get("/hello", (req: Request, res: Response) => {
  res.send("Hello from Firebase Functions!");
});

// Register route
app.post("/register", async (req: Request, res: Response) => {
  const { name, email, password } = req.body;
  try {
    // Create a new user document in Firestore
    const userRef = await db.collection("users").add({ name, email, password });
    res.status(201).json({ message: "User registered!", id: userRef.id, name, email });
  } catch (err) {
    res.status(500).json({ error: "Firestore error", details: err });
  }
});

// Tasks route - GET all tasks
app.get("/tasks", async (req: Request, res: Response) => {
  try {
    const snapshot = await db.collection("tasks").get();
    const tasks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: "Firestore error", details: err });
  }
});

// Tasks route - POST create a new task
app.post("/tasks", async (req: Request, res: Response) => {
  const task = req.body;
  try {
    const taskRef = await db.collection("tasks").add(task);
    res.status(201).json({ message: "Task created!", id: taskRef.id, ...task });
  } catch (err) {
    res.status(500).json({ error: "Firestore error", details: err });
  }
});

// TODO: Add your other routes (register, login, tasks, etc.)

export const api = functions.https.onRequest(app);
