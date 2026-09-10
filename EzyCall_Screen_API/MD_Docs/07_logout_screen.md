# EzyCall AI - Profile / Logout Screen

**UI Reference:** `logout.jpeg`

## Purpose

Display the logged-in user's basic information and allow the user to log out.

## Open Profile Menu

When the user presses the profile/user icon, open the profile dropdown.

## Display Fields

Use user information returned by the OTP Verify API.

| UI | API Field |
|---|---|
| Display name | `user.full_name` |
| Phone number | `user.phone` |

Example:

```json
"user": {
  "full_name": "Mani",
  "phone": "60183810223"
}
```

## Logout API

```http
POST {BASE_URL}/logout
Authorization: Bearer <token>
```

No request body is defined in the supplied Postman collection.

## Logout Flow

1. User opens the profile menu.
2. Display name and phone number.
3. User presses **Logout**.
4. Call `/logout`.
5. Clear the locally stored bearer token.
6. Clear locally cached user/session information.
7. Redirect to the **Login Screen**.

## Session Cleanup

Clear at minimum:

- Bearer token
- Token expiry
- Cached user information
- Pending/history cached data where applicable

The supplied Postman test accepts HTTP `200` or `401` as logout completion and clears its stored token.
