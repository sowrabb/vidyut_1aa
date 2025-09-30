# Firebase Firestore Schema (Vidyut)

This document outlines the suggested Firestore schema based on current app models. Field names mirror existing `toJson()` keys where applicable.

## Conventions
- Timestamps use Firestore `timestamp` type: `created_at`, `updated_at`.
- Document IDs use ULIDs/UUIDs unless derived from Auth UID.
- Collections are in lowercase, snake_case.

## Collections

### users (Auth-linked)
- id (doc id): string (Auth UID)
- name: string
- email: string
- phone: string
- role: enum [admin, seller, buyer, marketing, support, ops]
- status: enum [active, pending, suspended]
- plan: enum [free, plus, pro, enterprise]
- is_seller: bool
- location: string
- industry: string
- materials: string[]
- seller_profile: map|null (embedded snapshot for quick access)
- created_at: timestamp
- last_active: timestamp

Indexes:
- Composite: role asc, status asc
- Single: email, phone

### seller_profiles
- id (doc id): string (same as user id or generated)
- company_name: string
- gst_number: string
- address: string
- city: string
- state: string
- pincode: string
- phone: string
- email: string
- website: string
- description: string
- categories: string[]
- materials: string[]
- logo_url: string
- is_verified: bool
- created_at: timestamp
- updated_at: timestamp

Indexes:
- city, state
- is_verified
- array-contains-any: categories, materials

### products
- id (doc id): string
- seller_id: string (ref users/{uid})
- title: string
- brand: string
- subtitle: string
- category: string
- description: string
- images: string[] (URLs; Firebase Storage recommended)
- price: number
- moq: number
- gst_rate: number
- materials: string[]
- custom_values: map<string, any>
- status: enum [active, draft, archived, pending, inactive]
- rating: number
- created_at: timestamp
- updated_at: timestamp
- metrics: map { view_count: number, order_count: number } (optional)

Indexes:
- status
- category
- seller_id + status
- array-contains-any: materials
- Composite: category asc, price asc

### leads
- id (doc id): string
- title: string
- industry: string
- materials: string[]
- city: string
- state: string
- qty: number
- turnover_cr: number
- need_by: timestamp
- status: string
- about: string
- created_by: string (users/{uid})
- created_at: timestamp
- updated_at: timestamp

Indexes:
- state, city
- array-contains-any: materials
- industry
- Composite: state asc, industry asc

### conversations
- id (doc id): string
- title: string
- subtitle: string
- is_pinned: bool
- is_support: bool
- participants: string[] (user ids)
- created_at: timestamp
- updated_at: timestamp

Subcollection: conversations/{id}/messages
- id (doc id): string
- sender_id: string (users/{uid})
- text: string
- attachments: string[] (URLs)
- created_at: timestamp
- read_by: string[] (user ids)

Indexes:
- participants array-contains
- messages.created_at

### categories
- id (doc id): string
- name: string
- description: string|null
- parent_id: string|null (categories/{id})
- sort_order: number
- is_active: bool
- created_at: timestamp

Indexes:
- is_active
- parent_id + sort_order

### hero_sections
- id (doc id): string
- title: string
- subtitle: string
- image_path: string
- is_active: bool
- priority: number
- created_at: timestamp
- updated_at: timestamp

Indexes:
- is_active
- priority

### billing
Collection group split into two top-level collections for simplicity.

payments
- id (doc id): string
- user_id: string
- user_name: string
- user_email: string
- amount: number
- currency: string [inr]
- status: enum [pending, completed, failed, refunded]
- method: enum [card, upi, netbanking, wallet]
- transaction_id: string
- failure_reason: string|null
- created_at: timestamp
- processed_at: timestamp|null

invoices
- id (doc id): string
- user_id: string
- user_name: string
- user_email: string
- invoice_number: string
- issue_date: timestamp
- due_date: timestamp
- subtotal: number
- tax_amount: number
- total_amount: number
- currency: string
- status: enum [draft, sent, paid, overdue, pending]
- items: array<map{ description, quantity, unit_price, total_price, plan_id }>
- taxes: array<map{ type, name, rate, amount }>

Indexes:
- payments.status
- invoices.status
- invoices.invoice_number

### notification_templates
- id (doc id): string
- name: string
- channel: enum [email, push, inApp, sms]
- title: string
- body: string
- created_at: timestamp

Indexes:
- channel

### power_generators
- id (doc id): string
- name: string
- type: string
- capacity: string
- location: string
- logo: string
- established: string
- founder: string
- ceo: string
- ceo_photo: string
- headquarters: string
- phone: string
- email: string
- website: string
- description: string
- total_plants: number
- employees: string
- revenue: string
- posts: array<map>

Indexes:
- type
- location

## Storage (Firebase Storage)
- buckets/products/{productId}/{imageId}.jpg
- buckets/users/{uid}/logo.png
- buckets/ads/{adId}/*.jpg

Rules should restrict write access to owners and validate MIME types and sizes.

## Cloud Functions (suggested)
- On product create/update: maintain metrics, denormalize seller snapshot.
- On user role change: update role-based claims.
