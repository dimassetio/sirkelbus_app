# SirkelBus — System Flow & Project Context

## Overview

SirkelBus is a school bus booking system with three surfaces:

| Surface | Stack | Role |
|---|---|---|
| Mobile app | Flutter (GetX, Firebase) | User booking, live tracking, check-in |
| Admin web | Next.js 16 (App Router) | Schedule/route/trip management, booking oversight |
| Backend API | Next.js Route Handlers + Firebase Admin SDK | All writes go through here; mobile never writes Firestore directly |

All business logic runs in the Next.js API. The mobile app reads Firestore directly for real-time streams (booking status, trip location) but creates/mutates data through REST calls to the admin backend.

---

## User Roles

| Role | Access |
|---|---|
| `user` | Books trips, tracks bus, scans check-in barcode |
| `driver` | Views assigned trips, updates trip status and location |
| `admin` | Full CRUD on all collections, creates trips, manages schedules |

Role is stored in the `users` Firestore collection under each user's UID.

---

## Firestore Collections

### `schedules`

Defines a recurring bus departure. A schedule is not tied to a specific date — it repeats daily unless a day is in `disabledDays`.

| Field | Type | Notes |
|---|---|---|
| `routeId` | string | Reference to `routes` |
| `routeDirection` | string | `"pergi"` / `"pulang"` (to-school / from-school) |
| `departureTime` | string | `"HH:MM"` — local time |
| `arrivalTimeEstimate` | string | `"HH:MM"` |
| `arrivalEstimateMinutes` | number | Duration in minutes |
| `capacity` | number | Max passengers per service date |
| `bookingOpenHour` | string | `"HH:MM"` — when booking opens each day |
| `bookingCloseHour` | string | `"HH:MM"` — when booking closes each day |
| `repeatDaily` | boolean | If false the schedule is one-off |
| `disabledDays` | string[] | `["saturday", "sunday"]` etc. |
| `busIds` | string[] | Eligible buses |
| `driverIds` | string[] | Eligible drivers |

### `routes`

Defines the ordered list of stops for a route.

| Field | Type | Notes |
|---|---|---|
| `name` | string | Display name |
| `stopIds` | string[] | Ordered stop IDs |
| `routeDirection` | string | `"pergi"` / `"pulang"` |

### `stops`

Physical pickup/dropoff points.

| Field | Type | Notes |
|---|---|---|
| `name` | string | |
| `lat` / `lng` | number | GPS coordinates |
| `order` | number | Display order |
| `category` | string | `"normal"` / `"departure"` / `"school"` |
| `city` / `kecamatan` / `kelurahan` | string | Address breakdown |
| `active` | boolean | |

### `bookings`

One document per passenger per service date.

| Field | Type | Notes |
|---|---|---|
| `userId` | string | Firebase Auth UID |
| `scheduleId` | string | |
| `pickupStopId` | string | |
| `serviceDate` | string | `"YYYY-MM-DD"` — the date of travel |
| `status` | string | See lifecycle below |
| `source` | string | `"mobile-app"` / `"admin-demo"` |
| `note` | string | Operator note |
| `tripId` | string | Set when a trip is assigned |
| `boardedAt` | string | ISO timestamp of QR check-in |
| `boardedTripId` | string | Trip that scanned the check-in |
| `boardedBy` | string | Driver UID who performed check-in |
| `checkInBarcode` | string | Barcode value attached to the trip |
| `createdAt` | timestamp | |

**Document ID format:** `BKG-YYMMDD-NNN` (e.g. `BKG-260618-001`). Counter is scoped per date and resets the next day.

### `trips`

A trip is the live instance of a schedule running on a specific date with a specific bus and driver.

