# CareAlert (placeholder name) — iOS Nurse-Call Alert App

## What this app is
Native iOS app for hospital nurse-call alerts. A patient event (call button, wet alarm,
housekeeping request, etc.) fires on the backend and must reach on-duty nurses' phones
instantly. Nurses acknowledge/assign alerts to close them out.

**Push notification reliability is the single most important non-functional requirement.**
A missed push is a missed nurse call — not a cosmetic bug. Every decision around push
handling, polling fallback, and error states should be made with that in mind.

## Tech constraints
- Swift, SwiftUI, iOS 16+ minimum deployment target
- Bundle identifier: `com.careapp.carealert` (placeholder — will be renamed)
- App display name "CareAlert" is a placeholder — isolate it to Info.plist's Display Name
  only, nowhere else in code, so it can be renamed with a one-line change
- Standard SwiftUI App lifecycle (`@main App`, not UIKit AppDelegate-based) — but note
  Firebase push setup requires a `UIApplicationDelegateAdaptor` bridge; use that, not a
  full UIKit rewrite
- Networking: URLSession + async/await, single Config file for base URL, shared APIClient
  that auto-attaches `Authorization: Bearer <token>`, typed APIError enum
- Secure token storage: Keychain wrapper exposed via SessionManager (ObservableObject)
  with saveSession(), getToken(), clearSession(), isLoggedIn (published)

## API contract (verified against actual backend samples — do not guess field names)

Base URL: `https://dev-ezycall-dms.ciot.my/notify`

All authenticated endpoints use `Authorization: Bearer <token>` header.

### POST /login
Request: `{ "phone_number": "60183810223" }` (no country-code symbol, digits only)
Response: `{ "success": true, "message": "...", "otp": "531513" }`

**Important:** the backend returns the OTP directly in this response. The app itself is
responsible for delivering it to the user via WhatsApp — the backend does not send it.
Immediately after a successful /login call, the app must POST to the WhatsApp relay:

```
POST https://notify.ciot.my:5000/
{
  "country_code": "+60",
  "footer": "*Reported by Ezycall AI System*",
  "msg": "Your OTP is: <otp>\nThis OTP is valid for 5 minutes.\nDo not share this OTP with anyone.",
  "msg_id": "<any unique id>",
  "notify_type": "whatsapp",
  "phone_num": "+<phone_number>",
  "title": "EzyCall Login OTP"
}
```
Do not display the OTP anywhere in the app UI — it should only ever be sent to WhatsApp.

### POST /otp_verify
Request: `{ "phone_number": "60183810223", "otp": "531513", "mobile_token": "<FCM token>" }`

**`mobile_token` is a Firebase Cloud Messaging token, not a raw APNs device token.**
This app must integrate the Firebase SDK (GoogleService-Info.plist + FirebaseMessaging)
to obtain this value. Do not build Step 4 around bare `UIApplication.registerForRemoteNotifications`
device-token strings — get the FCM token via `Messaging.messaging().token`.

Response includes `token` (JWT, save via SessionManager), `expires_at`, `expires_in_seconds`,
and a `user` object (id, email, full_name, phone, hospital_uuid, ward_uuid, notify flags,
shift_time).

### POST /update_mobile_token (Bearer auth)
Re-registers a refreshed FCM token against the logged-in session. Call this whenever
Firebase's `messaging(_:didReceiveRegistrationToken:)` fires with a new token after the
user is already logged in — not just at login time. This matters for push reliability:
a stale token after an app reinstall/OS update means silent missed pushes.

### GET /validate_token (Bearer auth)
Check session validity — use on cold app launch before deciding whether to route into
AlarmsView or LoginView.

### POST /renew_token (Bearer auth)
Refresh the JWT. Prefer this over hard-logout when a request nears/hits 401, if the
token is still within a renewable window; fall back to full logout+redirect if renewal
also fails.

### GET /get_pending_notifications (Bearer auth)
Response: `{ "success": true, "count": N, "data": [ <event> ] }`

