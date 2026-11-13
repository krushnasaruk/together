/**
 * Together Dedicated Realtime Backend & Notification Hub
 *
 * Optimized for 24/7 Render deployment.
 * Supports:
 * - Ping keepalive endpoint (/ping) to prevent Render 10-minute spin down
 * - REST API for notifications, statuses, and partner pokes
 * - WebSocket connection for instant sub-second in-app notification banners
 */

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 10000;

app.use(cors());
app.use(express.json());

// In-memory message and status store (can be connected to MongoDB / Firebase)
const notifications = [];
const partnerStatuses = {};
const pokeHistory = [];

// 1. Root and Keepalive Ping Endpoints
app.get('/', (req, res) => {
  res.json({
    app: 'Together - Couples Shared Calendar Backend',
    version: '1.0.0',
    status: 'online',
    uptimeSeconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString(),
    keepalive: 'Every 5 minutes to prevent Render idle suspension',
  });
});

app.get('/ping', (req, res) => {
  res.json({
    status: 'ok',
    message: 'pong - Together keepalive active',
    time: new Date().toISOString(),
    uptime: `${Math.floor(process.uptime())}s`,
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    memoryUsage: process.memoryUsage(),
    activeSockets: wss ? wss.clients.size : 0,
    notificationCount: notifications.length,
  });
});

// 2. Notification Endpoints
app.get('/api/notifications', (req, res) => {
  const { recipientId, coupleId } = req.query;
  let filtered = notifications;

  if (recipientId) {
    filtered = filtered.filter((n) => n.recipientId === recipientId);
  }
  if (coupleId) {
    filtered = filtered.filter((n) => n.coupleId === coupleId);
  }

  res.json({
    success: true,
    count: filtered.length,
    notifications: filtered.slice(0, 50),
  });
});

app.post('/api/notifications', (req, res) => {
  const { recipientId, senderId, senderName, type, title, body, entityId, coupleId } = req.body;

  if (!recipientId || !title || !body) {
    return res.status(400).json({ error: 'recipientId, title, and body are required' });
  }

  const notification = {
    id: `notif_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
    recipientId,
    senderId: senderId || 'unknown',
    senderName: senderName || 'Partner',
    type: type || 'custom',
    title,
    body,
    entityId: entityId || null,
    coupleId: coupleId || 'couple_workspace_01',
    isRead: false,
    createdAt: new Date().toISOString(),
  };

  notifications.unshift(notification);
  if (notifications.length > 200) notifications.pop();

  // Broadcast to connected WebSockets
  broadcastToRecipient(recipientId, {
    type: 'NEW_NOTIFICATION',
    data: notification,
  });

  res.status(201).json({ success: true, notification });
});

// 3. Playful Poke / Nudge Endpoint ("콕 찌르기")
app.post('/api/poke', (req, res) => {
  const { senderId, senderName, recipientId, pokeType, customMessage } = req.body;

  const pokeMessages = {
    poke: '👉 sent you a gentle poke!',
    hug: '🤗 sent you a warm cozy hug!',
    miss_you: '💭 is thinking of you right now!',
    nudge: '⏰ nudged: "Check our plans for today!"',
    snack: '🥪 asks: "Have you had something to eat?"',
  };

  const bodyText = customMessage || pokeMessages[pokeType] || '👉 poked you!';

  const pokeNotification = {
    id: `poke_${Date.now()}`,
    recipientId,
    senderId,
    senderName: senderName || 'Partner',
    type: 'partnerPoke',
    title: `${senderName || 'Partner'} poked you!`,
    body: bodyText,
    pokeType: pokeType || 'poke',
    createdAt: new Date().toISOString(),
  };

  notifications.unshift(pokeNotification);
  pokeHistory.unshift(pokeNotification);

  // Broadcast instantly to partner
  broadcastToRecipient(recipientId, {
    type: 'PARTNER_POKE',
    data: pokeNotification,
  });

  res.json({ success: true, message: 'Poke dispatched!', notification: pokeNotification });
});

// 4. Partner Status Endpoints
app.post('/api/status', (req, res) => {
  const { userId, userName, coupleId, preset, customNote, expiresAt } = req.body;

  if (!userId || !preset) {
    return res.status(400).json({ error: 'userId and preset are required' });
  }

  const statusUpdate = {
    userId,
    userName: userName || 'User',
    coupleId: coupleId || 'couple_workspace_01',
    preset,
    customNote: customNote || null,
    updatedAt: new Date().toISOString(),
    expiresAt: expiresAt || new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
  };

  partnerStatuses[userId] = statusUpdate;

  // Broadcast to couple members
  broadcastToCouple(coupleId, {
    type: 'STATUS_UPDATE',
    data: statusUpdate,
  });

  res.json({ success: true, status: statusUpdate });
});

app.get('/api/status', (req, res) => {
  res.json({ success: true, statuses: partnerStatuses });
});

// Create HTTP server & WebSocket server
const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/ws' });

// Store client subscriptions
const clientSubscriptions = new Map(); // ws -> { userId, coupleId }

wss.on('connection', (ws) => {
  debugLog('Client connected via WebSocket');

  ws.on('message', (messageRaw) => {
    try {
      const msg = JSON.parse(messageRaw);
      if (msg.action === 'IDENTIFY') {
        clientSubscriptions.set(ws, {
          userId: msg.userId,
          coupleId: msg.coupleId || 'couple_workspace_01',
        });
        ws.send(JSON.stringify({ type: 'IDENTIFIED', message: 'Ready for real-time alerts' }));
      }
    } catch (_) {}
  });

  ws.on('close', () => {
    clientSubscriptions.delete(ws);
  });
});

function broadcastToRecipient(recipientId, payload) {
  const payloadStr = JSON.stringify(payload);
  for (const [client, meta] of clientSubscriptions.entries()) {
    if (client.readyState === WebSocket.OPEN && meta.userId === recipientId) {
      client.send(payloadStr);
    }
  }
}

function broadcastToCouple(coupleId, payload) {
  const payloadStr = JSON.stringify(payload);
  for (const [client, meta] of clientSubscriptions.entries()) {
    if (client.readyState === WebSocket.OPEN && meta.coupleId === coupleId) {
      client.send(payloadStr);
    }
  }
}

function debugLog(msg) {
  if (process.env.NODE_ENV !== 'production') {
    console.log(`[TogetherBackend] ${msg}`);
  }
}

server.listen(PORT, () => {
  console.log(`✨ Together Backend running on port ${PORT}`);
  console.log(`🔗 Keepalive Ping URL: http://localhost:${PORT}/ping`);
});

