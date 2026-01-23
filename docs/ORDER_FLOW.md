# Order Flow Documentation

## Overview

This document describes the complete order flow in the I-Mart application, from payment initiation to order tracking and status management.

---

## API Endpoints

### Payment Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/order/v1/checkout/` | Initiate payment, get Razorpay order |
| `POST` | `/api/order/v1/payment/verify/` | Verify payment after Razorpay success |

### Order Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/order/v1/orders/` | Get all orders for current user |
| `GET` | `/api/order/v1/orders/{id}/` | Get single order details |
| `GET` | `/api/order/v1/order-lines/?order={id}` | Get order line items (products) |
| `POST` | `/api/order/v1/{id}/ratings/` | Submit order rating |
| `POST` | `/api/order/v1/orders/{id}/reorder/` | Reorder (add same items to cart) |

### Delivery Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/delivery/v1/deliveries/` | Create delivery (Admin only) |
| `GET` | `/api/delivery/v1/deliveries/` | List deliveries (filtered by role) |
| `GET` | `/api/delivery/v1/deliveries/{id}/` | Get specific delivery details |
| `PUT/PATCH` | `/api/delivery/v1/deliveries/{id}/` | Update delivery status |

---

## Delivery Status Flow

### Status Progression

```
pending → assigned → at_pickup → picked_up → out_for_delivery → delivered
                                                              ↘ failed
```

### Status Definitions

| Status | Step | UI Label | Description | Auto-set Fields |
|--------|------|----------|-------------|-----------------|
| `pending` | 0 | Order Placed | Delivery created, not assigned | - |
| `assigned` | 1 | Order Confirmed | Delivery partner assigned | `assigned_at` |
| `at_pickup` | 2 | Getting Packed | Partner at pickup location | - |
| `picked_up` | 3 | Picked Up | Order picked up by partner | `picked_up_at` |
| `out_for_delivery` | 4 | Out for Delivery | Order being delivered | - |
| `delivered` | 5 | Delivered | Order delivered successfully | `delivered_at` |
| `failed` | -2 | Failed | Delivery failed | - |

### Special Status Values

| Status | Step | UI Label | Color | Description |
|--------|------|----------|-------|-------------|
| `refunded` | -1 | Refunded | Orange | Payment refunded (from `payment_status`) |
| `cancelled` | - | Cancelled | Red | Order cancelled |
| `failed` | -2 | Failed | Red | Delivery failed |

---

## Complete Order Flow

### Phase 1: Payment Initiation

```
User clicks "Place Order"
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  POST /api/order/v1/checkout/                           │
│  Request: {}  (empty body)                              │
│  Response: {                                            │
│    "razorpay_order_id": "order_abc123",                │
│    "razorpay_key": "rzp_test_xxx",                     │
│    "amount": "271.46",                                 │
│    "currency": "INR",                                  │
│    "order_id": 96                                      │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
         │
         ▼
   Open Razorpay Payment Modal
```

### Phase 2: Razorpay Payment

```
User completes payment on Razorpay
         │
         ▼
Razorpay returns:
  - razorpay_payment_id
  - razorpay_order_id
  - razorpay_signature
```

### Phase 3: Payment Verification

```
┌─────────────────────────────────────────────────────────┐
│  POST /api/order/v1/payment/verify/                     │
│  Request: {                                             │
│    "razorpay_payment_id": "pay_xyz789",                │
│    "razorpay_order_id": "order_abc123",                │
│    "razorpay_signature": "signature_hash"              │
│  }                                                      │
│  Response: {                                            │
│    "success": true,                                    │
│    "order_id": 96,                                     │
│    "message": "Payment verified"                       │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
         │
         ▼
   Order Created Successfully
   Cart Cleared
   Delivery Created (status: pending)
```

### Phase 4: Delivery Tracking

