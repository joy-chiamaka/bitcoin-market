;; BitcoinMarket: Decentralized Marketplace for Stacks Blockchain
;; A secure, decentralized marketplace built on Stacks, enabling direct sales,
;; auctions, and brand verification with Bitcoin settlement security.
;;

;; Constants & Error Codes
(define-constant contract-owner tx-sender)

;; Access control errors
(define-constant err-owner-only (err u100))
(define-constant err-not-brand-owner (err u101))

;; Marketplace errors
(define-constant err-invalid-price (err u102))
(define-constant err-listing-not-found (err u103))
(define-constant err-insufficient-funds (err u104))

;; Auction errors
(define-constant err-auction-ended (err u105))
(define-constant err-bid-too-low (err u106))
(define-constant err-no-active-auction (err u107))
(define-constant err-invalid-duration (err u108))

;; Review errors
(define-constant err-invalid-rating (err u109))

;; Data Variables
;; Platform fee in basis points (2.5%)
(define-data-var platform-fee uint u25)

;; Product ID counter
(define-data-var product-counter uint u0)

;; Data Maps
;; Brand registry - maps brand principal to their profile data
(define-map Brands
  principal
  {
    name: (string-ascii 50),
    verified: bool,
    created-at: uint,
  }
)

;; Product listings - maps product ID to product details
(define-map Products
  uint
  {
    brand: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    price: uint,
    available: bool,
    created-at: uint,
    is-auction: bool,
  }
)

;; Auction data - maps product ID to auction details
(define-map Auctions
  uint
  {
    end-block: uint,
    min-price: uint,
    highest-bid: uint,
    highest-bidder: (optional principal),
    is-active: bool,
  }
)

;; Product reviews - maps product ID and reviewer to review data
(define-map Reviews
  {
    product-id: uint,
    reviewer: principal,
  }
  {
    rating: uint,
    comment: (string-ascii 200),
    timestamp: uint,
  }
)

;; Brand Management Functions

;; Register a new brand in the marketplace
(define-public (register-brand (name (string-ascii 50)))
  (let ((brand-data {
      name: name,
      verified: false,
      created-at: stacks-block-height,
    }))
    (ok (map-set Brands tx-sender brand-data))
  )
)

;; Verify a brand (owner only function)
(define-public (verify-brand (brand principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? Brands brand)) err-not-brand-owner)
    (let ((brand-data (unwrap! (map-get? Brands brand) err-not-brand-owner)))
      (ok (map-set Brands brand (merge brand-data { verified: true })))
    )
  )
)

;; Direct Sale Functions

;; List a new product for direct sale
(define-public (list-product
    (name (string-ascii 100))
    (description (string-ascii 500))
    (price uint)
  )
  (let (
      (brand (unwrap! (map-get? Brands tx-sender) err-not-brand-owner))
      (product-id (+ (var-get product-counter) u1))
    )
    (asserts! (> price u0) err-invalid-price)
    (asserts! (> (len name) u0) err-invalid-price)
    (asserts! (> (len description) u0) err-invalid-price)
    (var-set product-counter product-id)
    (ok (map-set Products product-id {
      brand: tx-sender,
      name: name,
      description: description,
      price: price,
      available: true,
      created-at: stacks-block-height,
      is-auction: false,
    }))
  )
)

;; Purchase a product (direct sale)
(define-public (purchase-product (product-id uint))
  (let (
      (product (unwrap! (map-get? Products product-id) err-listing-not-found))
      (price (get price product))
      (brand (get brand product))
      (fee (/ (* price (var-get platform-fee)) u1000))
    )
    (if (and
        (get available product)
        (not (get is-auction product))
        (>= (stx-get-balance tx-sender) price)
      )
      (begin
        (try! (stx-transfer? fee tx-sender contract-owner))
        (try! (stx-transfer? (- price fee) tx-sender brand))
        (map-set Products product-id (merge product { available: false }))
        (ok true)
      )
      err-insufficient-funds
    )
  )
)

;; Auction Functions

;; Create an auction for a new product
(define-public (create-auction
    (name (string-ascii 100))
    (description (string-ascii 500))
    (min-price uint)
    (duration uint)
  )
  (let (
      (brand (unwrap! (map-get? Brands tx-sender) err-not-brand-owner))
      (product-id (+ (var-get product-counter) u1))
      (end-block (+ stacks-block-height duration))
    )
    (asserts! (>= duration u10) err-invalid-duration)
    (asserts! (> min-price u0) err-invalid-price)
    (asserts! (> (len name) u0) err-invalid-price)
    (asserts! (> (len description) u0) err-invalid-price)
    (var-set product-counter product-id)
    (map-set Products product-id {
      brand: tx-sender,
      name: name,
      description: description,
      price: min-price,
      available: true,
      created-at: stacks-block-height,
      is-auction: true,
    })
    (ok (map-set Auctions product-id {
      end-block: end-block,
      min-price: min-price,
      highest-bid: u0,
      highest-bidder: none,
      is-active: true,
    }))
  )
)

;; Place a bid on an auction
(define-public (place-bid
    (product-id uint)
    (bid-amount uint)
  )
  (let (
      (product (unwrap! (map-get? Products product-id) err-listing-not-found))
      (auction (unwrap! (map-get? Auctions product-id) err-no-active-auction))
    )
    (asserts! (get is-active auction) err-auction-ended)
    (asserts! (<= stacks-block-height (get end-block auction)) err-auction-ended)
    (asserts! (>= bid-amount (get min-price auction)) err-bid-too-low)
    (asserts! (> bid-amount (get highest-bid auction)) err-bid-too-low)
    (if (>= (stx-get-balance tx-sender) bid-amount)
      (begin
        ;; Return funds to previous bidder if exists
        (match (get highest-bidder auction)
          prev-bidder (try! (stx-transfer? (get highest-bid auction) contract-owner prev-bidder))
          true
        )
        ;; Accept new bid
        (try! (stx-transfer? bid-amount tx-sender contract-owner))
        (ok (map-set Auctions product-id
          (merge auction {
            highest-bid: bid-amount,
            highest-bidder: (some tx-sender),
          })
        ))
      )
      err-insufficient-funds
    )
  )
)