| Field | Type | Notes |
|---|---|---|
| `scheduleId` | string | |
| `routeId` | string | |
| `routeDirection` | string | `"pergi"` / `"pulang"` |
| `serviceDate` | string | `"YYYY-MM-DD"` |
| `driverId` | string | |
| `busId` | string | The bus assigned to this trip — also the QR payload scanned by passengers |
| `busCapacity` | number | |
| `status` | string | `"assigned"` → `"started"` → `"in_progress"` → `"completed"` (also `"waiting"`, `"cancelled"`) |
| `routeStops` | array | `{ stopId, name, order, estimatedPassengers, category? }[]` — the capacity-sweep plan, not a commitment of specific bookings |
| `bookingIds` | string[] | Bookings actually attached to this trip — populated only by boarding (scan or manual fallback), **not** at trip creation |
| `boardedBookingIds` / `boardedCount` | string[] / number | Bookings that have physically boarded |
| `progress` | object | `{ currentStopIndex, currentStopId, nextStopId, remainingStopIds, capacityReached, capacityReachedStopId, directToDestination, directRoutePath?, directRouteDistanceKm?, lastBoardedBookingId, lastBoardedStopId, lastBoardedAt }` |
| `estimatedPassengerCount` / `estimatedBookingCount` | number | Planning estimates from the capacity sweep, not actual boarded counts |
| `driverLatitude` / `driverLongitude` | number | Live GPS from driver app |
| `createdAt` / `startedAt` / `completedAt` / `updatedAt` | timestamp | |

A bus can only be on **one active trip per schedule** at a time — "active" means `status` is `assigned`, `started`, `in_progress`, or `waiting`. Once a trip is `completed` or `cancelled`, its bus is free to be assigned to a new trip on the same schedule+date.

---

## Booking Status Lifecycle

```
[User books]
     │
     ▼
"pending" (rider sees "Dipesan")  ──── Admin cancels ────► "cancelled"
     │
     │  Admin generates a trip for the schedule+date
     │  (trip.status: "assigned" — booking is NOT touched yet)
     ▼
"pending"  (still no tripId — rider sees "Dipesan", awaiting trip start)
     │
     │  Admin or driver starts the trip for this schedule+date
     │  (trip.status → "started", via /api/startTrip or
     │  /api/updateTripStatus). ALL "pending" bookings for that
     │  schedule+serviceDate flip to "confirmed" in bulk — every
     │  rider's "Dipesan" ticket becomes "Terkonfirmasi" at once.
     ▼
"confirmed"  (still no tripId — rider sees "Terkonfirmasi", no trip info)
     │
     │  User scans the bus's QR code (its busId)
     ▼
"confirmed" + tripId + boardedAt set  (checked in — this is the only
                                        moment a booking gets attached
                                        to a specific trip)
     │
     │  Trip ends (driver finishes OR user taps "selesai")
     ▼
"completed"
```

A booking is only ever linked to a trip at the moment its rider boards — there is no "assigned but not yet boarded" state for a booking, unlike a trip. Status is set server-side via the API or by the driver app; the mobile app only reads it via a Firestore stream.

**Pending → confirmed is a bulk, schedule-wide transition**, not per-booking: the instant a trip goes live for a schedule+serviceDate, *every* pending booking on that schedule+date is confirmed together — not just the rider who happens to be looking at their ticket. This happens in two places, both calling helpers in `src/lib/bookingHelpers.ts`:

- `POST /api/startTrip` (fixed-routing) — confirms pending bookings **inside the same Firestore transaction** that creates/upserts the trip (`confirmPendingBookingsInTransaction`), and folds them into the same capacity sweep as already-confirmed bookings so `routeStops`/`estimatedPassengerCount` reflect true demand.
- `POST /api/updateTripStatus` with `status: "started"` (dynamic-routing, or any restart) — confirms pending bookings via a standalone batch (`confirmPendingBookings`) after the trip status update commits.

**Demand counting before a trip exists** (route simulator, trip planner, trips monitor, manual trip-create form) treats `"pending"` and `"confirmed"` as equally real demand — `DEMAND_BOOKING_STATUSES` in `src/types/booking.ts`. There's no other way to plan a trip's capacity/stop order before it exists, since nothing can be "confirmed" yet.