```
┌─────────────────────────────────────────────────────────┐
│  GET /api/delivery/v1/deliveries/?order={id}            │
│  Response: [{                                           │
│    "id": 1,                                            │
│    "order": 96,                                        │
│    "order_details": {                                  │
│      "id": 96,                                         │
│      "user": 1,                                        │
│      "total_amount": "271.46",                         │
│      "status": "processing"                            │
│    },                                                  │
│    "delivery_partner": 201,                            │
│    "delivery_partner_details": {                       │
│      "id": 201,                                        │
│      "username": "delivery_guy1",                      │
│      "email": "delivery1@example.com"                  │
│    },                                                  │
│    "delivery_partner_profile": {                       │
│      "id": 1,                                          │
│      "vehicle_type": "bike",                           │
│      "availability_status": "online"                   │
│    },                                                  │
│    "status": "assigned",                               │
│    "delivery_fee": "5.00",                             │
│    "assigned_at": "2025-12-17T10:00:00Z",             │
│    "picked_up_at": null,                               │
│    "delivered_at": null,                               │
│    "proof_of_delivery": null,                          │
│    "notes": "Deliver by 5 PM"                          │
│  }]                                                    │
└─────────────────────────────────────────────────────────┘
```

---

## Order Timeline UI

### Normal Order Timeline (6 Steps)

```
┌─────────────────────────────────────────────────────────┐
│  ✓ Order Placed                                         │
│  │  Wednesday, 22 January 2026                          │
│  │  10:30 AM                                            │
│  │                                                      │
│  ✓ Order Confirmed                                      │
│  │  Partner assigned                                    │
│  │                                                      │
│  ✓ Getting Packed                                       │
│  │  At pickup location                                  │
│  │                                                      │
│  ○ Picked Up                                            │
│  │  Order collected                                     │
│  │                                                      │
│  ○ Out for Delivery                                     │
│  │  On the way                                          │
│  │                                                      │
│  ○ Delivered                                            │
│     Completed                                           │
└─────────────────────────────────────────────────────────┘
```

### Refunded Order Timeline

```
┌─────────────────────────────────────────────────────────┐
│  ✓ Order Placed                                         │
│  │  Wednesday, 22 January 2026                          │
│  │  10:30 AM                                            │
│  │                                                      │
│  💱 Payment Refunded                                    │
│     Amount returned to your account                     │
└─────────────────────────────────────────────────────────┘
```

### Cancelled Order Timeline

```
┌─────────────────────────────────────────────────────────┐
│  ✓ Order Placed                                         │
│  │  Wednesday, 22 January 2026                          │
│  │  10:30 AM                                            │
│  │                                                      │
│  ✗ Order Cancelled                                      │
│     Wednesday, 22 January 2026                          │
└─────────────────────────────────────────────────────────┘
```

### Failed Delivery Timeline

```
┌─────────────────────────────────────────────────────────┐
│  ✓ Order Placed                                         │
│  │  Wednesday, 22 January 2026                          │
│  │  10:30 AM                                            │
│  │                                                      │
│  ✗ Delivery Failed                                      │
│     Unable to deliver                                   │
└─────────────────────────────────────────────────────────┘
```

---

## Status Colors & Icons

| Status | Color | Icon | Hex Code |
|--------|-------|------|----------|
| Pending | Yellow | `schedule_outlined` | `#FFB800` |
| Order Confirmed | Orange | `assignment_turned_in_outlined` | `#FF8555` |
| Getting Packed | Purple | `inventory_outlined` | `#9C27B0` |
| Picked Up | Blue | `inventory_2_outlined` | `#2196F3` |
| Out for Delivery | Cyan | `local_shipping_outlined` | `#4ECDC4` |
| Delivered | Green | `check_circle_outline` | `#25A63E` |
| Refunded | Orange | `currency_exchange_outlined` | `orange.shade700` |
| Cancelled | Red | `cancel_outlined` | `red.shade600` |
| Failed | Red | `cancel_outlined` | `red.shade600` |

---

## Delivery Partner Status Updates

### Update Flow (PATCH requests)

