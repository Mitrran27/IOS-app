# EzyCall AI - New Alert / Notification Panel

**UI Reference:** `new_alert.jpeg`

## Purpose

Display recent application alerts when the user presses the notification bell.

## Screen Components

The supplied UI shows:

- Notification bell with unread count badge
- `Latest Alerts` heading
- Total alert count
- Alert title/message
- Alert timestamp
- `New` badge
- `Clear All`
- `View All Alerts`

## Open Panel

1. User presses the notification bell.
2. Open the Latest Alerts dropdown/panel.
3. Display recent alerts.
4. Show unread/total count as required by the UI.

## API Status

A dedicated notification-inbox API is **not included** in the supplied API files.

The supplied APIs provide:

```text
notify_sent
```

inside pending/history alarm records. This indicates whether push notification sending occurred, but the supplied documentation does **not** define it as the data source for the notification-bell inbox.

## Pending API Field

Example:

```json
{
  "notify_sent": true
}
```

This field is used on the Alarm screen as:

```text
true  -> Notified
false -> Not Notified
```

It should not automatically be treated as the notification-panel read/unread state unless the backend business rule confirms this.

## Items Requiring Backend/API Definition

The following are not defined in the supplied APIs:

- Latest Alerts API
- Unread alert count
- Read/unread status
- Mark alert as read
- `Clear All` API/action
- `View All Alerts` data source
- Alert message/title source
- Alert inbox retention period

## Implementation Status

The UI can be implemented according to `new_alert.jpeg`, but full functionality requires the notification-panel API/business rules above.
