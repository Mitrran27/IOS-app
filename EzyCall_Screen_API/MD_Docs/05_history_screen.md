# EzyCall AI - History Screen

**UI Reference:** `history.jpeg`

## Purpose

Display acknowledged and closed alarm history for the logged-in user.

## API

```http
GET {BASE_URL}/get_history_notifications
Authorization: Bearer <token>
```

## Flow

1. User selects the **History** tab.
2. Call `get_history_notifications`.
3. Display returned records as history cards.
4. Allow client-side searching.
5. User taps a history card to open **History Detail**.

## Search

Filter the loaded history records by:

- `hospital_name`
- `ward_name`
- `bed_name`
- `event_name`

Search behavior:

- Case-insensitive
- Partial match
- Filter while typing
- Empty search restores all history records

## Status Mapping

```text
event_status = 1 -> Acknowledged
event_status = 2 -> Closed
```

## Card Mapping

| UI | API Field |
|---|---|
| Event name/title | `event_name` |
| Status badge | `event_status` |
| Hospital | `hospital_name` |
| Ward | `ward_name` |
| Bed | `bed_name` |
| Occurred time | `occurred_at` |
| Event record ID | `id` |

## Example History Record

```json
{
  "id": "767e9c07-6cf7-4b75-a7c7-6a79d7cb7122",
  "occurred_at": "2026-08-18T09:10:14.000Z",
  "ended_at": "2026-08-18T09:10:51.000Z",
  "event_status": 2,
  "event_type": 2,
  "ack_by": null,
  "ack_at": null,
  "notify_sent": true,
  "hospital_name": "Pantai Hospital Laguna",
  "ward_name": "WARD 1",
  "bed_name": "123A",
  "bed_code": "123A",
  "event_uuid": "4ce152d7-a903-4c03-8a6c-b4aaed6be46c",
  "event_name": "123A-HK",
  "color": "#2563EB",
  "priority": 6,
  "master_event_type": 2
}
```

## Open History Detail

When the user taps a card:

1. Keep the complete selected history object.
2. Open History Detail.
3. Pass the complete object to the detail screen/modal.

No separate history-detail API is supplied.
