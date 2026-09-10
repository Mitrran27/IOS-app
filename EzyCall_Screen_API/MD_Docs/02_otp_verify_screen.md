# EzyCall AI - OTP Verification Screen

**UI Reference:** `otp_verify.jpeg`

## Purpose

Verify the OTP received by the user and create the authenticated application session.

## Screen Components

- EzyCall AI logo
- `Login to your account` heading
- `Code sent to` phone number
- `Change` option
- OTP input fields
- `Verify and Sign In` button
- Status message such as `Code sent.`

## Flow

1. Display the phone number entered on the Login screen.
2. User enters the OTP received through WhatsApp.
3. User presses **Verify and Sign In**.
4. Get the current Firebase/FCM mobile token.
5. Call the OTP Verify API with phone number, OTP and mobile token.
6. If successful:
   - Store the returned bearer token securely.
   - Store required user details.
   - Navigate to the **Alarms Screen**.
7. Use the bearer token for all protected APIs.
8. If **Change** is pressed, return to the Login screen.

## API

```http
POST {BASE_URL}/otp_verify
Content-Type: application/json
```

### Request

```json
{
  "phone_number": "60183810223",
  "otp": "531513",
  "mobile_token": "firebase-token1"
}
```

### Important Response

```json
{
  "success": true,
  "message": "Login successful",
  "token": "<JWT_TOKEN>",
  "expires_at": "2026-11-16T01:29:05.000Z",
  "expires_in_seconds": 7776000,
  "user": {
    "id": "c8b9c44d-fe10-4d6c-84db-2f4b0371219f",
    "email": "kr.manikandan22@gmail.com",
    "full_name": "Mani",
    "phone": "60183810223",
    "hospital_uuid": "7348eb7c-49dc-4a2e-9207-c186b0ef5610",
    "ward_uuid": null,
    "notify_apps": true,
    "shift_time": "08:00-16:00",
    "push_notify_ezycall": false,
    "push_notify_advance": true,
    "flag_whatsapp_registration": 0,
    "push_notify_asset": false
  }
}
```

## Store After Successful Login

- `token`
- `expires_at`
- `user.id`
- `user.full_name`
- `user.phone`
- `user.hospital_uuid`
- `user.ward_uuid`
- Required notification flags

## Authentication

For all protected APIs:

```http
Authorization: Bearer <token>
```

## Error Handling

- OTP is mandatory.
- Disable Verify button during API processing.
- Invalid/expired OTP: display API error and remain on screen.
- Do not navigate to Alarms until verification succeeds.
