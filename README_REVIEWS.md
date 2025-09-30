# Reviews Feature

## API Contracts (Client Repository)

- getReviewSummary(productId) → ReviewSummary { average, totalCount, countsByStar }
- listReviews(productId, { page, pageSize, starFilters, withPhotosOnly, sort }) → List<Review>
- createReview(Review)
- updateReview(Review)
- voteReviewHelpful({ productId, reviewId, userId, helpful })
- reportReview({ productId, reviewId })

## Models

- Review { id, productId, userId, authorDisplay, rating, title?, body, images[], createdAt, updatedAt?, helpfulVotesByUser, reported, attributes? }
- ReviewImage { url, width?, height? }
- HelpfulVote { reviewId, userId, helpful }
- ReviewSummary { productId, average, totalCount, countsByStar }

## Image Constraints

- Max images per review: 6 (configurable in ReviewsRepository)
- Allowed types: JPEG/PNG/WEBP (enforced client-side via picker; demo accepts any)
- Suggested max size: 5 MB per image (not enforced in demo)
- Storage/CDN: demo uses placeholder URLs; integrate Firebase Storage or your CDN

## Moderation

- Basic reporting is supported via reportReview; server-side queueing recommended

## Analytics Events (suggested)

- reviews_card_viewed { productId }
- reviews_view_all_clicked { productId }
- review_composer_opened { productId }
- review_submitted { productId, rating, imagesCount }
- review_helpful_toggled { productId, reviewId, helpful }
- review_reported { productId, reviewId }

## Tests

- Unit: models serialization, reviews repository flows
- Widgets: ProductReviewsCard renders, navigation to ReviewsPage and Composer, helpful/report toggles
- Goldens: Card states (light/dark, LTR/RTL), review tile, filters bar


