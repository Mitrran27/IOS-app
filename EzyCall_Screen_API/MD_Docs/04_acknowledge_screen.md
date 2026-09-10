# EzyCall AI - Acknowledge Alarm Screen

**UI Reference:** No final screen design is currently provided.

## Purpose

Allow the logged-in user to assign a pending alarm to a nurse and acknowledge the alarm.

## Open Screen

This modal/window is opened when the user presses **Acknowledge** from a pending alarm card.

## Required UI Components

- Event name
- Hospital name
- Ward name
- Bed name
- `Assigned To` dropdown
- Submit/Acknowledge button
- Cancel/Close button

## Nurse List Source

Do **not** call a separate nurse API.

Use the `nurse_list` already returned inside the selected record from:

```http
GET /get_pending_notifications
```

Example:

```json
"nurse_list": [
  {
    "name": "Mani Nurse",
    "email": "kr.manikandan22+1@gmail.com",
    "user_id": "fa83c7e2-68b0-4f09-856d-e4ccbec56717",
    "shift_time": "08:00-16:00",
    "phone_number": "917550317806"
  }
]
```

## Assigned To Mapping

Dropdown display:

```text
nurse_list[].name
```

Value used for API:

```text
nurse_list[].user_id
```

Submit this value as:

```text
nurse_uuid
```

## Acknowledge API

```http
POST {BASE_URL}/acknowledge
Authorization: Bearer <token>
Content-Type: application/json
```

### Request

```json
{
  "event_log_id": "9bb2584b-0f81-445b-a529-9d0d07648f3c",
  "nurse_uuid": "3c3878e1-6e4b-4666-ab1e-c273baa05b04"
}
```

## Flow

1. User presses Acknowledge on an alarm.
2. Open this modal.
3. Show selected event information.
4. Populate Assigned To from `nurse_list`.
5. User selects a nurse.
6. User presses Submit/Acknowledge.
7. Call `/acknowledge`.
8. If successful:
   - Show success message.
   - Close modal.
   - Refresh pending alarms.
   - Recalculate Top 4 alarm counters.

## Validation

- Nurse selection is mandatory.
- `event_log_id` must come from the selected pending alarm's `id`.
- Disable submit while the request is processing.
- If `nurse_list` is empty, disable submission and indicate that no nurse is available.
