# EzyCall AI - History Detail Screen

**UI Reference:** `history_detail.jpeg`

## Purpose

Display complete information for a selected acknowledged or closed history event.

## Data Source

No separate History Detail API is supplied.

Use the complete selected record already returned by:

```http
GET /get_history_notifications
```

## Flow

1. User selects an event from History.
2. Open the History Detail modal/screen.
3. Display the selected record.
4. User presses Close/X to return to History.

## Field Mapping

| UI Label | API Field |
|---|---|
| Event title | `event_name` |
| Hospital | `hospital_name` |
| Ward | `ward_name` |
| Bed | `bed_name` |
| Occurred | `occurred_at` |
| Ended | `ended_at` |
| Status | `event_status` |
| Ack By | `ack_by` |
| Ack At | `ack_at` |

## Status Mapping

```text
event_status = 1 -> Acknowledged
event_status = 2 -> Closed
```

## Null Values

When a value is `null`, display:

```text
-
```

Example:

```text
ACK BY
-

ACK AT
-
```

## Additional Available Fields

The History API also provides:

- `id`
- `event_type`
- `notify_sent`
- `force_close`
- `bed_code`
- `event_uuid`
- `color`
- `priority`
- `master_event_type`
- `nurse_list`

These values can be displayed if required by the final UI.
