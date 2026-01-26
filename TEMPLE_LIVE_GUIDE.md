# Temple Live Feature Guide

## Overview

The Temple Live feature allows users to watch live streams from temples and religious places, view daily schedules, get special pooja alerts, and explore temple profiles with location and deity information.

## Features

### 1. Live Temple Streaming (Video/Audio)

- Watch live darshan from temples across India
- Real-time viewer count display
- Full-screen video player with controls
- Live chat during streams
- Picture-in-picture support (planned)

### 2. Daily Schedule & Special Pooja Alerts

- View today's schedule for each temple
- Set notifications for specific poojas
- Get alerts for special events and festivals
- Customizable notification preferences

### 3. Temple Profile

- Detailed temple information
- Deity and religion details
- Location with map integration
- Opening hours and timings
- Photo gallery
- Upcoming events calendar

## User Flow

1. **Access Temple Live**
   - Tap "Temple Live" story icon on home screen (with LIVE badge)
   - View list of currently live temples

2. **Browse Temples**
   - Two tabs: "LIVE Now" and "All Temples"
   - Filter by religion (Hindu, Sikh, Islam, Christian, Buddhist)
   - Search by temple name, city, or deity

3. **Watch Live Stream**
   - Tap on a live temple card
   - Watch video/audio stream
   - View today's schedule alongside
   - Chat with other viewers
   - Subscribe for future alerts

4. **View Temple Details**
   - Tap on any temple card
   - View full temple profile
   - See location on map
   - Browse upcoming events
   - Get directions

5. **Subscribe for Alerts**
   - Tap subscribe button on any temple
   - Choose notification preferences:
     - Live stream alerts
     - Daily pooja notifications
     - Festival reminders
     - Special event alerts

## File Structure

```
lib/
├── models/
│   └── temple_live_model.dart      # TempleLive, TempleEvent, TempleSubscription models
├── services/
│   └── temple_live_service.dart    # API service for temple operations
├── screens/
│   └── temple/
│       ├── temple_live_screen.dart    # Main temple list screen
│       ├── temple_stream_screen.dart  # Live stream player screen
│       └── temple_detail_screen.dart  # Temple profile screen
└── widgets/
    └── user_stories_bar.dart          # Updated with LIVE badge support
```

## API Endpoints

| Endpoint                 | Method | Description                             |
| ------------------------ | ------ | --------------------------------------- |
| `/temples/live`          | GET    | Get all currently live temples          |
| `/temples`               | GET    | Get all temples (with optional filters) |
| `/temples/{id}`          | GET    | Get temple details by ID                |
| `/temples/{id}/schedule` | GET    | Get today's schedule for a temple       |
| `/temples/{id}/events`   | GET    | Get upcoming events for a temple        |
| `/temples/subscribe`     | POST   | Subscribe to temple alerts              |
| `/temples/subscribe`     | DELETE | Unsubscribe from temple alerts          |
| `/temples/search`        | GET    | Search temples by name, city, or deity  |

## Database Schema

### temples Table

```sql
id              UUID PRIMARY KEY
name            VARCHAR(255) NOT NULL
city            VARCHAR(100) NOT NULL
state           VARCHAR(100)
religion        VARCHAR(50)
deity           VARCHAR(255)
description     TEXT
stream_url      TEXT
is_live         BOOLEAN DEFAULT FALSE
thumbnail_url   TEXT
viewer_count    INTEGER DEFAULT 0
live_started_at TIMESTAMP
timings         VARCHAR(255)
latitude        DECIMAL(10, 8)
longitude       DECIMAL(11, 8)
created_at      TIMESTAMP
```

### temple_subscriptions Table

```sql
id                    UUID PRIMARY KEY
temple_id             UUID REFERENCES temples(id)
user_id               UUID
notify_live           BOOLEAN DEFAULT TRUE
notify_pooja          BOOLEAN DEFAULT TRUE
notify_festivals      BOOLEAN DEFAULT TRUE
notify_special_events BOOLEAN DEFAULT TRUE
subscribed_at         TIMESTAMP
```

### temple_events Table

```sql
id          UUID PRIMARY KEY
temple_id   UUID REFERENCES temples(id)
title       VARCHAR(255) NOT NULL
description TEXT
event_type  VARCHAR(50)
event_date  TIMESTAMP
is_special  BOOLEAN DEFAULT FALSE
```

## Navigation

The Temple Live screen can be accessed from:

1. **Home Screen Stories Bar** - Tap the "Temple Live" story icon (with LIVE badge)
2. **Direct Route** - `/temple-live` (planned)

## UI Components

### Temple Live Screen

- Tab bar with "LIVE Now" and "All Temples"
- Search bar for filtering
- Religion filter chips
- Live temple cards with:
  - Thumbnail with LIVE badge
  - Viewer count
  - Temple name and location
  - Deity information
  - Subscribe button

### Temple Stream Screen

- Video player with controls (play/pause, mute, fullscreen)
- LIVE indicator with viewer count
- Today's schedule tab
- Temple info tab
- Live chat section
- Share and subscribe buttons

### Temple Detail Screen

- Hero image with temple photo
- Quick info (religion, deity, location, timings)
- Watch Live button (if live)
- About section
- Today's schedule timeline
- Upcoming events cards
- Location map
- Subscription options

## Mock Data

The service includes mock data for 10 temples across different religions:

- 4 Live temples (Tirupati, Golden Temple, Kashi Vishwanath, ISKCON)
- 6 Offline temples (Siddhivinayak, Meenakshi, Jama Masjid, Basilica, Mahabodhi, Charminar)

## Testing

1. **Access Temple Live**
   - Open the app
   - Tap on "Temple Live" story (should have LIVE badge)
   - Verify the temple list loads

2. **Watch Live Stream**
   - Tap on a live temple
   - Verify video player opens
   - Test play/pause, mute, fullscreen controls
   - Check schedule and info tabs

3. **Subscribe to Temple**
   - Tap subscribe button
   - Verify success message
   - Check subscribed temples list (bell icon)

4. **Search and Filter**
   - Search for a temple by name
   - Filter by religion
   - Verify results update correctly

## Future Enhancements

1. **Video Integration**
   - Integrate with YouTube Live API
   - Support RTMP streams
   - Add picture-in-picture mode

2. **Push Notifications**
   - Live stream start alerts
   - Daily pooja reminders
   - Festival notifications

3. **Social Features**
   - Share live streams
   - Comment on streams
   - Temple ratings and reviews

4. **Offline Support**
   - Download schedules for offline viewing
   - Cache temple profiles

5. **AR Features**
   - Virtual darshan
   - Temple tour
