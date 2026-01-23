# Order Flow Documentation - iMart App

This document describes the order tracking, rating popup, and banner logic in the iMart application.

---

## Table of Contents

1. [Overview](#overview)
2. [Live Order Tracking Banner](#live-order-tracking-banner)
3. [Order Delivered Rating Popup](#order-delivered-rating-popup)
4. [Rate Order Bottom Sheet](#rate-order-bottom-sheet)
5. [Fresh Install Handling](#fresh-install-handling)
6. [SharedPreferences Keys](#sharedpreferences-keys)
7. [File Locations](#file-locations)

---

## Overview

When a user logs into the app, the following checks occur:

1. **Orders are loaded** from the backend via `orderProvider`
2. **Live Order Tracking Banner** evaluates which orders to display
3. **Rating Popup** checks if the latest delivered order needs a rating

---

## Live Order Tracking Banner

**File:** `lib/features/home/presentation/components/live_order_tracking_banner.dart`

### What it Shows

The banner displays active orders at the bottom of the home screen with live status updates.

### Order Status Types

| Status | Banner Behavior |
|--------|-----------------|
| `pending` | Shows with "Order placed!" message |
| `assigned` | Shows with "Order confirmed!" message |
| `at_pickup` | Shows with "Getting packed!" message |
| `picked_up` | Shows with "Picked up!" message |
| `out_for_delivery` | Shows with "On the way!" message |
| `failed` | Shows with "Delivery failed" (with conditions) |
| `delivered` | NOT shown in banner |
| `cancelled` | NOT shown in banner |
| `refunded` | NOT shown in banner |

### Failed Order Conditions

Failed orders are ONLY shown if:
1. It is the **LATEST order** (most recent by creation date)
2. It was created/updated **within the last 24 hours**

This prevents old failed orders from appearing after fresh install.

### Multiple Orders Badge

When multiple active orders exist, a badge shows "+N" to indicate additional orders.

### Dismissing the Banner

- Failed orders can be dismissed by tapping the X button
- Dismissed order IDs are stored in SharedPreferences
- Banner auto-dismisses for failed/cancelled orders after viewing Previous Orders

### Auto-Refresh

The banner auto-refreshes every 30 seconds to get the latest order status.

---

## Order Delivered Rating Popup

**File:** `lib/features/profile/presentation/components/pending_rating_dialog.dart`

### When the Popup Shows

The "Order Delivered!" popup appears when ALL these conditions are met:

1. **Latest Delivered Order Only**: Only considers the most recent delivered order
2. **Not Already Rated**: `order.rating == null`
3. **Popup Not Already Shown**: Order ID not in `shown_popup_orders` list
4. **Not Skipped**: Order ID not in `dismissed_rating_orders` list

### Popup Trigger Points

1. **On Login/Home Screen Load**:
   - Waits for orders to load (polls up to 10 seconds)
   - Then checks `pendingRatingOrderProvider`

2. **On Status Change to Delivered**:
   - `LiveOrderTrackingBanner` detects status transition
   - Calls `showRatingDialogForOrder()` for the specific order

### One-Time Popup Logic

- Popup is marked as "shown" immediately when dialog opens
- If user rates: order gets `rating` value from backend
- If user skips: order ID added to `dismissed_rating_orders`
- Either action prevents popup from showing again

### Auto-Mark Rated Orders

If backend shows an order as already rated (`rating != null`):
- Provider automatically marks it as "shown"
- Prevents popup check loops

---

## Rate Order Bottom Sheet

**File:** `lib/features/profile/presentation/components/rate_order_bottom_sheet.dart`

### Features

- 5-star rating selection with animations
- Optional review text field
- Loading state on submit button
- Success/Error feedback via snackbar

### Rating Submission Flow

1. User selects 1-5 stars
2. User optionally writes review
3. User taps "Submit Review"
4. Loading indicator shows
5. API call to submit rating
6. On success: Close sheet, show success message
7. On "already rated": Show message, reload orders
8. On error: Show error message, stay on sheet

---

## Fresh Install Handling

### What Happens on Fresh Install

1. **SharedPreferences are empty**: No dismissed orders, no shown popups
2. **Orders loaded fresh from backend**: Latest status from server
3. **Rating check uses backend data**: `order.rating` from API

### Preventing Stale Data

| Issue | Solution |
|-------|----------|
| Old failed orders showing | Only show failed if latest AND < 24 hours old |
| Past delivered orders asking for rating | Only check LATEST delivered order |
| Already rated orders showing popup | Check `order.rating != null` from backend, auto-mark as shown |

---

## SharedPreferences Keys

| Key | Purpose | Data Type |
|-----|---------|-----------|
| `shown_popup_orders` | Order IDs where rating popup was shown | `List<String>` |
| `dismissed_rating_orders` | Order IDs where user tapped "Skip" | `List<String>` |
| `dismissed_banner_orders` | Order IDs where banner was dismissed | `List<String>` |
| `order_status_cache` | Cached order statuses for detecting transitions | `List<String>` (format: `orderId:status`) |

---

## File Locations

### Core Files

```
lib/features/
├── home/
│   └── presentation/
│       ├── home.dart                           # HomeScreen with popup trigger
│       └── components/
│           └── live_order_tracking_banner.dart # Order tracking banner
│
└── profile/
    ├── application/
    │   ├── providers/
    │   │   └── order_provider.dart             # Order state management
    │   └── states/
    │       └── order_state.dart                # Order state classes
    │
    └── presentation/
        └── components/
            ├── pending_rating_dialog.dart      # Rating popup dialog
            ├── rate_order_bottom_sheet.dart    # Rating submission UI
            └── orders/
                └── order_card.dart             # Order card with Rate button
```

---

## Flow Diagrams

### Login → Rating Popup Flow

```
User Logs In
    │
    ▼
HomeScreen.didChangeDependencies()
    │
    ▼
_waitForOrdersAndCheckRatings()
    │
    ├── Poll every 500ms for up to 10 seconds
    │
    ▼
Orders Loaded? ───No──► Timeout, no popup
    │
   Yes
    │
    ▼
pendingRatingOrderProvider.future
    │
    ├── Get latest delivered order
    │
    ▼
Already Rated? ───Yes──► Mark as shown, no popup
    │
   No
    │
    ▼
Popup Already Shown? ───Yes──► No popup
    │
   No
    │
    ▼
User Skipped? ───Yes──► No popup
    │
   No
    │
    ▼
Show Rating Popup
```

### Banner Order Filtering Flow

```
Orders from Backend
    │
    ▼
Filter: status != delivered, cancelled, refunded
    │
    ▼
For each order:
    │
    ├── Status == failed?
    │       │
    │      Yes
    │       │
    │       ▼
    │   Is Latest Order? ───No──► HIDE
    │       │
    │      Yes
    │       │
    │       ▼
    │   < 24 hours old? ───No──► HIDE
    │       │
    │      Yes
    │       │
    │       ▼
    │     SHOW
    │
    └── Status != failed ──► SHOW
```

---

## Debug Logging

All order flow logic includes debug prints with `📦` prefix:

- `📦 [Rating]` - Rating popup related logs
- `📦 [Banner]` - Banner filtering logs
- `📦 [LiveBanner]` - Status transition detection

Use Flutter DevTools or console to monitor these logs during testing.

---

## Testing Checklist

### Fresh Install Test
- [ ] Uninstall app completely
- [ ] Install fresh
- [ ] Login with account that has old failed order
- [ ] Verify: Old failed banner does NOT show
- [ ] Verify: Only latest delivered order triggers popup (if unrated)

### Rating Popup Test
- [ ] Deliver an order
- [ ] Verify popup shows once
- [ ] Close app and reopen
- [ ] Verify popup does NOT show again

### Skip Rating Test
- [ ] Deliver an order
- [ ] Tap "Skip for now"
- [ ] Verify popup never shows for that order again

### Already Rated Test
- [ ] Rate an order via Previous Orders screen
- [ ] Close app and reopen
- [ ] Verify popup does NOT show for that order

### Multiple Orders Test
- [ ] Have 2+ active orders
- [ ] Verify banner shows "+1" badge
- [ ] Verify correct order count (excludes failed from count)

---

*Last Updated: January 2026*
