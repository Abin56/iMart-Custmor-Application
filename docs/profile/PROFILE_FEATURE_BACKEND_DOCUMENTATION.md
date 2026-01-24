# Profile Feature - Backend Implementation Guide

> **Purpose:** Complete backend implementation documentation for the Profile feature. This guide enables replication of the same business logic, API integration, and caching strategies in other projects with different UI frameworks.

---

## Table of Contents

1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Repository Pattern](#repository-pattern)
5. [Caching Strategy](#caching-strategy)
6. [State Management](#state-management)
7. [Business Logic & Use Cases](#business-logic--use-cases)
8. [Request/Response Patterns](#requestresponse-patterns)
9. [Error Handling](#error-handling)
10. [Architecture Overview](#architecture-overview)
11. [Replication Guide](#replication-guide)

---

## Overview

The Profile feature implements a **production-ready user profile management system** with:

- ✅ **Cache-First Loading** - Instant UI with cached data
- ✅ **Background Refresh** - Non-blocking updates for fresh data
- ✅ **Offline Support** - Full functionality without internet
- ✅ **HTTP Optimization** - Conditional requests (304 Not Modified)
- ✅ **Error Recovery** - Graceful degradation with stale data
- ✅ **Clean Architecture** - Easily testable and maintainable
- ✅ **Type Safety** - Defensive parsing with clear error messages

**Tech Stack:**
- HTTP Client: Dio
- Local Storage: Hive
- State Management: Riverpod
- Architecture: Clean Architecture with Repository Pattern

---

## API Endpoints

### Base URL
```
http://156.67.104.149:8012/api/auth/v1/
```

### Endpoint Summary

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `profile/` | Fetch current user profile | ✅ |
| PATCH | `profile/` | Update profile information | ✅ |
| POST | `delete-account/` | Delete user account permanently | ✅ |

---

### 1. Fetch Profile

**Endpoint:** `GET /api/auth/v1/profile/`

**Headers:**
```http
X-CSRFToken: <csrf_token>
Cookie: sessionid=<session_id>
If-Modified-Since: Mon, 23 May 2024 22:22:01 GMT  (optional)
```

**Request:**
```http
GET http://156.67.104.149:8012/api/auth/v1/profile/
If-Modified-Since: Mon, 23 May 2024 22:22:01 GMT
```

**Response (200 OK):**
```json
{
  "id": "user-123",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "email": "john@example.com",
  "username": "johndoe",
  "role": "user",
  "profile_image": "https://example.com/avatar.jpg",
  "created_at": "2022-05-23T22:22:01Z",
  "updated_at": "2024-01-17T10:00:00Z"
}
```

**Response Headers:**
```http
Last-Modified: Thu, 17 Jan 2024 10:00:00 GMT
```

**Response (304 Not Modified):**
```http
HTTP/1.1 304 Not Modified
Last-Modified: Mon, 23 May 2024 22:22:01 GMT
```
> No body returned when data hasn't changed since last fetch

**Code Implementation:**
```dart
Future<ProfileFetchResponse> fetchProfile({String? ifModifiedSince}) async {
  final headers = <String, String>{};
  if (ifModifiedSince != null) {
    headers['If-Modified-Since'] = ifModifiedSince;
  }

  final response = await _client.get<Map<String, dynamic>>(
    'api/auth/v1/profile/',
    headers: headers.isEmpty ? null : headers,
  );

  // Handle 304 Not Modified
  if (response.statusCode == 304) {
    return ProfileFetchResponse.notModified();
  }

  return ProfileFetchResponse(
    profile: ProfileDto.fromJson(response.data),
    lastModified: response.headers.value('last-modified'),
  );
}
```

---

### 2. Update Profile

**Endpoint:** `PATCH /api/auth/v1/profile/`

**Headers:**
```http
Content-Type: application/json
X-CSRFToken: <csrf_token>
Cookie: sessionid=<session_id>
```

**Request:**
```http
PATCH http://156.67.104.149:8012/api/auth/v1/profile/
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "email": "john@example.com"
}
```

**Field Validation:**
- `first_name`: Required, non-empty string
- `last_name`: Required, non-empty string
- `phone_number`: Required, valid phone number
- `email`: Optional, valid email format if provided

**Code Implementation:**
```dart
Future<ProfileDto> updateProfile({
  required String fullName,
  required String phoneNumber,
}) async {
  final names = ProfileDto.splitFullName(fullName);

  final data = {
    'first_name': names['firstName'],
    'last_name': names['lastName'],
    'phone_number': phoneNumber,
  };

  final response = await _client.patch<Map<String, dynamic>>(
    'api/auth/v1/profile/',
    data: data,
  );

  return ProfileDto.fromJson(response.data);
}
```

**Response (200 OK):**
```json
{
  "id": "user-123",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "email": "john@example.com",
  "username": "johndoe",
  "role": "user",
  "profile_image": "https://example.com/avatar.jpg",
  "created_at": "2022-05-23T22:22:01Z",
  "updated_at": "2024-01-17T12:30:00Z"
}
```

---

### 3. Delete Account

**Endpoint:** `POST /api/auth/v1/delete-account/`

**Headers:**
```http
X-CSRFToken: <csrf_token>
Cookie: sessionid=<session_id>
```

**Request:**
```http
POST http://156.67.104.149:8012/api/auth/v1/delete-account/
```

**Response (200 OK or 204 No Content):**
```json
{}
```

**Code Implementation:**
```dart
Future<void> deleteAccount() async {
  await _client.post('api/auth/v1/delete-account/');
}
```

**Important Notes:**
- This operation is **irreversible**
- All user data is permanently deleted
- Session is invalidated after deletion
- Client should logout and clear all local data

---

## Data Models

### Architecture Layers

```
API Response (JSON)
    ↓
ProfileDto (Data Transfer Object)
    ↓
Profile (Domain Entity)
    ↓
UI Layer
```

---

### 1. Domain Entity - Profile

**File:** `domain/entities/profile.dart`

**Purpose:** Core business object representing a user profile

```dart
class Profile {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String? location;
  final String? profileImageUrl;

  const Profile({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    this.location,
    this.profileImageUrl,
  });

  // Computed property
  String get displayName => fullName.isEmpty ? mobileNumber : fullName;

  // Copy method for updates
  Profile copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? email,
    String? location,
    String? profileImageUrl,
  }) { ... }
}
```

**Key Features:**
- Immutable (all fields are final)
- Null-safe (optional fields marked with `?`)
- Business logic methods (displayName)
- No JSON serialization (pure domain object)

---

### 2. Data Transfer Object - ProfileDto

**File:** `infrastructure/models/profile_dto.dart`

**Purpose:** Bridge between API responses and domain entities

```dart
class ProfileDto {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? username;
  final String? role;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.username,
    this.role,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Parse from API JSON
  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json.isEmpty) {
      throw const FormatException('Profile data cannot be empty');
    }

    // Flexible ID parsing (handles multiple field names)
    final id = json['id']?.toString() ??
              json['user_id']?.toString() ??
              json['uuid']?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Profile ID is required');
    }

    // Extract and validate required fields
    final firstName = json['first_name']?.toString() ?? '';
    if (firstName.isEmpty) {
      throw const FormatException('First name is required');
    }

    final lastName = json['last_name']?.toString() ?? '';
    if (lastName.isEmpty) {
      throw const FormatException('Last name is required');
    }

    final phoneNumber = json['phone_number']?.toString() ?? '';
    if (phoneNumber.isEmpty) {
      throw const FormatException('Phone number is required');
    }

    // Optional fields with null coalescing
    final email = json['email']?.toString();
    final username = json['username']?.toString();
    final role = json['role']?.toString();

    // Flexible profile image field names
    final profileImage = json['profile_image']?.toString() ??
                        json['avatar']?.toString() ??
                        json['image']?.toString();

    // Parse dates if available
    DateTime? createdAt;
    DateTime? updatedAt;
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at'].toString());
      }
      if (json['updated_at'] != null) {
        updatedAt = DateTime.parse(json['updated_at'].toString());
      }
    } catch (_) {
      // Ignore date parsing errors
    }

    return ProfileDto(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email?.isEmpty ?? true ? null : email,
      username: username,
      role: role,
      profileImageUrl: profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (role != null) 'role': role,
      if (profileImageUrl != null) 'profile_image': profileImageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Convert to domain entity
  Profile toDomain() {
    return Profile(
      id: id,
      fullName: '$firstName $lastName'.trim(),
      mobileNumber: phoneNumber,
      email: email,
      profileImageUrl: profileImageUrl,
    );
  }

  // Helper: Split full name into first/last names
  static Map<String, String> splitFullName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return {'firstName': parts[0], 'lastName': ''};
    }
    return {
      'firstName': parts.first,
      'lastName': parts.skip(1).join(' '),
    };
  }
}
```

**Defensive Parsing Features:**
- ✅ Validates required fields before parsing
- ✅ Throws `FormatException` with descriptive messages
- ✅ Handles multiple field name variants (id, user_id, uuid)
- ✅ Gracefully handles missing optional fields
- ✅ Safe date parsing (ignores errors)
- ✅ Flexible image URL field mapping

---

### 3. Cache DTO - ProfileCacheDto

**File:** `infrastructure/data_sources/local/profile_cache_dto.dart`

**Purpose:** Store cached profile with metadata

```dart
class ProfileCacheDto {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? location;
  final String? profileImageUrl;
  final DateTime cachedAt;  // Cache timestamp

  const ProfileCacheDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.cachedAt,
    this.email,
    this.location,
    this.profileImageUrl,
  });

  // Parse from Hive storage
  factory ProfileCacheDto.fromJson(Map<String, dynamic> json) {
    return ProfileCacheDto(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      location: json['location'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      cachedAt: DateTime.parse(json['cached_at'] as String),
    );
  }

  // Serialize to Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (location != null) 'location': location,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      'cached_at': cachedAt.toIso8601String(),
    };
  }

  // Convert to ProfileDto
  ProfileDto toDto() {
    return ProfileDto(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      profileImageUrl: profileImageUrl,
    );
  }

  // Create from ProfileDto
  factory ProfileCacheDto.fromDto(ProfileDto dto) {
    return ProfileCacheDto(
      id: dto.id,
      firstName: dto.firstName,
      lastName: dto.lastName,
      phoneNumber: dto.phoneNumber,
      email: dto.email,
      profileImageUrl: dto.profileImageUrl,
      cachedAt: DateTime.now(),
    );
  }

  // Check if cache is stale (older than 24 hours)
  bool get isStale {
    final age = DateTime.now().difference(cachedAt);
    return age.inHours >= 24;
  }
}
```

---

### 4. Response Wrappers

#### ProfileFetchResponse

**Purpose:** Wraps API response with cache metadata

```dart
class ProfileFetchResponse {
  final ProfileDto? profile;
  final String? lastModified;
  final bool isNotModified;

  const ProfileFetchResponse({
    this.profile,
    this.lastModified,
    this.isNotModified = false,
  });

  // Factory for 304 Not Modified response
  factory ProfileFetchResponse.notModified() {
    return const ProfileFetchResponse(isNotModified: true);
  }
}
```

#### ProfileFetchResult

**Purpose:** Repository result with cache metadata for UI

```dart
class ProfileFetchResult {
  final Profile profile;
  final bool isStale;
  final bool fromCache;

  const ProfileFetchResult({
    required this.profile,
    required this.isStale,
    required this.fromCache,
  });
}
```

---

## Repository Pattern

### Abstract Interface

**File:** `domain/repositories/profile_repository.dart`

```dart
abstract class ProfileRepository {
  /// Fetch profile (cache-first strategy)
  Future<Profile> fetchProfile();

  /// Fetch profile with cache metadata
  Future<ProfileFetchResult> fetchProfileWithCache();

  /// Refresh profile from API (background refresh)
  Future<Profile?> refreshProfileFromApi();

  /// Update profile information
  Future<Profile> updateProfile({
    required String fullName,
    required String phoneNumber,
  });

  /// Delete user account
  Future<void> deleteAccount();

  /// Logout (clear cache)
  Future<void> logout();
}
```

---

### Implementation

**File:** `infrastructure/repositories/profile_repository_impl.dart`

#### 1. Cache-First Fetch

```dart
@override
Future<ProfileFetchResult> fetchProfileWithCache() async {
  try {
    // 1. Check local cache first
    final cachedResult = await _localDataSource.getCachedProfile();

    if (cachedResult != null) {
      final profile = cachedResult.profile.toDomain();
      final isStale = cachedResult.isStale;

      Logger.info('Profile loaded from cache', data: {
        'is_stale': isStale,
        'cached_at': cachedResult.cachedAt.toIso8601String(),
      });

      return ProfileFetchResult(
        profile: profile,
        isStale: isStale,
        fromCache: true,
      );
    }

    // 2. No cache - fetch from API
    Logger.info('No cached profile found, fetching from API');
    final response = await _remoteDataSource.fetchProfile();

    if (response.isNotModified) {
      throw Exception('304 received but no cache available');
    }

    final profile = response.profile!.toDomain();

    // 3. Cache asynchronously (non-blocking)
    _localDataSource.cacheProfileAsync(response.profile!);

    return ProfileFetchResult(
      profile: profile,
      isStale: false,
      fromCache: false,
    );
  } catch (e) {
    Logger.error('Failed to fetch profile', error: e);
    rethrow;
  }
}
```

**Flow Diagram:**
```
┌─────────────────────────────────────────┐
│ fetchProfileWithCache()                 │
├─────────────────────────────────────────┤
│ 1. Check local cache                    │
│    ├─ Cache HIT                         │
│    │  ├─ Return immediately              │
│    │  └─ Mark as stale if > 24h         │
│    └─ Cache MISS                        │
│       ├─ Fetch from API                 │
│       ├─ Cache asynchronously           │
│       └─ Return fresh data              │
│                                         │
│ Benefits:                               │
│ ✓ Instant UI (no loading spinner)      │
│ ✓ Works offline                         │
│ ✓ Non-blocking cache writes             │
└─────────────────────────────────────────┘
```

---

#### 2. Background Refresh

```dart
@override
Future<Profile?> refreshProfileFromApi() async {
  try {
    Logger.info('Refreshing profile in background');

    final response = await _remoteDataSource.fetchProfile();

    // Handle 304 Not Modified (data unchanged)
    if (response.isNotModified) {
      Logger.info('Profile not modified (304), using cached data');
      return null;
    }

    final profile = response.profile!.toDomain();

    // Cache asynchronously
    _localDataSource.cacheProfileAsync(response.profile!);

    Logger.info('Profile refreshed successfully');
    return profile;
  } catch (e) {
    // Silently fail - keep existing cached data
    Logger.error('Background refresh failed', error: e);
    return null;
  }
}
```

**Usage Pattern:**
```dart
// In ProfileController:
Future<void> _refreshInBackground() async {
  final freshProfile = await _repository.refreshProfileFromApi();

  if (freshProfile != null) {
    // Update state with fresh data
    state = state.copyWith(
      profile: freshProfile,
      isStale: false,
    );
  }
  // If null (304 or error), keep existing state
}
```

---

#### 3. Standard Fetch (Wrapper)

```dart
@override
Future<Profile> fetchProfile() async {
  final result = await fetchProfileWithCache();
  return result.profile;
}
```

---

#### 4. Update Profile

```dart
@override
Future<Profile> updateProfile({
  required String fullName,
  required String phoneNumber,
}) async {
  try {
    Logger.info('Updating profile', data: {
      'full_name': fullName,
      'phone_number': phoneNumber,
    });

    final updatedDto = await _remoteDataSource.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );

    final profile = updatedDto.toDomain();

    // Cache updated profile asynchronously
    _localDataSource.cacheProfileAsync(updatedDto);

    Logger.info('Profile updated successfully');
    return profile;
  } catch (e) {
    Logger.error('Failed to update profile', error: e);
    rethrow;
  }
}
```

---

#### 5. Delete Account

```dart
@override
Future<void> deleteAccount() async {
  try {
    Logger.info('Deleting user account');

    await _remoteDataSource.deleteAccount();

    // Clear all cached data
    await _localDataSource.clearCache();

    Logger.info('Account deleted successfully');
  } catch (e) {
    Logger.error('Failed to delete account', error: e);
    rethrow;
  }
}
```

---

#### 6. Logout

```dart
@override
Future<void> logout() async {
  Logger.info('Logging out - clearing profile cache');
  await _localDataSource.clearCache();
}
```

---

## Caching Strategy

### Overview

The profile feature implements a **sophisticated multi-layer caching system** optimized for both performance and user experience.

---

### Cache Technology

**Storage:** Hive (lightweight NoSQL database)

**Location:**
```
Hive Box: AppHiveBoxes.profile
Key: 'cached_profile'
Data: ProfileCacheDto (JSON serialized)
```

**Code Setup:**
```dart
class ProfileLocalDs {
  final Box _box;

  ProfileLocalDs({required Box box}) : _box = box;

  static const String _kProfileKey = 'cached_profile';
  static const int _kCacheValidityHours = 24;
}
```

---

### Cache Lifecycle

#### 1. Cache Validity Rules

```dart
Cache States:
├─ FRESH: Age < 24 hours
│  └─ isStale = false
│  └─ No background refresh needed
│
├─ STALE: Age >= 24 hours
│  └─ isStale = true
│  └─ Trigger background refresh
│  └─ Still returned to user (offline support)
│
└─ MISSING: No cache exists
   └─ Show loading spinner
   └─ Fetch from API
```

**Implementation:**
```dart
Future<CachedProfileResult?> getCachedProfile() async {
  try {
    final cached = _box.get(_kProfileKey);
    if (cached == null) return null;

    final cacheDto = ProfileCacheDto.fromJson(
      Map<String, dynamic>.from(cached as Map),
    );

    // Calculate age
    final age = DateTime.now().difference(cacheDto.cachedAt);
    final isStale = age.inHours >= _kCacheValidityHours;

    return CachedProfileResult(
      profile: cacheDto.toDto(),
      isStale: isStale,
      cachedAt: cacheDto.cachedAt,
    );
  } catch (e) {
    Logger.error('Failed to read cached profile', error: e);
    return null; // Corrupted cache = treat as missing
  }
}
```

---

#### 2. Cache Population Events

**When to Cache:**
```
✅ After successful API fetch
✅ After successful profile update
✅ On app resume (if profile exists in memory)

❌ Never auto-delete cache (kept for offline access)
❌ Never cache on API error
```

---

#### 3. Cache Invalidation Events

**When to Clear:**
```
✅ User logout
✅ Account deletion
✅ Explicit cache clear (admin/debug only)

❌ Never on stale timeout
❌ Never on background refresh failure
```

**Implementation:**
```dart
Future<void> clearCache() async {
  await _box.delete(_kProfileKey);
  Logger.info('Profile cache cleared');
}

Future<void> clearAll() async {
  await _box.clear();
  Logger.info('All profile data cleared');
}
```

---

### Non-Blocking Cache Writes

**Key Design Pattern: Fire-and-Forget**

```dart
/// Cache profile asynchronously (non-blocking)
void cacheProfileAsync(ProfileDto profile) {
  // Don't await - fire and forget
  _saveCacheInternal(profile);
}

Future<void> _saveCacheInternal(ProfileDto profile) async {
  try {
    final cacheDto = ProfileCacheDto.fromDto(profile);
    await _box.put(_kProfileKey, cacheDto.toJson());
    Logger.debug('Profile cached successfully');
  } catch (e) {
    // Silently fail - cache is not critical
    Logger.error('Failed to cache profile', error: e);
  }
}
```

**Benefits:**
- ✅ UI never blocked by cache operations
- ✅ Failed cache writes don't crash the app
- ✅ Smooth user experience
- ✅ Cache is "best-effort" optimization

**Usage:**
```dart
// In repository:
final profile = await _remoteDataSource.fetchProfile();

// Cache asynchronously (don't await)
_localDataSource.cacheProfileAsync(profile);

// Immediately return to user
return profile.toDomain();
```

---

### HTTP Caching (Conditional Requests)

**Protocol:** HTTP 1.1 Conditional Requests

**Headers Used:**
- `If-Modified-Since` (request)
- `Last-Modified` (response)

**Flow:**
```
┌─────────────────────────────────────────┐
│ 1. First Fetch                          │
├─────────────────────────────────────────┤
│ GET /profile/                           │
│                                         │
│ Response: 200 OK                        │
│ Last-Modified: Mon, 23 May 2024 10:00  │
│ Body: { profile data }                  │
│                                         │
│ → Save Last-Modified header             │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 2. Subsequent Fetch (with header)       │
├─────────────────────────────────────────┤
│ GET /profile/                           │
│ If-Modified-Since: Mon, 23 May 2024... │
│                                         │
│ Case A: Data Changed                    │
│ Response: 200 OK                        │
│ Last-Modified: Thu, 17 Jan 2026 12:00  │
│ Body: { updated profile data }          │
│                                         │
│ Case B: Data Unchanged (Bandwidth Saved)│
│ Response: 304 Not Modified              │
│ Body: (empty)                           │
│ → Use cached data                       │
└─────────────────────────────────────────┘
```

**Implementation:**
```dart
class ProfileApi {
  String? _lastModified;

  Future<ProfileFetchResponse> fetchProfile({
    String? ifModifiedSince,
  }) async {
    final headers = <String, String>{};
    if (ifModifiedSince ?? _lastModified != null) {
      headers['If-Modified-Since'] = ifModifiedSince ?? _lastModified!;
    }

    final response = await _client.get(
      'api/auth/v1/profile/',
      headers: headers.isEmpty ? null : headers,
    );

    // Handle 304 Not Modified
    if (response.statusCode == 304) {
      return ProfileFetchResponse.notModified();
    }

    // Save Last-Modified for next request
    _lastModified = response.headers.value('last-modified');

    return ProfileFetchResponse(
      profile: ProfileDto.fromJson(response.data),
      lastModified: _lastModified,
    );
  }
}
```

**Benefits:**
- ✅ Reduces bandwidth usage (no body in 304 response)
- ✅ Server-side cache validation
- ✅ Standard HTTP behavior
- ✅ Works with CDNs and proxies

---

### Cache-First UX Flow

**Complete User Experience:**

```
User Opens Profile Screen
    ↓
┌─────────────────────────────────────────┐
│ INSTANT UI (0ms)                        │
├─────────────────────────────────────────┤
│ ✓ Check Hive cache                      │
│ ✓ Cache found → Show immediately        │
│ ✓ No loading spinner                    │
│                                         │
│ UI State:                               │
│ - Profile data visible                  │
│ - If stale: Warning banner              │
│   "Showing offline data. Pull to refresh"│
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ BACKGROUND REFRESH (non-blocking)       │
├─────────────────────────────────────────┤
│ ✓ Triggered if cache is stale           │
│ ✓ User can interact with UI             │
│ ✓ No loading indicator                  │
│                                         │
│ If API Returns Fresh Data:              │
│ - UI smoothly updates                   │
│ - Warning banner fades out              │
│                                         │
│ If API Returns 304:                     │
│ - No UI change (data unchanged)         │
│ - Warning banner disappears             │
│                                         │
│ If API Fails:                           │
│ - Silently ignored                      │
│ - User keeps cached data                │
│ - Warning banner remains                │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ PULL-TO-REFRESH (user action)           │
├─────────────────────────────────────────┤
│ ✓ Force fresh API call                  │
│ ✓ Show loading indicator                │
│ ✓ Update cache on success               │
│ ✓ Show error if fails                   │
└─────────────────────────────────────────┘
```

**Code Implementation:**
```dart
// In ProfileController:
Future<void> fetchProfile() async {
  // Smart loading: only show spinner if no data exists
  if (state.profile == null) {
    state = state.copyWith(status: ProfileStatus.loading);
  }

  try {
    final result = await _repository.fetchProfileWithCache();

    state = state.copyWith(
      status: ProfileStatus.data,
      profile: result.profile,
      isStale: result.isStale,
    );

    // Trigger background refresh if stale
    if (result.isStale) {
      _refreshInBackground(); // Don't await
    }
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: _mapError(e),
    );
  }
}
```

---

## State Management

### State Model

**File:** `application/states/profile_state.dart`

```dart
enum ProfileStatus {
  initial,    // No data loaded yet
  loading,    // Fetching from API (no cached data)
  data,       // Data available (cached or fresh)
  error,      // Error occurred
}

class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;
  final bool? isUpdating;
  final bool? isDeletingAccount;
  final bool isStale;

  const ProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
    this.isUpdating,
    this.isDeletingAccount,
    this.isStale = false,
  });

  // Computed properties
  bool get hasData => profile != null;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isError => status == ProfileStatus.error;

  // Initial state factory
  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  // Copy with method
  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
    bool? isUpdating,
    bool? isDeletingAccount,
    bool? isStale,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      isStale: isStale ?? this.isStale,
    );
  }
}
```

**State Transitions:**
```
initial
  ↓ (fetchProfile called)
loading (if no cache)
  ↓ (API success)
data (profile loaded)
  ↓ (updateProfile called)
data (isUpdating: true)
  ↓ (update success)
data (isUpdating: false, updated profile)

data
  ↓ (deleteAccount called)
data (isDeletingAccount: true)
  ↓ (delete success)
initial (reset)
```

---

### Provider Architecture

**File:** `application/providers/profile_provider.dart`

#### 1. Dependency Providers (Singleton)

```dart
/// Local data source provider
final profileLocalDsProvider = Provider<ProfileLocalDs>((ref) {
  final box = Hive.box(AppHiveBoxes.profile);
  return ProfileLocalDs(box: box);
});

/// Remote API provider
final profileApiProvider = Provider<ProfileApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileApi(client: apiClient);
});

/// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileApiProvider);
  final localDataSource = ref.watch(profileLocalDsProvider);

  return ProfileRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});
```

**Benefits:**
- ✅ Single source of truth
- ✅ Lazy initialization
- ✅ Automatic dependency injection
- ✅ Easy to mock for testing

---

#### 2. State Controller (Notifier)

```dart
/// Profile controller provider (manages state)
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(() {
  return ProfileController();
});

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.read(profileRepositoryProvider);
    return ProfileState.initial();
  }

  // Methods documented below...
}
```

---

### Controller Methods

#### 1. Fetch Profile (Smart Loading)

```dart
Future<void> fetchProfile() async {
  try {
    // Smart loading: only show spinner if no cached data
    if (state.profile == null) {
      state = state.copyWith(status: ProfileStatus.loading);
    }

    final result = await _repository.fetchProfileWithCache();

    state = state.copyWith(
      status: ProfileStatus.data,
      profile: result.profile,
      isStale: result.isStale,
      errorMessage: null,
    );

    // Trigger background refresh if stale (non-blocking)
    if (result.isStale) {
      _refreshInBackground(); // Don't await
    }
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: _mapError(e),
    );
  }
}
```

**Smart Loading Logic:**
```
Has cached data?
├─ YES: Show data immediately (no spinner)
│  └─ If stale: trigger background refresh
└─ NO: Show loading spinner
   └─ Fetch from API
```

---

#### 2. Background Refresh (Non-Blocking)

```dart
Future<void> _refreshInBackground() async {
  try {
    Logger.info('Starting background profile refresh');

    final freshProfile = await _repository.refreshProfileFromApi();

    if (freshProfile != null) {
      // Update state with fresh data
      state = state.copyWith(
        profile: freshProfile,
        isStale: false,
      );
      Logger.info('Background refresh completed successfully');
    } else {
      // 304 or error - keep existing state
      Logger.info('Background refresh: no new data (304 or error)');
    }
  } catch (e) {
    // Silently fail - keep existing cached data
    Logger.error('Background refresh failed', error: e);
  }
}
```

**Key Characteristics:**
- ✅ Non-blocking (fire-and-forget)
- ✅ No loading indicator
- ✅ Silent failure (UX not disrupted)
- ✅ Updates UI only if fresh data received

---

#### 3. Manual Refresh (Pull-to-Refresh)

```dart
Future<void> refreshProfile() async {
  try {
    Logger.info('Manual profile refresh triggered');

    final freshProfile = await _repository.refreshProfileFromApi();

    if (freshProfile != null) {
      state = state.copyWith(
        status: ProfileStatus.data,
        profile: freshProfile,
        isStale: false,
        errorMessage: null,
      );
    }
  } catch (e) {
    // Show error to user (unlike background refresh)
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: _mapError(e),
    );
    rethrow; // Let UI handle error display
  }
}
```

**Difference from Background Refresh:**
```
Background Refresh:
- Silent failure
- No user feedback
- Keep existing data on error

Manual Refresh:
- Show error to user
- Update UI state
- Rethrow exception for snackbar
```

---

#### 4. Update Profile

```dart
Future<void> updateProfile({
  required String fullName,
  required String phoneNumber,
}) async {
  try {
    state = state.copyWith(isUpdating: true);

    final updatedProfile = await _repository.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );

    state = state.copyWith(
      status: ProfileStatus.data,
      profile: updatedProfile,
      isUpdating: false,
      isStale: false, // Fresh data from API
      errorMessage: null,
    );
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: _mapError(e),
      isUpdating: false,
    );
    rethrow;
  }
}
```

**UI Integration:**
```dart
// In ProfileEditScreen:
final isUpdating = ref.watch(
  profileControllerProvider.select((s) => s.isUpdating),
);

ElevatedButton(
  onPressed: isUpdating ? null : _handleSave,
  child: isUpdating
    ? CircularProgressIndicator()
    : Text('Save'),
)
```

---

#### 5. Delete Account

```dart
Future<void> deleteAccount() async {
  try {
    state = state.copyWith(isDeletingAccount: true);

    await _repository.deleteAccount();

    // Reset to initial state
    state = ProfileState.initial();
  } catch (e) {
    state = state.copyWith(
      status: ProfileStatus.error,
      errorMessage: _mapError(e),
      isDeletingAccount: false,
    );
    rethrow;
  }
}
```

**Important:** This is a destructive operation. Always require user confirmation before calling.

---

#### 6. Logout

```dart
Future<void> logout() async {
  await _repository.logout();
  state = ProfileState.initial();
}
```

**Note:** Logout always resets state, even if repository operation fails.

---

#### 7. Error Mapping

```dart
String _mapError(Object error) {
  if (error is NetworkException) {
    if (error.statusCode == 401) {
      return 'Session expired. Please login again.';
    }
    if (error.statusCode == 404) {
      return 'Profile not found.';
    }
    if (error.statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    return error.message;
  }

  if (error is FormatException) {
    return 'Invalid data received. Please try again.';
  }

  if (error is TimeoutException) {
    return 'Request timed out. Please check your connection.';
  }

  return 'Something went wrong. Please try again.';
}
```

---

## Business Logic & Use Cases

### Use Case Pattern

Each use case encapsulates a single business operation following the **Command Pattern**.

**Structure:**
```dart
class UseCaseName {
  final ProfileRepository _repository;

  UseCaseName({required ProfileRepository repository})
    : _repository = repository;

  Future<ReturnType> call({required params}) {
    return _repository.method(params);
  }
}
```

---

### 1. Fetch Profile Use Case

**File:** `application/usecases/fetch_profile.dart`

```dart
class FetchProfile {
  final ProfileRepository _repository;

  FetchProfile({required ProfileRepository repository})
    : _repository = repository;

  Future<Profile> call() {
    return _repository.fetchProfile();
  }
}

// Provider
final fetchProfileProvider = Provider<FetchProfile>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return FetchProfile(repository: repository);
});
```

**Usage:**
```dart
final fetchProfile = ref.read(fetchProfileProvider);
final profile = await fetchProfile();
```

---

### 2. Update Profile Use Case

**File:** `application/usecases/update_profile.dart`

```dart
class UpdateProfile {
  final ProfileRepository _repository;

  UpdateProfile({required ProfileRepository repository})
    : _repository = repository;

  Future<Profile> call({
    required String fullName,
    required String phoneNumber,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}

// Provider
final updateProfileProvider = Provider<UpdateProfile>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfile(repository: repository);
});
```

**Usage:**
```dart
final updateProfile = ref.read(updateProfileProvider);
final updated = await updateProfile(
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
);
```

---

### 3. Delete Account Use Case

**File:** `application/usecases/delete_account.dart`

```dart
class DeleteAccount {
  final ProfileRepository _repository;

  DeleteAccount({required ProfileRepository repository})
    : _repository = repository;

  Future<void> call() {
    return _repository.deleteAccount();
  }
}

// Provider
final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return DeleteAccount(repository: repository);
});
```

**Usage:**
```dart
final deleteAccount = ref.read(deleteAccountProvider);
await deleteAccount();
```

---

### 4. Logout Use Case

**File:** `application/usecases/logout.dart`

```dart
class Logout {
  final ProfileRepository _repository;

  Logout({required ProfileRepository repository})
    : _repository = repository;

  Future<void> call() {
    return _repository.logout();
  }
}

// Provider
final logoutProvider = Provider<Logout>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return Logout(repository: repository);
});
```

**Usage:**
```dart
final logout = ref.read(logoutProvider);
await logout();
```

---

### Benefits of Use Case Pattern

| Benefit | Description |
|---------|-------------|
| **Single Responsibility** | Each use case handles one operation |
| **Testability** | Easy to mock and unit test |
| **Reusability** | Can be used across multiple UI components |
| **Clarity** | Clear business intent |
| **Flexibility** | Easy to add validation or business rules |

---

## Request/Response Patterns

### Complete API Communication Flow

```
┌──────────────────────────────────────────────────────────┐
│                   CLIENT (Flutter App)                   │
├──────────────────────────────────────────────────────────┤
│ ProfileController.fetchProfile()                         │
│   ↓                                                      │
│ ProfileRepository.fetchProfileWithCache()                │
│   ↓                                                      │
│ ProfileLocalDs.getCachedProfile()                        │
│   ├─ Cache HIT: Return immediately                       │
│   └─ Cache MISS: Continue to API                        │
│                                                          │
│ ProfileApi.fetchProfile(ifModifiedSince)                 │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼ (HTTP Request)
┌──────────────────────────────────────────────────────────┐
│                    SERVER (Django)                       │
├──────────────────────────────────────────────────────────┤
│ Receive: GET /api/auth/v1/profile/                      │
│ Headers: {                                               │
│   Cookie: sessionid=xyz123,                              │
│   X-CSRFToken: abc456,                                   │
│   If-Modified-Since: Mon, 23 May 2024...                 │
│ }                                                        │
│                                                          │
│ ├─ Validate session cookie                              │
│ ├─ Check If-Modified-Since header                       │
│ │  ├─ Data unchanged → 304 Not Modified                 │
│ │  └─ Data changed → 200 OK with body                   │
│ │                                                        │
│ └─ Response: {                                           │
│     Status: 200 OK,                                      │
│     Headers: { Last-Modified: ... },                     │
│     Body: { profile JSON }                               │
│   }                                                      │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼ (HTTP Response)
┌──────────────────────────────────────────────────────────┐
│                   CLIENT (Flutter App)                   │
├──────────────────────────────────────────────────────────┤
│ ProfileApi receives response                             │
│   ↓                                                      │
│ ProfileDto.fromJson(response.data)                       │
│   ↓                                                      │
│ ProfileLocalDs.cacheProfileAsync(dto)  [fire-and-forget] │
│   ↓                                                      │
│ ProfileDto.toDomain() → Profile entity                   │
│   ↓                                                      │
│ ProfileController updates state                          │
│   ↓                                                      │
│ UI rebuilds with new data                                │
└──────────────────────────────────────────────────────────┘
```

---

### Detailed Request Examples

#### 1. Initial Profile Fetch

**Request:**
```http
GET /api/auth/v1/profile/ HTTP/1.1
Host: 156.67.104.149:8012
Cookie: sessionid=xyz123abc
X-CSRFToken: abc456def
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json
Last-Modified: Thu, 17 Jan 2026 10:00:00 GMT

{
  "id": "user-123",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "email": "john@example.com",
  "username": "johndoe",
  "role": "user",
  "profile_image": "https://example.com/avatar.jpg",
  "created_at": "2022-05-23T22:22:01Z",
  "updated_at": "2024-01-17T10:00:00Z"
}
```

---

#### 2. Conditional Fetch (Cache Validation)

**Request:**
```http
GET /api/auth/v1/profile/ HTTP/1.1
Host: 156.67.104.149:8012
Cookie: sessionid=xyz123abc
X-CSRFToken: abc456def
If-Modified-Since: Thu, 17 Jan 2026 10:00:00 GMT
```

**Response (Data Unchanged):**
```http
HTTP/1.1 304 Not Modified
Last-Modified: Thu, 17 Jan 2026 10:00:00 GMT
```
> No body returned - use cached data

**Response (Data Changed):**
```http
HTTP/1.1 200 OK
Content-Type: application/json
Last-Modified: Fri, 18 Jan 2026 14:30:00 GMT

{
  "id": "user-123",
  "first_name": "John",
  "last_name": "Smith",  ← Changed
  "phone_number": "+1234567890",
  "email": "john.smith@example.com",  ← Changed
  ...
}
```

---

#### 3. Update Profile

**Request:**
```http
PATCH /api/auth/v1/profile/ HTTP/1.1
Host: 156.67.104.149:8012
Content-Type: application/json
Cookie: sessionid=xyz123abc
X-CSRFToken: abc456def

{
  "first_name": "Jane",
  "last_name": "Doe",
  "phone_number": "+0987654321"
}
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "user-123",
  "first_name": "Jane",
  "last_name": "Doe",
  "phone_number": "+0987654321",
  "email": "john@example.com",
  "username": "johndoe",
  "role": "user",
  "profile_image": "https://example.com/avatar.jpg",
  "created_at": "2022-05-23T22:22:01Z",
  "updated_at": "2026-01-18T15:45:00Z"  ← Updated timestamp
}
```

---

#### 4. Delete Account

**Request:**
```http
POST /api/auth/v1/delete-account/ HTTP/1.1
Host: 156.67.104.149:8012
Cookie: sessionid=xyz123abc
X-CSRFToken: abc456def
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{}
```

Or:

```http
HTTP/1.1 204 No Content
```

---

## Error Handling

### Error Types & Recovery Strategies

#### 1. Network Errors

**No Internet Connection:**
```dart
NetworkException(
  message: 'No internet connection',
  statusCode: null,
  errorType: NetworkErrorType.noInternet,
)

Recovery:
├─ If cache exists: Return cached data
│  └─ Show warning: "Showing offline data"
└─ If no cache: Show error screen with retry button
```

**Timeout:**
```dart
NetworkException(
  message: 'Request timed out',
  statusCode: null,
  errorType: NetworkErrorType.timeout,
)

Recovery:
├─ If cache exists: Return cached data
└─ Show error: "Connection is slow. Please try again."
```

---

#### 2. HTTP Errors

**401 Unauthorized (Session Expired):**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

```dart
Recovery:
├─ Clear all cached data
├─ Logout user
└─ Redirect to login screen
```

**404 Not Found (Profile Doesn't Exist):**
```json
{
  "detail": "Not found."
}
```

```dart
Recovery:
├─ Show error: "Profile not found"
└─ Offer to re-login or create profile
```

**400 Bad Request (Validation Error):**
```json
{
  "phone_number": ["Enter a valid phone number."],
  "email": ["Enter a valid email address."]
}
```

```dart
Recovery:
├─ Parse field-specific errors
├─ Show errors next to input fields
└─ Keep user's input (don't clear form)
```

**500 Internal Server Error:**
```json
{
  "detail": "Internal server error"
}
```

```dart
Recovery:
├─ If cache exists: Return cached data
│  └─ Show warning: "Unable to refresh. Showing offline data."
├─ If no cache: Show generic error
└─ Offer retry button
```

---

#### 3. Parsing Errors

**Invalid JSON:**
```dart
FormatException('Unexpected character')

Recovery:
├─ Log error for debugging
├─ Show user: "Invalid data received"
└─ If cache exists: Return cached data
```

**Missing Required Fields:**
```dart
FormatException('First name is required')

Recovery:
├─ Log detailed error for debugging
├─ Show user: "Invalid profile data"
└─ Offer retry or contact support
```

**Corrupted Cache:**
```dart
FormatException('Invalid cached data format')

Recovery:
├─ Clear corrupted cache
├─ Fetch fresh data from API
└─ No error shown to user (transparent recovery)
```

---

### Error Handling Code Examples

#### Repository Layer

```dart
@override
Future<ProfileFetchResult> fetchProfileWithCache() async {
  try {
    // Try cache first
    final cachedResult = await _localDataSource.getCachedProfile();

    if (cachedResult != null) {
      return ProfileFetchResult(
        profile: cachedResult.profile.toDomain(),
        isStale: cachedResult.isStale,
        fromCache: true,
      );
    }

    // Fetch from API
    final response = await _remoteDataSource.fetchProfile();
    final profile = response.profile!.toDomain();

    // Cache asynchronously
    _localDataSource.cacheProfileAsync(response.profile!);

    return ProfileFetchResult(
      profile: profile,
      isStale: false,
      fromCache: false,
    );
  } on NetworkException catch (e) {
    // Network error - try to return stale cache
    final cachedResult = await _localDataSource.getCachedProfile();
    if (cachedResult != null) {
      Logger.warn('Network error, using stale cache', data: {
        'error': e.message,
        'cached_age_hours': DateTime.now()
            .difference(cachedResult.cachedAt)
            .inHours,
      });

      return ProfileFetchResult(
        profile: cachedResult.profile.toDomain(),
        isStale: true,
        fromCache: true,
      );
    }

    // No cache available - rethrow
    rethrow;
  } on FormatException catch (e) {
    // Parsing error - try cache
    final cachedResult = await _localDataSource.getCachedProfile();
    if (cachedResult != null) {
      Logger.error('Parsing error, using cache', error: e);
      return ProfileFetchResult(
        profile: cachedResult.profile.toDomain(),
        isStale: true,
        fromCache: true,
      );
    }

    // No cache - rethrow
    rethrow;
  } catch (e) {
    Logger.error('Unexpected error fetching profile', error: e);
    rethrow;
  }
}
```

---

#### Controller Layer

```dart
String _mapError(Object error) {
  if (error is NetworkException) {
    switch (error.errorType) {
      case NetworkErrorType.noInternet:
        return 'No internet connection. Please check your network.';

      case NetworkErrorType.timeout:
        return 'Request timed out. Please try again.';

      case NetworkErrorType.serverError:
        return 'Server error. Please try again later.';

      case NetworkErrorType.clientError:
        if (error.statusCode == 401) {
          return 'Your session expired. Please login again.';
        }
        if (error.statusCode == 404) {
          return 'Profile not found.';
        }
        return error.message;

      default:
        return 'Unable to connect. Please try again.';
    }
  }

  if (error is FormatException) {
    return 'Invalid data received. Please try again.';
  }

  if (error is TimeoutException) {
    return 'Request timed out. Please check your connection.';
  }

  return 'Something went wrong. Please try again.';
}
```

---

### UI Error Display Patterns

#### 1. Full-Screen Error (No Cached Data)

```dart
if (profileState.isError && !profileState.hasData) {
  return ErrorView(
    message: profileState.errorMessage ?? 'Failed to load profile',
    onRetry: () => ref.read(profileControllerProvider.notifier).fetchProfile(),
  );
}
```

#### 2. Banner Warning (Stale Cached Data)

```dart
if (profileState.isStale) {
  return Container(
    color: Colors.orange.shade100,
    padding: EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Showing offline data. Pull to refresh.',
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      ],
    ),
  );
}
```

#### 3. Snackbar (Operation Errors)

```dart
// In ProfileEditScreen:
try {
  await ref.read(profileControllerProvider.notifier).updateProfile(
    fullName: fullName,
    phoneNumber: phoneNumber,
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(profileState.errorMessage ?? 'Update failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│                  (Framework-Specific UI)                    │
├─────────────────────────────────────────────────────────────┤
│ - ProfileScreen (displays profile data)                     │
│ - ProfileEditScreen (edit form)                             │
│ - ContactUsScreen (support)                                 │
│                                                             │
│ Technologies:                                               │
│ - Flutter widgets                                           │
│ - ConsumerWidget (Riverpod)                                 │
│ - Form validation                                           │
│ - Navigation (go_router)                                    │
└───────────────────────────┬─────────────────────────────────┘
                            │ (watches)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               APPLICATION LAYER (State Management)          │
│                      Framework-Agnostic                     │
├─────────────────────────────────────────────────────────────┤
│ ProfileController (Notifier)                                │
│ ├─ Manages ProfileState                                     │
│ ├─ Orchestrates use cases                                   │
│ ├─ Error mapping                                            │
│ └─ Background refresh logic                                 │
│                                                             │
│ Use Cases:                                                  │
│ ├─ FetchProfile                                             │
│ ├─ UpdateProfile                                            │
│ ├─ DeleteAccount                                            │
│ └─ Logout                                                   │
│                                                             │
│ ProfileState:                                               │
│ ├─ status: ProfileStatus                                    │
│ ├─ profile: Profile?                                        │
│ ├─ errorMessage: String?                                    │
│ ├─ isUpdating: bool?                                        │
│ ├─ isDeletingAccount: bool?                                 │
│ └─ isStale: bool                                            │
└───────────────────────────┬─────────────────────────────────┘
                            │ (calls)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER (Business Logic)           │
│                      Framework-Agnostic                     │
├─────────────────────────────────────────────────────────────┤
│ ProfileRepository (abstract interface)                      │
│ ├─ fetchProfile(): Profile                                  │
│ ├─ fetchProfileWithCache(): ProfileFetchResult              │
│ ├─ refreshProfileFromApi(): Profile?                        │
│ ├─ updateProfile(...): Profile                              │
│ ├─ deleteAccount(): void                                    │
│ └─ logout(): void                                           │
│                                                             │
│ Profile (domain entity)                                     │
│ ├─ id: String                                               │
│ ├─ fullName: String                                         │
│ ├─ mobileNumber: String                                     │
│ ├─ email: String?                                           │
│ ├─ location: String?                                        │
│ └─ profileImageUrl: String?                                 │
└───────────────────────────┬─────────────────────────────────┘
                            │ (implements)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              INFRASTRUCTURE LAYER (Data Access)             │
│                  Framework-Dependent Implementation         │
├─────────────────────────────────────────────────────────────┤
│ ProfileRepositoryImpl                                       │
│ ├─ Cache-first fetch strategy                              │
│ ├─ Background refresh logic                                 │
│ ├─ Error recovery (fallback to cache)                       │
│ └─ Async cache writes                                       │
│                                                             │
│ Data Sources:                                               │
│ ├─ ProfileApi (remote)                                      │
│ │  ├─ HTTP client (Dio)                                     │
│ │  ├─ Conditional requests (If-Modified-Since)              │
│ │  └─ Error handling                                        │
│ │                                                           │
│ └─ ProfileLocalDs (local cache)                             │
│    ├─ Hive storage                                          │
│    ├─ Cache validity checks                                 │
│    └─ Non-blocking writes                                   │
│                                                             │
│ Data Models:                                                │
│ ├─ ProfileDto (API ↔ Domain mapper)                        │
│ │  ├─ fromJson() - defensive parsing                        │
│ │  ├─ toJson() - API request serialization                  │
│ │  └─ toDomain() - convert to entity                        │
│ │                                                           │
│ └─ ProfileCacheDto (Cache structure)                        │
│    ├─ fromDto() - create from ProfileDto                    │
│    ├─ toDto() - convert to ProfileDto                       │
│    ├─ toJson() - serialize for Hive                         │
│    ├─ fromJson() - deserialize from Hive                    │
│    └─ isStale - cache age check                             │
└──────────────────┬──────────────────┬───────────────────────┘
                   │                  │
                   ▼                  ▼
        ┌──────────────────┐  ┌─────────────────┐
        │   Remote API     │  │  Local Storage  │
        │   (HTTP/REST)    │  │     (Hive)      │
        ├──────────────────┤  ├─────────────────┤
        │ GET /profile/    │  │ Box: 'profile'  │
        │ PATCH /profile/  │  │ Key: 'cached_   │
        │ POST /delete-... │  │      profile'   │
        └──────────────────┘  └─────────────────┘
```

---

### Dependency Flow

```
UI Widget
  ↓ watches
ProfileController (via profileControllerProvider)
  ↓ depends on
ProfileRepository (via profileRepositoryProvider)
  ↓ depends on
┌────────────────┬────────────────┐
│                │                │
▼                ▼                ▼
ProfileApi   ProfileLocalDs   Use Cases
(remote)       (cache)
  ↓                ↓
ApiClient      Hive Box
(Dio)
```

---

### Key Design Patterns

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Repository Pattern** | `ProfileRepository` | Abstract data access |
| **Data Mapper** | `ProfileDto`, `ProfileCacheDto` | Layer isolation |
| **Use Case/Command** | `FetchProfile`, `UpdateProfile` | Encapsulate operations |
| **Provider (DI)** | Riverpod providers | Dependency injection |
| **State Management** | `ProfileController` | Reactive UI updates |
| **Cache-First** | `fetchProfileWithCache()` | Optimized UX |
| **Fire-and-Forget** | `cacheProfileAsync()` | Non-blocking writes |
| **Defensive Parsing** | `ProfileDto.fromJson()` | Type safety |
| **HTTP Conditional** | `If-Modified-Since` | Bandwidth optimization |
| **Error Recovery** | Fallback to cache | Graceful degradation |

---

## Replication Guide

### Step-by-Step Implementation for New Projects

---

### Step 1: Project Setup

#### 1.1 Create Directory Structure

```
lib/
└── features/
    └── profile/
        ├── domain/
        │   ├── entities/
        │   │   └── profile.dart
        │   └── repositories/
        │       └── profile_repository.dart
        ├── infrastructure/
        │   ├── data_sources/
        │   │   ├── local/
        │   │   │   ├── profile_local_ds.dart
        │   │   │   └── profile_cache_dto.dart
        │   │   └── remote/
        │   │       └── profile_api.dart
        │   ├── models/
        │   │   └── profile_dto.dart
        │   └── repositories/
        │       └── profile_repository_impl.dart
        ├── application/
        │   ├── providers/
        │   │   └── profile_provider.dart
        │   ├── states/
        │   │   └── profile_state.dart
        │   └── usecases/
        │       ├── fetch_profile.dart
        │       ├── update_profile.dart
        │       ├── delete_account.dart
        │       └── logout.dart
        └── presentation/
            └── screens/
                ├── profile_screen.dart
                └── profile_edit_screen.dart
```

---

#### 1.2 Add Dependencies

**For Flutter:**
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  dio: ^5.3.3
  fpdart: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

**For Other Platforms:**
- Web (React): axios, react-query, zustand
- iOS: Alamofire, Core Data, Combine
- Android: Retrofit, Room, Flow

---

### Step 2: Domain Layer (100% Reusable)

#### 2.1 Create Profile Entity

```dart
// domain/entities/profile.dart

class Profile {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String? location;
  final String? profileImageUrl;

  const Profile({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    this.location,
    this.profileImageUrl,
  });

  String get displayName => fullName.isEmpty ? mobileNumber : fullName;

  Profile copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? email,
    String? location,
    String? profileImageUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          mobileNumber == other.mobileNumber &&
          email == other.email &&
          location == other.location &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        mobileNumber,
        email,
        location,
        profileImageUrl,
      );
}
```

---

#### 2.2 Create Repository Interface

```dart
// domain/repositories/profile_repository.dart

abstract class ProfileRepository {
  Future<Profile> fetchProfile();

  Future<ProfileFetchResult> fetchProfileWithCache();

  Future<Profile?> refreshProfileFromApi();

  Future<Profile> updateProfile({
    required String fullName,
    required String phoneNumber,
  });

  Future<void> deleteAccount();

  Future<void> logout();
}

class ProfileFetchResult {
  final Profile profile;
  final bool isStale;
  final bool fromCache;

  const ProfileFetchResult({
    required this.profile,
    required this.isStale,
    required this.fromCache,
  });
}
```

---

### Step 3: Infrastructure Layer (Adapt to Your Backend)

#### 3.1 Create ProfileDto

```dart
// infrastructure/models/profile_dto.dart

class ProfileDto {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? profileImageUrl;

  const ProfileDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
  });

  // Copy the fromJson, toJson, toDomain, and splitFullName methods
  // from the Data Models section above
}
```

---

#### 3.2 Create ProfileApi

```dart
// infrastructure/data_sources/remote/profile_api.dart

class ProfileApi {
  final ApiClient _client;
  String? _lastModified;

  ProfileApi({required ApiClient client}) : _client = client;

  Future<ProfileFetchResponse> fetchProfile({
    String? ifModifiedSince,
  }) async {
    // Copy implementation from API Endpoints section
  }

  Future<ProfileDto> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    // Copy implementation from API Endpoints section
  }

  Future<void> deleteAccount() async {
    await _client.post('api/auth/v1/delete-account/');
  }
}

class ProfileFetchResponse {
  final ProfileDto? profile;
  final String? lastModified;
  final bool isNotModified;

  const ProfileFetchResponse({
    this.profile,
    this.lastModified,
    this.isNotModified = false,
  });

  factory ProfileFetchResponse.notModified() {
    return const ProfileFetchResponse(isNotModified: true);
  }
}
```

---

#### 3.3 Create ProfileLocalDs

```dart
// infrastructure/data_sources/local/profile_local_ds.dart

class ProfileLocalDs {
  final Box _box;

  static const String _kProfileKey = 'cached_profile';
  static const int _kCacheValidityHours = 24;

  ProfileLocalDs({required Box box}) : _box = box;

  // Copy implementations from Caching Strategy section:
  // - getCachedProfile()
  // - cacheProfileAsync()
  // - _saveCacheInternal()
  // - clearCache()
}

class CachedProfileResult {
  final ProfileDto profile;
  final bool isStale;
  final DateTime cachedAt;

  const CachedProfileResult({
    required this.profile,
    required this.isStale,
    required this.cachedAt,
  });
}
```

---

#### 3.4 Create ProfileRepositoryImpl

```dart
// infrastructure/repositories/profile_repository_impl.dart

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _remoteDataSource;
  final ProfileLocalDs _localDataSource;

  ProfileRepositoryImpl({
    required ProfileApi remoteDataSource,
    required ProfileLocalDs localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // Copy all method implementations from Repository Pattern section:
  // - fetchProfileWithCache()
  // - refreshProfileFromApi()
  // - fetchProfile()
  // - updateProfile()
  // - deleteAccount()
  // - logout()
}
```

---

### Step 4: Application Layer (Framework-Agnostic)

#### 4.1 Create ProfileState

```dart
// application/states/profile_state.dart

enum ProfileStatus { initial, loading, data, error }

class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;
  final bool? isUpdating;
  final bool? isDeletingAccount;
  final bool isStale;

  const ProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
    this.isUpdating,
    this.isDeletingAccount,
    this.isStale = false,
  });

  // Copy all methods from State Management section
}
```

---

#### 4.2 Create ProfileController

```dart
// application/providers/profile_provider.dart

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.read(profileRepositoryProvider);
    return ProfileState.initial();
  }

  // Copy all method implementations from State Management section:
  // - fetchProfile()
  // - _refreshInBackground()
  // - refreshProfile()
  // - updateProfile()
  // - deleteAccount()
  // - logout()
  // - _mapError()
}
```

---

#### 4.3 Create Providers

```dart
// application/providers/profile_provider.dart

// Local data source
final profileLocalDsProvider = Provider<ProfileLocalDs>((ref) {
  final box = Hive.box(AppHiveBoxes.profile);
  return ProfileLocalDs(box: box);
});

// Remote API
final profileApiProvider = Provider<ProfileApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileApi(client: apiClient);
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileApiProvider),
    localDataSource: ref.watch(profileLocalDsProvider),
  );
});

// Controller
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(() {
  return ProfileController();
});
```

---

### Step 5: UI Layer (Framework-Specific)

#### 5.1 For Flutter

```dart
// presentation/screens/profile_screen.dart

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    // Handle loading
    if (profileState.isLoading && !profileState.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    // Handle error
    if (profileState.isError && !profileState.hasData) {
      return ErrorView(
        message: profileState.errorMessage ?? 'Failed to load profile',
        onRetry: () => ref.read(profileControllerProvider.notifier).fetchProfile(),
      );
    }

    // Show data
    final profile = profileState.profile!;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).refreshProfile(),
        child: ListView(
          children: [
            // Stale data warning
            if (profileState.isStale)
              Container(
                color: Colors.orange.shade100,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Showing offline data. Pull to refresh.'),
                    ),
                  ],
                ),
              ),

            // Profile content
            ListTile(
              title: Text('Name'),
              subtitle: Text(profile.fullName),
            ),
            ListTile(
              title: Text('Phone'),
              subtitle: Text(profile.mobileNumber),
            ),
            if (profile.email != null)
              ListTile(
                title: Text('Email'),
                subtitle: Text(profile.email!),
              ),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### 5.2 For React (Web)

```typescript
// hooks/useProfile.ts

import { useQuery, useMutation } from 'react-query';
import { profileRepository } from '../repositories/ProfileRepository';

export function useProfile() {
  const {
    data: result,
    isLoading,
    error,
    refetch,
  } = useQuery('profile', () => profileRepository.fetchProfileWithCache(), {
    staleTime: 24 * 60 * 60 * 1000, // 24 hours
    cacheTime: Infinity,
  });

  const updateMutation = useMutation(
    (data: { fullName: string; phoneNumber: string }) =>
      profileRepository.updateProfile(data),
    {
      onSuccess: () => refetch(),
    }
  );

  return {
    profile: result?.profile,
    isStale: result?.isStale ?? false,
    isLoading,
    error,
    updateProfile: updateMutation.mutate,
    refreshProfile: refetch,
  };
}

// components/ProfileScreen.tsx

export function ProfileScreen() {
  const { profile, isStale, isLoading, error, refreshProfile } = useProfile();

  if (isLoading && !profile) return <LoadingSpinner />;
  if (error && !profile) return <ErrorView onRetry={refreshProfile} />;

  return (
    <div>
      {isStale && (
        <WarningBanner message="Showing offline data. Tap to refresh." />
      )}

      <ProfileDetails profile={profile} />

      <button onClick={() => refreshProfile()}>
        Refresh
      </button>
    </div>
  );
}
```

---

### Step 6: Testing

#### 6.1 Unit Tests (Repository)

```dart
void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileApi mockApi;
  late MockProfileLocalDs mockCache;

  setUp(() {
    mockApi = MockProfileApi();
    mockCache = MockProfileLocalDs();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockApi,
      localDataSource: mockCache,
    );
  });

  group('fetchProfileWithCache', () {
    test('returns cached data when available', () async {
      // Arrange
      final cachedDto = ProfileDto(/* ... */);
      when(() => mockCache.getCachedProfile()).thenAnswer(
        (_) async => CachedProfileResult(
          profile: cachedDto,
          isStale: false,
          cachedAt: DateTime.now(),
        ),
      );

      // Act
      final result = await repository.fetchProfileWithCache();

      // Assert
      expect(result.fromCache, true);
      expect(result.isStale, false);
      verify(() => mockCache.getCachedProfile()).called(1);
      verifyNever(() => mockApi.fetchProfile());
    });

    test('fetches from API when cache is empty', () async {
      // Arrange
      when(() => mockCache.getCachedProfile()).thenAnswer((_) async => null);
      when(() => mockApi.fetchProfile()).thenAnswer(
        (_) async => ProfileFetchResponse(profile: ProfileDto(/* ... */)),
      );

      // Act
      final result = await repository.fetchProfileWithCache();

      // Assert
      expect(result.fromCache, false);
      verify(() => mockCache.getCachedProfile()).called(1);
      verify(() => mockApi.fetchProfile()).called(1);
    });
  });
}
```

---

#### 6.2 Widget Tests (Flutter)

```dart
void main() {
  testWidgets('ProfileScreen shows loading state', (tester) async {
    final container = ProviderContainer(
      overrides: [
        profileControllerProvider.overrideWith(
          () => MockProfileController()..state = ProfileState.initial(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ProfileScreen shows stale data warning', (tester) async {
    final container = ProviderContainer(
      overrides: [
        profileControllerProvider.overrideWith(
          () => MockProfileController()
            ..state = ProfileState(
              status: ProfileStatus.data,
              profile: Profile(/* ... */),
              isStale: true,
            ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Showing offline data. Pull to refresh.'), findsOneWidget);
  });
}
```

---

### Step 7: Platform-Specific Adaptations

#### For iOS (Swift + Combine)

```swift
class ProfileRepository {
    private let api: ProfileAPI
    private let cache: ProfileCache

    func fetchProfileWithCache() -> AnyPublisher<ProfileFetchResult, Error> {
        // Check cache first
        if let cached = cache.getCachedProfile() {
            return Just(ProfileFetchResult(
                profile: cached.profile,
                isStale: cached.isStale,
                fromCache: true
            ))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        // Fetch from API
        return api.fetchProfile()
            .map { dto in
                self.cache.cacheAsync(dto)
                return ProfileFetchResult(
                    profile: dto.toDomain(),
                    isStale: false,
                    fromCache: false
                )
            }
            .eraseToAnyPublisher()
    }
}
```

---

#### For Android (Kotlin + Flow)

```kotlin
class ProfileRepository(
    private val api: ProfileApi,
    private val cache: ProfileCache
) {
    suspend fun fetchProfileWithCache(): ProfileFetchResult {
        // Check cache first
        val cached = cache.getCachedProfile()
        if (cached != null) {
            return ProfileFetchResult(
                profile = cached.profile.toDomain(),
                isStale = cached.isStale,
                fromCache = true
            )
        }

        // Fetch from API
        val response = api.fetchProfile()
        cache.cacheAsync(response.profile)

        return ProfileFetchResult(
            profile = response.profile.toDomain(),
            isStale = false,
            fromCache = false
        )
    }
}
```

---

## Summary & Key Takeaways

### What Makes This Implementation Production-Ready?

1. ✅ **Cache-First UX** - Instant UI, no waiting
2. ✅ **Offline Support** - Full functionality without internet
3. ✅ **Background Refresh** - Non-blocking updates
4. ✅ **Error Recovery** - Graceful degradation
5. ✅ **HTTP Optimization** - Conditional requests (304)
6. ✅ **Type Safety** - Defensive parsing
7. ✅ **Clean Architecture** - Testable, maintainable
8. ✅ **Framework-Agnostic** - Reusable business logic

---

### Replication Checklist

- [ ] Copy domain layer (entities, repository interface)
- [ ] Adapt infrastructure layer (DTOs, API client, cache)
- [ ] Copy application layer (state, controller, use cases)
- [ ] Implement UI layer (framework-specific)
- [ ] Configure dependency injection (providers)
- [ ] Add error handling and logging
- [ ] Write unit tests (repository, use cases)
- [ ] Write integration tests (UI, API)
- [ ] Test offline scenarios
- [ ] Test error recovery
- [ ] Performance testing (cache speed, API latency)

---

### Files Summary (19 Total)

**Domain (2)**: Profile entity, Repository interface
**Infrastructure (5)**: DTO, Cache DTO, API, Local DS, Repository impl
**Application (7)**: State, Controller, Providers, 4 Use Cases
**Presentation (3)**: Profile screen, Edit screen, Contact screen
**Tests (2+)**: Unit tests, Widget tests

---

**Last Updated:** 2026-01-17
**Version:** 1.0
**Backend API:** Django REST at `http://156.67.104.149:8012`
