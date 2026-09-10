# EzyCall AI - Alarm Screen

**UI Reference:** `alarms.jpeg`

## Purpose

Display all pending alarms available to the logged-in user and allow alarms to be searched and acknowledged.

## API

```http
GET {BASE_URL}/get_pending_notifications
Authorization: Bearer <token>
```

## Flow

1. Call `get_pending_notifications` when the Alarms screen opens.
2. Display the returned pending alarm records.
3. Calculate `event_name` counts.
4. Sort event counts in descending order.
5. Display only the **Top 4 event names** above the search box.
6. Allow client-side searching.
7. User can press **Acknowledge** on an alarm to open the Acknowledge modal.

## Top Event Count Logic

Group records using:

```text
event_name
```

Example:

```text
120A-WTR = 3
127A-HK  = 2
119D-AWS = 1
123A-HK  = 1
```

Sort by count descending and show only the first four.

Each top summary card displays:

- Event count
- Event name

## Search

The search field must filter the currently loaded records by:

- `hospital_name`
- `ward_name`
- `bed_name`
- `event_name`

Recommended behavior:

- Case-insensitive
- Partial match
- Filter while typing
- Empty search displays all records

## Alarm Card Mapping

| UI | API Field |
|---|---|
| Event name/title | `event_name` |
| Notification status | `notify_sent` |
| Hospital | `hospital_name` |
| Ward | `ward_name` |
| Bed | `bed_name` |
| Occurred time | `occurred_at` |
| Event log ID | `id` |
| Event color, if required | `color` |

## Notification Status

```text
notify_sent = true  -> Notified
notify_sent = false -> Not Notified
```

## Example Pending Record

```json
{
  "id": "7e3d2b4e-5755-48f9-af96-130def630db7",
  "occurred_at": "2026-08-19T10:15:00.000Z",
  "ended_at": null,
  "event_status": 0,
  "event_type": 2,
  "ack_by": null,
  "ack_at": null,
  "notify_sent": true,
  "hospital_name": "Pantai Hospital Laguna",
  "ward_name": "WARD 1",
  "bed_name": "120A",
  "event_name": "120A-WTR",
  "color": "#2563EB",
  "priority": 6,
  "nurse_list": [
    {
      "name": "Mani Nurse",
      "user_id": "fa83c7e2-68b0-4f09-856d-e4ccbec56717",
      "shift_time": "08:00-16:00",
      "phone_number": "917550317806"
    }
  ]
}
```

## Acknowledge Action

When **Acknowledge** is pressed:

1. Take the selected record's `id`.
2. Open the **Acknowledge Alarm modal**.
3. Pass `id` as `event_log_id`.
4. Use the selected record's `nurse_list` for the Assigned To dropdown.
5. Do not call `/acknowledge` until a nurse is selected and the user submits.

## Refresh

After a successful acknowledgement, call `get_pending_notifications` again so:

- Pending list is refreshed.
- Top 4 counters are recalculated.
- Acknowledged alarm is removed if no longer pending.