```dart
// Step 1: Partner arrives at pickup
PATCH /api/delivery/v1/deliveries/{id}/
{ "status": "at_pickup" }

// Step 2: Order picked up
PATCH /api/delivery/v1/deliveries/{id}/
{ "status": "picked_up" }
// Auto-sets: picked_up_at timestamp

// Step 3: Out for delivery
PATCH /api/delivery/v1/deliveries/{id}/
{ "status": "out_for_delivery" }

// Step 4a: Delivered successfully
PATCH /api/delivery/v1/deliveries/{id}/
{
  "status": "delivered",
  "proof_of_delivery": "https://example.com/proof/delivery_123.jpg",
  "notes": "Delivered to customer at door"
}
// Auto-sets: delivered_at timestamp

// Step 4b: Delivery failed
PATCH /api/delivery/v1/deliveries/{id}/
{
  "status": "failed",
  "notes": "Customer not available, multiple attempts made"
}
```

---

## Active vs Previous Orders

Orders are categorized into two tabs:

### Active Orders
- Delivery status is NOT `delivered`, `cancelled`, or `failed`
- Payment status is NOT `Refunded`

### Previous Orders (Completed)
- Delivery status is `delivered`, `cancelled`, or `failed`
- OR payment status is `Refunded`

```dart
bool get isActive {
  // Refunded orders are not active
  if (paymentStatus?.toLowerCase() == 'refunded') {
    return false;
  }
  return status != 'delivered' && status != 'cancelled' && status != 'failed';
}
```

---

## Data Models

### OrderEntity

```dart
class OrderEntity {
  final int id;
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final int itemCount;
  final DateTime? deliveryDate;
  final int? rating;
  final String? paymentStatus;
  final String? userName;
}
```

### DeliveryEntity (from API)

```json
{
  "id": 1,
  "order": 96,
  "order_details": {...},
  "delivery_partner": 201,
  "delivery_partner_details": {...},
  "delivery_partner_profile": {...},
  "status": "assigned",
  "delivery_fee": "5.00",
  "assigned_at": "2025-12-17T10:00:00Z",
  "picked_up_at": null,
  "delivered_at": null,
  "proof_of_delivery": null,
  "notes": "Deliver by 5 PM",
  "created_at": "2025-12-17T09:30:00Z",
  "updated_at": "2025-12-17T10:00:00Z"
}
```

---

## Files Structure

```
lib/features/profile/
├── application/
│   ├── providers/
│   │   └── order_provider.dart       # Order state management
│   └── states/
│       └── order_state.dart          # Order state classes
├── domain/
│   ├── entities/
│   │   ├── order.dart                # OrderEntity model
│   │   ├── order_item.dart           # OrderItemEntity model
│   │   └── order_rating.dart         # OrderRatingEntity model
│   └── repositories/
│       └── profile_repository.dart   # Repository interface
├── infrastructure/
│   ├── data_sources/
│   │   ├── local/
│   │   │   └── profile_local_ds.dart # Local cache
│   │   └── remote/
│   │       └── profile_api.dart      # API client
│   └── repositories/
│       └── profile_repository_impl.dart # Repository implementation
└── presentation/
    └── components/
        ├── my_orders_screen.dart     # Orders list UI
        ├── order_items_bottom_sheet.dart # Order items UI
        └── rate_order_bottom_sheet.dart  # Rating UI
```

---

## Debug Logs

Enable debug logs to trace order flow:

```
🌐 [ProfileApi] Fetching orders from: /api/order/v1/orders/
📥 [ProfileApi] Orders response: {...}
📊 [ProfileApi] Paginated response - count: 1, next: null
📦 [ProfileApi] Parsing 1 orders
📦 [OrderEntity] Parsing order id=96, status=assigned, payment_status=Paid
✅ [ProfileApi] Returning 1 orders
✅ [ProfileRepo] Returning 1 cached orders
🔄 [ProfileRepo] Refreshing orders in background
🎨 [UI] Order #96 - status: "assigned", paymentStatus: "Paid", statusInfo.label: "Order Confirmed", step: 1
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-22 | Initial documentation |
| 1.1 | 2026-01-22 | Added refunded status handling |
| 2.0 | 2026-01-22 | Updated delivery status flow to match new API |

---

## API Reference Links

- Delivery API: `/api/delivery/v1/`
- Order API: `/api/order/v1/`
- Payment API: `/api/order/v1/checkout/`, `/api/order/v1/payment/verify/`
