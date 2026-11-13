# Together Realtime Backend & Notification Hub

This service powers real-time synchronization, partner push/in-app notifications, partner status updates, and playful pokes ("콕 찌르기") for the Together mobile application.

---

## 🚀 1-Click Render Deployment Guide

Render's free tier suspends inactive web services after 10 minutes.
Together includes a built-in **5-minute keepalive ping service** (`/ping`) that automatically runs from the Flutter client, keeping this server 100% active 24/7 without ever spinning down!

### Steps to Deploy on Render:

1. **Sign in to Render:**  
   Go to [dashboard.render.com](https://dashboard.render.com/) (free account).

2. **Create New Web Service:**  
   - Click **New +** -> **Web Service**.
   - Connect your GitHub repository (`together`).
   - Root Directory: `server`
   - Runtime: `Node`
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Plan: **Free**

3. **Deploy & Copy URL:**  
   - Click **Create Web Service**.
   - Render will build and assign you a URL (e.g. `https://together-backend.onrender.com`).

4. **Verify Health:**  
   - Visit `https://your-app.onrender.com/ping` in your browser.
   - You will see:
     ```json
     {
       "status": "ok",
       "message": "pong - Together keepalive active",
       "time": "2026-11-13T17:50:00.000Z",
       "uptime": "120s"
     }
     ```

5. **Connect Flutter App:**  
   - In Together app Settings or `RenderKeepAliveService.defaultRenderUrl`, set your Render URL.
   - Together automatically pings `/ping` every 5 minutes in the background, keeping your backend awake permanently.

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/ping` | Lightweight 5-minute keepalive endpoint |
| `GET` | `/api/health` | Service uptime and active socket counts |
| `GET` | `/api/notifications` | Fetch unread notifications for user/couple |
| `POST` | `/api/notifications` | Dispatch notification to partner |
| `POST` | `/api/poke` | Send instant poke / nudge ("콕 찌르기") |
| `POST` | `/api/status` | Broadcast status change |
| `GET` | `/api/status` | Read active statuses |
| `WS` | `/ws` | Bidirectional real-time notification socket |

