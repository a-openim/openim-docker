# OpenIM Default Credentials

## Admin Account

### Admin Login (Backend API)
- **User ID**: `imAdmin`
- **Secret**: `openIM123`
- **Platform ID**: `2`

### Get Admin Token
```bash
curl -X POST -H "Content-Type: application/json" -H "operationID: imAdmin" -d '{
  "secret": "openIM123",
  "platformID": 2,
  "userID": "imAdmin"
}' http://127.0.0.1:10002/auth/get_admin_token
```

## Test Accounts (H5 Frontend)

### Test User 1
- **Nickname**: `test12312`
- **Phone Number**: `+86 12345678190`
- **Password**: `test123456`
- **Area Code**: `+86`
- **Platform**: `3` (Web/H5)

### Test User 2
- **Nickname**: `test22312`
- **Phone Number**: `+86 12345678290`
- **Password**: `test123456`
- **Area Code**: `+86`
- **Platform**: `3` (Web/H5)

## Register New Test User

```bash
curl -X POST -H "Content-Type: application/json" -H "operationID: imAdmin" -d '{
  "verifyCode": "666666",
  "platform": 3,
  "autoLogin": true,
  "user":{
    "nickname": "YourNickname",
    "areaCode":"+86",
    "phoneNumber": "YourPhoneNumber",
    "password":"YourPassword"
  }
}' http://127.0.0.1:10008/account/register
```

## Login with Test Account

```bash
curl -X POST -H "Content-Type: application/json" -H "operationID: imAdmin" -d '{
  "platform": 3,
  "areaCode":"+86",
  "phoneNumber": "12345678190",
  "password":"test123456"
}' http://localhost:10008/account/login
```

## Access URLs

### H5 Frontend (Web)
- **URL**: http://h5-openim.36x9.com
- **Login Method**: Phone number + password
- **Test Account**: +86 12345678190 / test123456

### Admin Frontend
- **URL**: http://admin-openim.36x9.com
- **Login Method**: Admin ID + secret
- **Admin Account**: imAdmin / openIM123

## API Endpoints

### OpenIM Server API
- **Base URL**: http://10.88.88.13:10002
- **Admin Token Endpoint**: `/auth/get_admin_token`

### OpenIM Chat API
- **Base URL**: http://10.88.88.13:10008
- **Register Endpoint**: `/account/register`
- **Login Endpoint**: `/account/login`

## Notes

1. **Admin Account**: The admin account (`imAdmin`) is used for backend management and API operations. You need to obtain an admin token first before performing admin operations.

2. **Test Accounts**: The test accounts are pre-configured for testing purposes. You can register new users using the registration API.

3. **Verification Code**: For registration, the verification code is set to `666666` in the test environment.

4. **Platform IDs**:
   - `2`: Admin platform
   - `3`: Web/H5 platform

5. **Security**: In production, change all default passwords and secrets immediately after deployment.

## Troubleshooting

### Cannot Login to Admin Frontend
- Ensure the admin service is running: `docker ps | grep openim-server`
- Check admin service logs: `docker logs openim-server`
- Verify the admin credentials: `imAdmin` / `openIM123`

### Cannot Login to H5 Frontend
- Ensure the chat service is running: `docker ps | grep openim-chat`
- Check chat service logs: `docker logs openim-chat`
- Verify the test account credentials: `+86 12345678190` / `test123456`

### API Connection Issues
- Check if services are accessible: `curl http://10.88.88.13:10002/auth/get_admin_token`
- Verify network connectivity between Kubernetes Ingress and Docker services
- Check firewall rules on node 10.88.88.13