Event shape:
```json
{
  "id": "uuid",                    // use THIS as event_log_id when acknowledging
  "occurred_at": "ISO8601",
  "ended_at": null,
  "event_status": 0,                // integer code
  "event_type": 2,                  // integer code
  "ack_by": null,
  "ack_at": null,
  "notify_sent": true,              // whether push was sent for this event — display
                                     // on the alarm card as "Notified"/"Not Notified";
                                     // do NOT treat this as notification-inbox read state
  "force_close": 0,
  "hospital_name": "Pantai Hospital Laguna",
  "ward_name": "WARD 1",
  "bed_name": "120A",
  "bed_code": "120A",
  "event_uuid": "uuid",
  "event_name": "120A-WTR",
  "color": "#2563EB",               // use directly for status badge color
  "priority": 6,
  "master_event_type": 2,
  "nurse_list": [
    { "name": "Mani Nurse", "email": "...", "user_id": "uuid", "shift_time": "08:00-16:00", "phone_number": "..." }
  ]
}
```

### GET /get_history_notifications (Bearer auth)
Same shape as pending, `event_status`/`ended_at` populated for closed events.

### POST /acknowledge (Bearer auth)
Request: `{ "event_log_id": "<the pending record's id field>", "nurse_uuid": "<nurse_list[].user_id>" }`

**Do not call a separate nurse-list API.** The Assigned-To dropdown is populated from the
`nurse_list` array already present on the selected pending event: display `nurse_list[].name`,
submit `nurse_list[].user_id` as `nurse_uuid`. If `nurse_list` is empty, disable submission
and show that no nurse is available.

On success: remove/update the item in the Alarms list, dismiss the modal, refresh pending list.

### POST /logout (Bearer auth)
Invalidates session. Clear SessionManager, navigate to LoginView.

## Screen-by-screen notes
- **Login**: phone number field only, basic format validation, calls /login then the
  WhatsApp relay, navigates to OtpVerifyView passing the phone number.
- **OTP Verify**: 6-digit input (matches sample `"531513"`), calls /otp_verify with
  phone + otp + FCM mobile_token, allows resend (re-runs /login + WhatsApp relay flow).
- **Alarms**: pending list, search across hospital/ward/bed/event name, status badge
  from `color`, Acknowledge button per card opens the acknowledge sheet.
- **Acknowledge modal**: shows event_name/hospital_name/ward_name/bed_name, Assigned-To
  dropdown from that event's `nurse_list`, submit calls /acknowledge.
- **History**: same card layout/fields as Alarms, closed-status styling, same search.
- **History Detail**: no extra API call — pass the already-fetched event object through nav.
- **Profile/Logout**: show user object fields, logout button calls /logout + clears session.
- **New-alert / notification bell panel**: NO backend API exists for this. Confirmed by
  the source docs — it's intentionally local-only. Store received pushes on-device
  (SwiftData or a simple local store), with Clear All / View All actions and an unread
  badge count. Do not wire this to `notify_sent` — that field means something different
  (whether the backend attempted to send push for that event, shown on the alarm card).

## Reliability requirements (apply throughout, not just Step 11)
- On app foreground, always refresh /get_pending_notifications regardless of push state —
  push is the fast path, not the only path.
- Background app refresh as secondary fallback poll where iOS execution limits allow.
- Global 401 handling: try /renew_token once; if that also fails, clear session and
  redirect to Login.
- Retry/backoff on transient network failures.
- Loading + disabled states on every button that triggers a network call.
- Re-register mobile_token via /update_mobile_token whenever Firebase issues a new token
  post-login, not just at initial login.

## Build order
Work through steps in this exact order. Fully complete and confirm each step builds
before moving to the next. Summarize what was built at the end of each step, then proceed
automatically unless something is genuinely ambiguous — in that case, stop and ask rather
than guessing.

1. Project scaffold (no UI/API calls yet — just structure, Config, APIClient, Keychain/SessionManager)
2. Login screen
3. OTP verify screen (placeholder push token is fine here; wire real FCM in step 4)
4. Push notification setup — real Firebase/APNs integration, foreground + background/terminated
   tap-to-open routing into AlarmsView. Most safety-critical step — must be tested on a
   real device, not just simulator.
5. Alarms screen
6. Acknowledge modal
7. History screen
8. History detail screen
9. Profile / logout
10. New-alert / notification inbox panel (local-only, see notes above)
11. Reliability: foreground polling fallback, background refresh, global 401 handling,
    retry/backoff, loading/disabled states, input validation

## Reference assets
- `/EzyCall_Screen_API/screens/*.jpeg` — UI reference screenshots per screen
- `/EzyCall_Screen_API/MD_Docs/*.md` — per-screen written specs (more detail than this file)
- `/EzyCall_Screen_API/api/*.json` — raw request/response samples
- `/EzyCall_Screen_API/Ezycall-Notification API.postman_collection.json` — full endpoint list