---

## Booking Flow (User — Mobile)

### 1. Schedule selection

- `UserScheduleController` streams all schedules from `schedules` collection.
- Filtered client-side by `selectedDate` (must `runsOn()` that date) and direction (to-school / from-school, matched against `routeDirection`).
- User picks a date via date picker (`selectedDate` defaults to today).

### 2. Stop selection

- Tapping a schedule opens `StopMapView`.
- `StopMapController` loads the stop IDs from the matched `RouteModel`.
- Device GPS is requested; the nearest stop is pre-selected automatically.
- User can override by tapping any marker on the map.
- in direction to school user will select the pickup point, and the destination is set to the school location
- in direction from school user picked at school and user select the drop off location

### 3. Creating a booking

`UserScheduleController.book()` calls:

```
POST /api/user/bookings
Authorization: Bearer <Firebase ID Token>

{
  "scheduleId": "<id>",
  "pickupStopId": "<id>",
  "serviceDate": "YYYY-MM-DD"
}
```

**Server flow:**
1. Verify ID token → extract `userId`.
2. Fetch schedule → normalize `serviceDate` (falls back to schedule's `departureTime` date if not provided).
3. Check booking window: `new Date(serviceDate + T + bookingCloseHour)` must be in the future.
4. Generate booking ID (`BKG-YYMMDD-NNN`) **outside** the Firestore transaction.
5. Run transaction: re-verify schedule exists → `tx.set(bookingRef, bookingData)`.
6. Return `{ booking: { id, userId, scheduleId, pickupStopId, serviceDate, status: "pending", ... } }`.

**Booking window enforcement** happens on the server. The mobile's `ScheduleModel.isBookingOpen()` is a client-side pre-check only — the server is the source of truth.

---

## Trip Flow (Admin + Driver)

There are two ways to create a trip, used by two different schedule routing modes:

### Fixed-routing schedules — `POST /api/startTrip`

- Used for schedules with `routingMode !== "dynamic"` — one schedule always maps to exactly one trip per service date (the endpoint upserts).
- Admin or driver selects a schedule; trip is created/updated with `status: "started"` immediately, `bookingIds: []`. Bookings are never *attached* here, but **every `"pending"` booking for that schedule+serviceDate is bulk-confirmed to `"confirmed"`** in the same transaction (see *Booking Status Lifecycle*) — this trip goes live as soon as it's created, so its riders' tickets go live with it.

### Dynamic-routing schedules — route simulator → `POST /api/trips/generate`

- The route simulator (`route-simulator-client.tsx`) previews how many passengers will board at each stop and where a bus would have to short-circuit straight to the destination once full (nearest-neighbor + 2-opt + Dijkstra over `lib/route-heuristic.ts`). Demand for this preview includes both `"pending"` and `"confirmed"` bookings (`DEMAND_BOOKING_STATUSES`) since nothing can be `"confirmed"` yet at planning time.
- Admin clicks "Generate real trip(s)" → `POST /api/trips/generate` creates one trip per bus needed to cover demand. Each trip is created with:
  - `status: "assigned"` (not started — the driver hasn't begun yet, so bookings stay `"pending"` and are **not** bulk-confirmed at this step)
  - `routeStops` populated with the capacity-sweep plan (stop order + `estimatedPassengers`)
  - `bookingIds: []` and **no booking documents are touched** — the plan is just an estimate; real boarding only happens via QR scan (see below)
- Bookings on that schedule+date are only bulk-confirmed once the driver actually starts this trip via `POST /api/updateTripStatus` (`status: "started"`) — see *Booking Status Lifecycle*.
- A bus already on an active trip (`assigned`/`started`/`in_progress`/`waiting`) for the same schedule+date is excluded from the pool, so it can't be double-booked. It becomes available again once that trip is `completed` or `cancelled`.
- The admin trip detail page (`components/trip-detail.tsx`) renders a QR code encoding `trip.busId` — this is what passengers scan to check in, and what should be displayed/printed on the physical bus.

### Driver Trip Lifecycle — mirrors the admin Trip Simulator

The driver app's flow should be the on-device equivalent of the admin web's **Trip Simulator** (`components/trip-simulator-client.tsx`) — same backend endpoints, same lifecycle, same capacity/fastest-route behavior, just driven by the actual driver instead of an admin clicking through it for testing.

**1. Start trip**

Driver app calls `POST /api/updateTripStatus` with `{ tripId, status: "started" }`, which also starts GPS streaming (`LocationService.startTracking()` — see *Location streaming* below). This is the point at which boarding becomes possible — scanning the bus's QR before the driver starts is rejected ("No active trip found for this bus").

**2. Route screen — `POST /api/trips/[id]/arrive-stop`**

Tapping an active trip card opens `DriverTripDetailView`, which lists `trip.routeStops` in order with the current stop (`trip.progress.currentStopIndex`) highlighted. A "Tiba di sini" button calls `POST /api/trips/[id]/arrive-stop` with `{ stopId }`, which advances `progress.currentStopIndex`/`currentStopId`/`nextStopId` for display purposes only — it does not gate or affect boarding, which stays entirely scan-driven.

**3. Boarding — two confirm methods, same as the admin simulator**

At each stop, a booking can be attached to the trip through either path — both call the shared `boardBookingOnTrip()` helper, so they're equivalent (same capacity counting, same `progress` recompute, same Dijkstra-on-full trigger):

- **Passenger self-scan (live today):** the rider scans the bus's QR (`busId`) from the user app's scan screen → `POST /api/checkIn`. This is the only boarding method currently wired up end-to-end in mobile.
- **Driver scans passenger ticket:** `POST /api/trips/[id]/check-in` lets the driver scan a passenger's booking QR/barcode as a fallback when the passenger can't scan the bus (no signal, broken phone, etc.). Mobile's `DriverScanController` (`lib/app/modules/driver/scan/`) mirrors the passenger `ScanController` 1:1 — same `mobile_scanner` flow, calling `DriverCheckInProvider` instead of `ScanProvider`. Reachable from the QR icon in `DriverTripDetailView`'s app bar.

**4. Capacity-triggered fastest route**

The first time `boardedCount` reaches `busCapacity`, the server computes a real Dijkstra shortest path from the current stop straight to the trip's final destination and stores it as `progress.directRoutePath` / `directRouteDistanceKm`. `DriverTripDetailView` surfaces this the same way the Trip Simulator does: when `progress.directToDestination` is true, it shows a red banner ("Bus penuh — menuju langsung ke `<destination>`...") with a single "Tiba di tujuan" button that calls `arrive-stop` directly with the final stop's id (the endpoint looks up by `stopId`, not sequential order, so this jumps straight there) — and hides the per-stop "Tiba di sini" buttons for the skipped stops in between.

**5. Finish trip**

Driver taps "Selesai" → `LocationService.stopTracking()` → `POST /api/updateTripStatus` with `{ tripId, status: "completed" }` → `DriverHomeController._completePassengers()` marks every boarded booking on that trip as `"completed"` (a direct Firestore batch write from the mobile app — see *Key Implementation Notes*).

### User is notified

`BookingDetailController` opens a Firestore stream on `bookings/{id}`. Once the user boards (see Check-in Flow below) `tripId` gets set on the booking, the stream fires, and the UI reflects the updated status with the live map.

### Location streaming — "last bus position"

`LocationService` treats `trip.driverLatitude` / `trip.driverLongitude` as the single source of truth for "where the bus currently is" — this is what `BookingDetailController._syncTripStream()` reads to animate the live map for waiting passengers. It is a **direct Firestore write** straight to `trips/{tripId}` (not routed through the Next.js API) — see *Key Implementation Notes*.

Update cadence — whichever fires first resets both:

- **Time-based:** send an update if **5 seconds** have elapsed since the last sent position, even if the device hasn't moved (so a bus stuck in traffic still shows as "live", not stale).
- **Distance-based:** send an update immediately if the device has moved **≥ 5 meters** from the last *sent* position, even if less than 5 seconds have passed (so a fast-moving bus doesn't appear to teleport between sparse 5-second samples).

Implemented as a combined timer + distance check in `LocationService`: `Geolocator.getPositionStream` runs with `distanceFilter: 0` (every raw OS sample reaches `_onPosition()`), which sends immediately once movement since the last *sent* position reaches 5m; a parallel `Timer.periodic(Duration(seconds: 5))` heartbeat sends the latest known position whenever 5s have passed without a send — covering the stationary-bus case the old pure-distance filter missed.

---

## Check-in Flow (QR Scan)

The QR code a passenger scans is the **bus's own QR code** (just `busId`, displayed on the admin trip detail page) — not a per-trip or per-booking code. A booking only gets attached to a trip at this moment; nothing is pre-assigned at trip generation.

1. User's bus arrives at their stop (trip must already be `started`/`in_progress`/`waiting` — the driver has begun the trip).
2. User opens the scan screen, scans the QR on the bus.
3. Mobile calls `POST /api/checkIn` with `{ bookingId, scannedValue }` (the scanned value is the bus's id).
4. Server (`lib/trip-boarding.ts` → `boardBookingOnTrip`, shared by every boarding path):
   - Finds the trip whose `busId` matches the scan and whose `status` is active.
   - Validates the booking belongs to that trip's `scheduleId`/`serviceDate`, is `confirmed`, and not already boarded.
   - Sets `boardedAt`, `boardedTripId`, `boardedBy`, `tripId` on the booking; appends to `trip.boardedBookingIds`/`bookingIds`, bumps `boardedCount`, and recomputes `trip.progress`.
   - The **first time** `boardedCount` reaches `busCapacity`, it runs a real Dijkstra shortest path (`findFastestPath`) from the current stop to the trip's final destination and stores it as `progress.directRoutePath`/`directRouteDistanceKm`, so the driver UI can render the actual shortcut rather than just a boolean flag.
5. Booking stream fires → UI updates.

`POST /api/trips/[id]/check-in` is the driver-side variant (driver scans a passenger's booking ticket instead of the passenger scanning the bus) and `POST /api/trips/[id]/assign-bookings` is an admin manual fallback (e.g. broken scanner) — both go through the same `boardBookingOnTrip` helper, so they behave identically to a QR scan (capacity counts, Dijkstra trigger included).

---

## Trip Completion

Either path sets booking `status: "completed"`:

- **Driver finishes trip** — driver app calls `POST /api/updateTripStatus` with `status: "completed"` (server-side this only flips the trip's own status), then `DriverHomeController._completePassengers()` queries `bookings` where `tripId == trip.id` and batch-updates every booking with a `boardedAt` to `status: "completed"` — a **direct Firestore write from the mobile app**, not server-side.
- **User self-confirms** — `BookingDetailController.confirmComplete()` calls `firestore.collection('bookings').doc(id).update({ status: 'completed' })` directly, allowed by security rules since the user owns the booking.

---

## API Reference

### Mobile-facing

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/user/bookings` | User Bearer token | Create booking for the authenticated user (`status: "pending"`) |

### Admin-facing

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/bookings` | Admin session | List bookings with filters (scheduleId, serviceDate, status) |
| POST | `/api/bookings` | Admin session | Create booking on behalf of any user (`status: "pending"`) |
| GET | `/api/bookings/[id]` | Admin session | Get single booking |
| PATCH | `/api/bookings/[id]` | Admin session | Update booking (status, note, etc.) |
| POST | `/api/startTrip` | Admin or driver session | Start/upsert a trip for a fixed-routing schedule. Bulk-confirms every `"pending"` booking on that schedule+serviceDate to `"confirmed"` in the same transaction |
| POST | `/api/trips/generate` | Admin session | Generate dynamic-routing trips from the route simulator plan (`status: "assigned"`, no pre-assigned bookings, no bulk-confirm yet) |
| POST | `/api/updateTripStatus` | Driver or Admin session | Update trip status. When `status: "started"`, bulk-confirms every `"pending"` booking on that trip's schedule+serviceDate. Optional `location` is written to a `currentLocation` subcollection that mobile doesn't read — the live map instead reads `driverLatitude`/`driverLongitude`, set by mobile's direct Firestore write (see *Location streaming*) |
| POST | `/api/checkIn` | User Bearer token | Board a booking by scanning the bus's QR (`busId`) |
| POST | `/api/trips/[id]/assign-bookings` | Admin session | Manual boarding fallback — same effect as a QR scan |
| POST | `/api/trips/[id]/check-in` | Driver or Admin session | Driver scans a passenger's booking ticket — no driver-app UI yet, exercised today only by the admin Trip Simulator |
| POST | `/api/trips/[id]/arrive-stop` | Driver or Admin session | Advance `progress.currentStopIndex` for the driver route screen (display only) |
| POST | `/api/trips/fromBooking` | Admin session | Create trip derived from a single `"pending"` or `"confirmed"` booking (`status: "started"` immediately — confirms the booking if it was still `"pending"`) |

---

## Key Implementation Notes

### Direct Firestore writes from mobile (three exceptions)

Booking *creation* always goes through the API. Three call sites write directly to Firestore instead, each scoped to documents the calling user/driver already owns:

1. **User self-completes a booking** — `BookingDetailController.confirmComplete()` updates `bookings/{id}.status` to `"completed"`.
2. **Driver location ping** — `LocationService._onPosition()` updates `trips/{tripId}.driverLatitude`/`driverLongitude` on every tracked position (see *Location streaming*). This is the bus's "last known position" the user app's live map reads.
3. **Driver completes boarded passengers** — `DriverHomeController._completePassengers()` batch-updates every boarded booking on a finished trip to `status: "completed"`.

Everything else — booking creation, trip status transitions, stop arrivals, boarding/check-in — goes through the Next.js API.

### Booking ID generation

`generateDatedSequentialId("bookings", "BKG", serviceDate)` in `src/lib/id-generators.ts` scans the entire `bookings` collection, finds the highest `NNN` counter for the given date code, and returns `BKG-YYMMDD-{NNN+1}`. This runs **outside** the Firestore transaction to avoid non-transactional reads inside the `runTransaction` callback, which conflicts with the Admin SDK's transaction state machine and causes race conditions.

### Booking window

`bookingCloseHour` (`"HH:MM"`) on the schedule defines the daily cutoff. The server combines it with `serviceDate` via `combineDateAndHourIso(serviceDate, bookingCloseHour)` from `src/lib/bookingHelpers.ts` and rejects any request past that time.

### Schedule direction matching

`routeDirection` values in Firestore use Indonesian words (`"pergi"`, `"pulang"`, `"berangkat"`, `"kembali"`). The mobile's `UserScheduleController._matchesDirection()` maps these to the two enum values `ScheduleDirection.toSchool` / `ScheduleDirection.fromSchool`.

### Boarding is centralized in one helper

`lib/trip-boarding.ts` → `boardBookingOnTrip()` is the single place that attaches a booking to a trip (used by `/api/checkIn`, `/api/trips/[id]/check-in`, and `/api/trips/[id]/assign-bookings`). This guarantees a manual admin assignment behaves exactly like a QR scan — same capacity counting, same `progress` recompute, same Dijkstra-on-full trigger — instead of three slightly different implementations drifting apart.

### Trip planning vs. trip reality

`trip.routeStops`/`estimatedPassengerCount` are a **plan** produced at generation time (capacity sweep over confirmed bookings at that moment). `trip.bookingIds`/`boardedBookingIds`/`boardedCount` are **reality**, populated only as riders actually scan in. The two can diverge (no-shows, walk-ons within capacity) — UI and reporting should be clear about which one they're showing.
