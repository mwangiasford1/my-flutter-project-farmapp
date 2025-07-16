const express = require('express');
const http = require('http');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const JWT_SECRET = 'your_jwt_secret'; // Use a strong secret in production
const fetch = require('node-fetch');
const cron = require('node-cron');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(cors());
app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root', // <-- CHANGE THIS
  password: '1234', // <-- CHANGE THIS
  database: 'farmers_financial_tracker'
});
db.connect(err => {
  if (err) throw err;
  console.log('MySQL connected!');
});

// --- REST API ---

// Tasks
app.get('/tasks', (req, res) => {
  const userId = req.query.userId;
  db.query('SELECT * FROM tasks WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/tasks', (req, res) => {
  const task = req.body;
  db.query('INSERT INTO tasks SET ?', task, (err, result) => {
    if (err) {
      console.error('Failed to insert task:', err); // Log the error for debugging
      return res.status(500).json({ error: err });
    }
    const newTask = { ...task, id: result.insertId };
    io.to(task.userId).emit('task_update', newTask);
    res.status(201).json(newTask);
  });
});
app.put('/tasks/:id', (req, res) => {
  const id = req.params.id;
  const task = req.body;
  db.query('UPDATE tasks SET ? WHERE id = ?', [task, id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(task.userId).emit('task_update', { ...task, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/tasks/:id', (req, res) => {
  const id = req.params.id;
  const userId = req.query.userId;
  db.query('DELETE FROM tasks WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('task_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Transactions
app.get('/transactions', (req, res) => {
  const userId = req.query.userId;
  db.query('SELECT * FROM transactions WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/transactions', (req, res) => {
  const tx = req.body;
  db.query('INSERT INTO transactions SET ?', tx, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newTx = { ...tx, id: result.insertId };
    io.to(tx.userId).emit('transaction_update', newTx);
    res.status(201).json(newTx);
  });
});
app.put('/transactions/:id', (req, res) => {
  const id = req.params.id;
  const tx = req.body;
  db.query('UPDATE transactions SET ? WHERE id = ?', [tx, id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(tx.userId).emit('transaction_update', { ...tx, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/transactions/:id', (req, res) => {
  const id = req.params.id;
  const userId = req.query.userId;
  db.query('DELETE FROM transactions WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('transaction_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Yields
app.get('/yields', (req, res) => {
  const userId = req.query.userId;
  db.query('SELECT * FROM yields WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/yields', (req, res) => {
  const yieldRecord = req.body;
  db.query('INSERT INTO yields SET ?', yieldRecord, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newYield = { ...yieldRecord, id: result.insertId };
    io.to(yieldRecord.userId).emit('yield_update', newYield);
    res.status(201).json(newYield);
  });
});
app.put('/yields/:id', (req, res) => {
  const id = req.params.id;
  const yieldRecord = req.body;
  db.query('UPDATE yields SET ? WHERE id = ?', [yieldRecord, id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(yieldRecord.userId).emit('yield_update', { ...yieldRecord, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/yields/:id', (req, res) => {
  const id = req.params.id;
  const userId = req.query.userId;
  db.query('DELETE FROM yields WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('yield_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Farm Sections
app.get('/farm_sections', (req, res) => {
  const userId = req.query.userId;
  db.query('SELECT * FROM farm_sections WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/farm_sections', (req, res) => {
  const section = req.body;
  db.query('INSERT INTO farm_sections SET ?', section, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newSection = { ...section, id: result.insertId };
    io.to(section.userId).emit('farm_section_update', newSection);
    res.status(201).json(newSection);
  });
});
app.put('/farm_sections/:id', (req, res) => {
  const id = req.params.id;
  const section = req.body;
  db.query('UPDATE farm_sections SET ? WHERE id = ?', [section, id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(section.userId).emit('farm_section_update', { ...section, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/farm_sections/:id', (req, res) => {
  const id = req.params.id;
  const userId = req.query.userId;
  db.query('DELETE FROM farm_sections WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('farm_section_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Weather
app.get('/weather', (req, res) => {
  const location = req.query.location;
  db.query('SELECT * FROM weather WHERE location = ? ORDER BY date DESC LIMIT 1', [location], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results[0] || {});
  });
});
app.post('/weather', (req, res) => {
  const weather = req.body;
  db.query('INSERT INTO weather SET ?', weather, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newWeather = { ...weather, id: result.insertId };
    io.to(weather.location).emit('weather_update', newWeather);
    res.status(201).json(newWeather);
  });
});

// User registration
app.post('/register', (req, res) => {
  const { username, password } = req.body;
  const hash = bcrypt.hashSync(password, 10);
  db.query('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash], (err, result) => {
    if (err) return res.status(500).json({ error: err });
    res.status(201).json({ success: true });
  });
});

// User login
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  db.query('SELECT * FROM users WHERE username = ?', [username], (err, results) => {
    if (err || results.length === 0) return res.status(401).json({ error: 'Invalid credentials' });
    const user = results[0];
    if (!bcrypt.compareSync(password, user.password)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = jwt.sign({ userId: user.id, username: user.username }, JWT_SECRET, { expiresIn: '1d' });
    res.json({ token });
  });
});

// Request password reset (send email with token)
app.post('/request-password-reset', (req, res) => {
  const { email } = req.body;
  db.query('SELECT * FROM users WHERE username = ?', [email], (err, results) => {
    if (err || results.length === 0) return res.status(404).json({ error: 'User not found' });
    const token = crypto.randomBytes(32).toString('hex');
    resetTokens[token] = { email, expires: Date.now() + 3600 * 1000 }; // 1 hour expiry

    // Send email
    const resetLink = `http://your-frontend-url/reset-password?token=${token}`;
    transporter.sendMail({
      from: 'your_email@gmail.com', // CHANGE THIS
      to: email,
      subject: 'Password Reset',
      html: `
    <div style="font-family: Arial, sans-serif; padding: 20px;">
      <h2>Password Reset Request</h2>
      <p>Click the button below to reset your password:</p>
      <a href="${resetLink}" style="display:inline-block;padding:10px 20px;background:#4CAF50;color:#fff;text-decoration:none;border-radius:5px;">Reset Password</a>
      <p>If you did not request this, you can ignore this email.</p>
      <p style="font-size:12px;color:#888;">&copy; ${new Date().getFullYear()} Your App Name</p>
    </div>
  `
    }, (err, info) => {
      if (err) return res.status(500).json({ error: 'Failed to send email' });
      res.json({ success: true });
    });
  });
});

// Reset password with token
app.post('/reset-password', (req, res) => {
  const { token, newPassword } = req.body;
  const record = resetTokens[token];
  if (!record || record.expires < Date.now()) {
    return res.status(400).json({ error: 'Invalid or expired token' });
  }
  const hash = bcrypt.hashSync(newPassword, 10);
  db.query('UPDATE users SET password = ? WHERE username = ?', [hash, record.email], (err, result) => {
    if (err) return res.status(500).json({ error: err });
    delete resetTokens[token];
    res.json({ success: true });
  });
});

// JWT middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

// Example protected route
app.get('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'This is protected', user: req.user });
});

// --- PROTECTED REST API ---

// Tasks
app.get('/tasks', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  db.query('SELECT * FROM tasks WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/tasks', authenticateToken, (req, res) => {
  const task = { ...req.body, userId: req.user.userId };
  db.query('INSERT INTO tasks SET ?', task, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newTask = { ...task, id: result.insertId };
    io.to(task.userId).emit('task_update', newTask);
    res.status(201).json(newTask);
  });
});
app.put('/tasks/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const task = { ...req.body, userId: req.user.userId };
  db.query('UPDATE tasks SET ? WHERE id = ? AND userId = ?', [task, id, task.userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(task.userId).emit('task_update', { ...task, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/tasks/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const userId = req.user.userId;
  db.query('DELETE FROM tasks WHERE id = ? AND userId = ?', [id, userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('task_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Transactions
app.get('/transactions', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  db.query('SELECT * FROM transactions WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/transactions', authenticateToken, (req, res) => {
  const tx = { ...req.body, userId: req.user.userId };
  db.query('INSERT INTO transactions SET ?', tx, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newTx = { ...tx, id: result.insertId };
    io.to(tx.userId).emit('transaction_update', newTx);
    res.status(201).json(newTx);
  });
});
app.put('/transactions/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const tx = { ...req.body, userId: req.user.userId };
  db.query('UPDATE transactions SET ? WHERE id = ? AND userId = ?', [tx, id, tx.userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(tx.userId).emit('transaction_update', { ...tx, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/transactions/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const userId = req.user.userId;
  db.query('DELETE FROM transactions WHERE id = ? AND userId = ?', [id, userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('transaction_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Yields
app.get('/yields', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  db.query('SELECT * FROM yields WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/yields', authenticateToken, (req, res) => {
  const yieldRecord = { ...req.body, userId: req.user.userId };
  db.query('INSERT INTO yields SET ?', yieldRecord, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newYield = { ...yieldRecord, id: result.insertId };
    io.to(yieldRecord.userId).emit('yield_update', newYield);
    res.status(201).json(newYield);
  });
});
app.put('/yields/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const yieldRecord = { ...req.body, userId: req.user.userId };
  db.query('UPDATE yields SET ? WHERE id = ? AND userId = ?', [yieldRecord, id, yieldRecord.userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(yieldRecord.userId).emit('yield_update', { ...yieldRecord, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/yields/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const userId = req.user.userId;
  db.query('DELETE FROM yields WHERE id = ? AND userId = ?', [id, userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('yield_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Farm Sections
app.get('/farm_sections', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  db.query('SELECT * FROM farm_sections WHERE userId = ?', [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
app.post('/farm_sections', authenticateToken, (req, res) => {
  const section = { ...req.body, userId: req.user.userId };
  db.query('INSERT INTO farm_sections SET ?', section, (err, result) => {
    if (err) return res.status(500).json({ error: err });
    const newSection = { ...section, id: result.insertId };
    io.to(section.userId).emit('farm_section_update', newSection);
    res.status(201).json(newSection);
  });
});
app.put('/farm_sections/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const section = { ...req.body, userId: req.user.userId };
  db.query('UPDATE farm_sections SET ? WHERE id = ? AND userId = ?', [section, id, section.userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(section.userId).emit('farm_section_update', { ...section, id: Number(id) });
    res.json({ success: true });
  });
});
app.delete('/farm_sections/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  const userId = req.user.userId;
  db.query('DELETE FROM farm_sections WHERE id = ? AND userId = ?', [id, userId], (err) => {
    if (err) return res.status(500).json({ error: err });
    io.to(userId).emit('farm_section_delete', { id: Number(id) });
    res.json({ success: true });
  });
});

// Weather endpoints remain public or can be protected as needed.

// --- Socket.IO Real-time Events ---
io.on('connection', (socket) => {
  // User rooms
  socket.on('join_user', (userId) => {
    socket.join(userId);
  });
  // Location rooms (for weather)
  socket.on('join_location', (location) => {
    socket.join(location);
  });

  // Tasks
  socket.on('new_task', (task) => {
    db.query('INSERT INTO tasks SET ?', task, (err, result) => {
      if (err) return socket.emit('task_error', { error: err });
      const newTask = { ...task, id: result.insertId };
      io.to(task.userId).emit('task_update', newTask);
    });
  });
  socket.on('update_task', (task) => {
    db.query('UPDATE tasks SET ? WHERE id = ?', [task, task.id], (err) => {
      if (err) return socket.emit('task_error', { error: err });
      io.to(task.userId).emit('task_update', task);
    });
  });
  socket.on('delete_task', ({ id, userId }) => {
    db.query('DELETE FROM tasks WHERE id = ?', [id], (err) => {
      if (err) return socket.emit('task_error', { error: err });
      io.to(userId).emit('task_delete', { id });
    });
  });

  // Transactions
  socket.on('new_transaction', (tx) => {
    db.query('INSERT INTO transactions SET ?', tx, (err, result) => {
      if (err) return socket.emit('transaction_error', { error: err });
      const newTx = { ...tx, id: result.insertId };
      io.to(tx.userId).emit('transaction_update', newTx);
    });
  });
  socket.on('update_transaction', (tx) => {
    db.query('UPDATE transactions SET ? WHERE id = ?', [tx, tx.id], (err) => {
      if (err) return socket.emit('transaction_error', { error: err });
      io.to(tx.userId).emit('transaction_update', tx);
    });
  });
  socket.on('delete_transaction', ({ id, userId }) => {
    db.query('DELETE FROM transactions WHERE id = ?', [id], (err) => {
      if (err) return socket.emit('transaction_error', { error: err });
      io.to(userId).emit('transaction_delete', { id });
    });
  });

  // Yields
  socket.on('new_yield', (yieldRecord) => {
    db.query('INSERT INTO yields SET ?', yieldRecord, (err, result) => {
      if (err) return socket.emit('yield_error', { error: err });
      const newYield = { ...yieldRecord, id: result.insertId };
      io.to(yieldRecord.userId).emit('yield_update', newYield);
    });
  });
  socket.on('update_yield', (yieldRecord) => {
    db.query('UPDATE yields SET ? WHERE id = ?', [yieldRecord, yieldRecord.id], (err) => {
      if (err) return socket.emit('yield_error', { error: err });
      io.to(yieldRecord.userId).emit('yield_update', yieldRecord);
    });
  });
  socket.on('delete_yield', ({ id, userId }) => {
    db.query('DELETE FROM yields WHERE id = ?', [id], (err) => {
      if (err) return socket.emit('yield_error', { error: err });
      io.to(userId).emit('yield_delete', { id });
    });
  });

  // Farm Sections
  socket.on('new_farm_section', (section) => {
    db.query('INSERT INTO farm_sections SET ?', section, (err, result) => {
      if (err) return socket.emit('farm_section_error', { error: err });
      const newSection = { ...section, id: result.insertId };
      io.to(section.userId).emit('farm_section_update', newSection);
    });
  });
  socket.on('update_farm_section', (section) => {
    db.query('UPDATE farm_sections SET ? WHERE id = ?', [section, section.id], (err) => {
      if (err) return socket.emit('farm_section_error', { error: err });
      io.to(section.userId).emit('farm_section_update', section);
    });
  });
  socket.on('delete_farm_section', ({ id, userId }) => {
    db.query('DELETE FROM farm_sections WHERE id = ?', [id], (err) => {
      if (err) return socket.emit('farm_section_error', { error: err });
      io.to(userId).emit('farm_section_delete', { id });
    });
  });

  // Weather
  socket.on('new_weather', (weather) => {
    db.query('INSERT INTO weather SET ?', weather, (err, result) => {
      if (err) return socket.emit('weather_error', { error: err });
      const newWeather = { ...weather, id: result.insertId };
      io.to(weather.location).emit('weather_update', newWeather);
    });
  });
});

// Automated weather recording (every hour)
cron.schedule('0 * * * *', async () => {
  const location = 'Thika';
  const apiKey = '8ee32c6c7e64692ad291cf7d87ffe863';
  const url = `https://api.openweathermap.org/data/2.5/weather?q=${location}&appid=${apiKey}&units=metric`;

  try {
    const response = await fetch(url);
    const data = await response.json();
    if (data.main) {
      const weather = {
        date: new Date(),
        temperature: data.main.temp,
        humidity: data.main.humidity,
        condition: data.weather[0].main,
        rainfall: data.rain ? data.rain['1h'] || 0 : 0,
        location: location
      };
      db.query('INSERT INTO weather SET ?', weather, (err, result) => {
        if (err) console.error('Failed to insert weather:', err);
        else console.log('Automated weather recorded:', weather);
        io.to(location).emit('weather_update', { ...weather, id: result?.insertId });
      });
    }
  } catch (err) {
    console.error('Failed to fetch weather:', err);
  }
});

const PORT = 3001;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`)); 