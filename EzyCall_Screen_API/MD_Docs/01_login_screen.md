# EzyCall AI - Login Screen

**UI Reference:** `login.jpeg`

## Purpose

Allow the user to enter a registered phone number and request a login OTP.

## Screen Components

- EzyCall AI logo
- `Login to your account` heading
- Phone Number text field
- OTP information message
- `Send OTP` button

## Flow

1. User enters the phone number in the **Phone Number** field.
2. User presses **Send OTP**.
3. Call the EzyCall Login API.
4. The Login API returns an OTP.
5. Send the returned OTP to the user's WhatsApp number using the CIOT WhatsApp API.
6. If successful, navigate to the **OTP Verification Screen**.
7. Retain the entered phone number for OTP verification.

## Login API

```http
POST {BASE_URL}/login
Content-Type: application/json
```

### Request

```json
{
  "phone_number": "60183810223"
}
```

### Response

```json
{
  "success": true,
  "message": "OTP sent successfully",
  "otp": "531513"
}
```

## WhatsApp OTP API

```http
POST https://notify.ciot.my:5000/
Content-Type: application/json
```

### Request

```json
{
  "country_code": "+60",
  "footer": "*Reported by Ezycall AI System*",
  "msg": "Your OTP is: 531513\nThis OTP is valid for 5 minutes.\nDo not share this OTP with anyone.",
  "msg_id": "1254",
  "notify_type": "whatsapp",
  "phone_num": "+60183810223",
  "title": "EzyCall Login OTP"
}
```

## Validation

- Phone number is mandatory.
- Do not call the API when the field is empty.
- Disable the Send OTP button while the request is processing.
- If `/login` fails, show the API error and remain on this screen.
- If WhatsApp OTP sending fails, show an error/retry message.
