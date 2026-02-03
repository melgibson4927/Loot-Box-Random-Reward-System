(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-loot-box (err u102))
(define-constant err-invalid-reward (err u103))
(define-constant err-loot-box-not-available (err u104))
(define-constant err-reward-not-owned (err u105))
(define-constant err-insufficient-burn-points (err u106))
(define-constant err-invalid-burn-quantity (err u107))
(define-constant err-zero-quantity (err u108))
(define-constant err-invalid-fusion-recipe (err u110))
(define-constant err-insufficient-boxes-for-fusion (err u111))
(define-constant err-fusion-not-enabled (err u112))
(define-constant err-invalid-craft-cost (err u113))
(define-constant err-contract-paused (err u115))

(define-data-var loot-box-counter uint u0)
(define-data-var reward-counter uint u0)
(define-data-var total-boxes-opened uint u0)
(define-data-var total-rewards-burned uint u0)
(define-data-var total-fusions-completed uint u0)
(define-data-var contract-paused bool false)

(define-map loot-boxes
  { loot-box-id: uint }
  {
    name: (string-ascii 50),
    price: uint,
    available: bool,
    total-supply: uint,
    current-supply: uint
  }
)

(define-map rewards
  { reward-id: uint }
  {
    name: (string-ascii 50),
    rarity: uint,
    loot-box-id: uint,
    drop-rate: uint
  }
)

(define-map player-inventory
  { player: principal, reward-id: uint }
  { quantity: uint }
)

(define-map player-stats
  { player: principal }
  {
    boxes-opened: uint,
    total-spent: uint,
    rare-items: uint
  }
)

(define-map loot-box-purchases
  { player: principal, loot-box-id: uint }
  { quantity: uint }
)

(define-map player-burn-points
  { player: principal }
  { points: uint }
)

(define-map burn-rates
  { rarity: uint }
  { points: uint }
)

(define-map fusion-recipes
  { source-loot-box-id: uint }
  {
    target-loot-box-id: uint,
    required-quantity: uint,
    enabled: bool
  }
)

(define-map player-fusion-stats
  { player: principal }
  {
    total-fusions: uint,
    boxes-fused: uint
  }
)

(define-read-only (get-loot-box (loot-box-id uint))
  (map-get? loot-boxes { loot-box-id: loot-box-id })
)

(define-read-only (get-reward (reward-id uint))
  (map-get? rewards { reward-id: reward-id })
)

(define-read-only (get-player-inventory (player principal) (reward-id uint))
  (default-to 
    { quantity: u0 }
    (map-get? player-inventory { player: player, reward-id: reward-id })
  )
)

(define-read-only (get-player-stats (player principal))
  (default-to
    { boxes-opened: u0, total-spent: u0, rare-items: u0 }
    (map-get? player-stats { player: player })
  )
)

(define-read-only (get-total-boxes-opened)
  (var-get total-boxes-opened)
)

(define-read-only (get-loot-box-counter)
  (var-get loot-box-counter)
)

(define-read-only (get-reward-counter)
  (var-get reward-counter)
)

(define-read-only (get-player-burn-points (player principal))
  (default-to
    { points: u0 }
    (map-get? player-burn-points { player: player })
  )
)

(define-read-only (get-burn-rate (rarity uint))
  (default-to
    { points: u0 }
    (map-get? burn-rates { rarity: rarity })
  )
)

(define-read-only (get-total-rewards-burned)
  (var-get total-rewards-burned)
)

(define-read-only (get-fusion-recipe (source-loot-box-id uint))
  (map-get? fusion-recipes { source-loot-box-id: source-loot-box-id })
)

(define-read-only (get-player-fusion-stats (player principal))
  (default-to
    { total-fusions: u0, boxes-fused: u0 }
    (map-get? player-fusion-stats { player: player })
  )
)

(define-read-only (get-total-fusions-completed)
  (var-get total-fusions-completed)
)

(define-read-only (get-contract-paused)
  (var-get contract-paused)
)

(define-public (set-contract-paused (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused paused)
    (ok paused)
  )
)

(define-private (generate-pseudo-random (player principal) (nonce uint))
  (+ 
    (+ stacks-block-height nonce)
    (+ (var-get total-boxes-opened) (len (unwrap-panic (to-consensus-buff? player))))
  )
)

(define-private (get-random-number (max-value uint) (seed uint))
  (mod seed max-value)
)

(define-private (determine-reward (loot-box-id uint) (random-value uint))
  (let
    (
      (reward-list (filter-rewards-by-loot-box loot-box-id))
      (selected-reward (select-reward-by-rarity reward-list random-value))
    )
    selected-reward
  )
)

(define-private (filter-rewards-by-loot-box (loot-box-id uint))
  (list u1 u2 u3 u4 u5)
)

(define-private (select-reward-by-rarity (reward-list (list 10 uint)) (random-value uint))
  (let
    (
      (rarity-threshold (mod random-value u10000))
    )
    (if (<= rarity-threshold u100)
      u1
      (if (<= rarity-threshold u500)
        u2
        (if (<= rarity-threshold u1500)
          u3
          (if (<= rarity-threshold u3500)
            u4
            u5
          )
        )
      )
    )
  )
)

(define-private (update-player-stats (player principal) (box-price uint) (is-rare bool))
  (let
    (
      (current-stats (get-player-stats player))
      (new-boxes-opened (+ (get boxes-opened current-stats) u1))
      (new-total-spent (+ (get total-spent current-stats) box-price))
      (new-rare-items (if is-rare (+ (get rare-items current-stats) u1) (get rare-items current-stats)))
    )
    (map-set player-stats
      { player: player }
      {
        boxes-opened: new-boxes-opened,
        total-spent: new-total-spent,
        rare-items: new-rare-items
      }
    )
  )
)

(define-private (add-reward-to-inventory (player principal) (reward-id uint))
  (let
    (
      (current-inventory (get-player-inventory player reward-id))
      (new-quantity (+ (get quantity current-inventory) u1))
    )
    (map-set player-inventory
      { player: player, reward-id: reward-id }
      { quantity: new-quantity }
    )
  )
)

(define-public (create-loot-box (name (string-ascii 50)) (price uint) (total-supply uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (loot-box-id (+ (var-get loot-box-counter) u1))
      )
      (map-set loot-boxes
        { loot-box-id: loot-box-id }
        {
          name: name,
          price: price,
          available: true,
          total-supply: total-supply,
          current-supply: total-supply
        }
      )
      (var-set loot-box-counter loot-box-id)
      (ok loot-box-id)
    )
  )
)

(define-public (create-reward (name (string-ascii 50)) (rarity uint) (loot-box-id uint) (drop-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (reward-id (+ (var-get reward-counter) u1))
      )
      (map-set rewards
        { reward-id: reward-id }
        {
          name: name,
          rarity: rarity,
          loot-box-id: loot-box-id,
          drop-rate: drop-rate
        }
      )
      (var-set reward-counter reward-id)
      (ok reward-id)
    )
  )
)

(define-public (purchase-loot-box (loot-box-id uint))
  (let
    (
      (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
      (box-price (get price loot-box-data))
      (current-supply (get current-supply loot-box-data))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (get available loot-box-data) err-loot-box-not-available)
    (asserts! (> current-supply u0) err-loot-box-not-available)
    (try! (stx-transfer? box-price tx-sender contract-owner))
    (map-set loot-boxes
      { loot-box-id: loot-box-id }
      (merge loot-box-data { current-supply: (- current-supply u1) })
    )
    (let
      (
        (current-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: tx-sender, loot-box-id: loot-box-id }))))
      )
      (map-set loot-box-purchases
        { player: tx-sender, loot-box-id: loot-box-id }
        { quantity: (+ current-purchases u1) }
      )
    )
    (ok true)
  )
)

(define-public (open-loot-box (loot-box-id uint))
  (let
    (
      (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
      (player-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: tx-sender, loot-box-id: loot-box-id }))))
      (box-price (get price loot-box-data))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> player-purchases u0) err-insufficient-balance)
    (let
      (
        (random-seed (generate-pseudo-random tx-sender (var-get total-boxes-opened)))
        (random-number (get-random-number u10000 random-seed))
        (reward-id (determine-reward loot-box-id random-number))
        (reward-data (unwrap! (get-reward reward-id) err-invalid-reward))
        (is-rare (< (get rarity reward-data) u3))
      )
      (add-reward-to-inventory tx-sender reward-id)
      (update-player-stats tx-sender box-price is-rare)
      (map-set loot-box-purchases
        { player: tx-sender, loot-box-id: loot-box-id }
        { quantity: (- player-purchases u1) }
      )
      (var-set total-boxes-opened (+ (var-get total-boxes-opened) u1))
      (ok { reward-id: reward-id, reward-name: (get name reward-data), rarity: (get rarity reward-data) })
    )
  )
)

(define-public (transfer-reward (recipient principal) (reward-id uint) (quantity uint))
  (let
    (
      (sender-inventory (get-player-inventory tx-sender reward-id))
      (sender-quantity (get quantity sender-inventory))
      (recipient-inventory (get-player-inventory recipient reward-id))
      (recipient-quantity (get quantity recipient-inventory))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (>= sender-quantity quantity) err-reward-not-owned)
    (map-set player-inventory
      { player: tx-sender, reward-id: reward-id }
      { quantity: (- sender-quantity quantity) }
    )
    (map-set player-inventory
      { player: recipient, reward-id: reward-id }
      { quantity: (+ recipient-quantity quantity) }
    )
    (ok true)
  )
)

(define-public (toggle-loot-box-availability (loot-box-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
        (current-availability (get available loot-box-data))
      )
      (map-set loot-boxes
        { loot-box-id: loot-box-id }
        (merge loot-box-data { available: (not current-availability) })
      )
      (ok (not current-availability))
    )
  )
)

(define-public (update-loot-box-price (loot-box-id uint) (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
      )
      (map-set loot-boxes
        { loot-box-id: loot-box-id }
        (merge loot-box-data { price: new-price })
      )
      (ok true)
    )
  )
)

(define-public (restock-loot-box (loot-box-id uint) (additional-supply uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
        (current-supply (get current-supply loot-box-data))
        (total-supply (get total-supply loot-box-data))
      )
      (map-set loot-boxes
        { loot-box-id: loot-box-id }
        (merge loot-box-data { 
          current-supply: (+ current-supply additional-supply),
          total-supply: (+ total-supply additional-supply)
        })
      )
      (ok true)
    )
  )
)

(define-read-only (get-loot-box-rewards (loot-box-id uint))
  (list
    (map-get? rewards { reward-id: u1 })
    (map-get? rewards { reward-id: u2 })
    (map-get? rewards { reward-id: u3 })
    (map-get? rewards { reward-id: u4 })
    (map-get? rewards { reward-id: u5 })
  )
)

(define-read-only (get-player-total-inventory (player principal))
  (list
    (get-player-inventory player u1)
    (get-player-inventory player u2)
    (get-player-inventory player u3)
    (get-player-inventory player u4)
    (get-player-inventory player u5)
  )
)

(define-read-only (calculate-rarity-bonus (rarity uint))
  (if (is-eq rarity u1)
    u1000
    (if (is-eq rarity u2)
      u500
      (if (is-eq rarity u3)
        u200
        (if (is-eq rarity u4)
          u100
          u50
        )
      )
    )
  )
)

(define-read-only (get-drop-chance (reward-id uint))
  (let
    (
      (reward-data (unwrap! (get-reward reward-id) (err u404)))
      (rarity (get rarity reward-data))
    )
    (ok (calculate-rarity-bonus rarity))
  )
)

(define-public (batch-open-loot-boxes (loot-box-id uint) (quantity uint))
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (<= quantity u10) (err u109))
    (ok (fold batch-open-helper (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) { loot-box-id: loot-box-id, remaining: quantity, results: (list) }))
  )
)

(define-private (batch-open-helper (iteration uint) (data { loot-box-id: uint, remaining: uint, results: (list 10 { reward-id: uint, reward-name: (string-ascii 50), rarity: uint }) }))
  (if (is-eq (get remaining data) u0)
    data
    (let
      (
        (open-result (open-loot-box (get loot-box-id data)))
      )
      (match open-result
        success-data (merge data { 
          remaining: (- (get remaining data) u1),
          results: (unwrap-panic (as-max-len? (append (get results data) success-data) u10))
        })
        error-data data
      )
    )
  )
)

(define-public (emergency-withdraw)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (contract-balance (stx-get-balance (as-contract tx-sender)))
      )
      (if (> contract-balance u0)
        (as-contract (stx-transfer? contract-balance tx-sender contract-owner))
        (ok true)
      )
    )
  )
)

(define-public (initialize-default-content)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (create-loot-box "Bronze Box" u1000000 u1000))
    (try! (create-loot-box "Silver Box" u5000000 u500))
    (try! (create-loot-box "Gold Box" u10000000 u100))
    (try! (create-reward "Common Sword" u5 u1 u3500))
    (try! (create-reward "Rare Shield" u4 u1 u1000))
    (try! (create-reward "Epic Armor" u3 u2 u400))
    (try! (create-reward "Legendary Gem" u2 u2 u90))
    (try! (create-reward "Mythic Crown" u1 u3 u10))
    (try! (set-burn-rate u1 u100))
    (try! (set-burn-rate u2 u50))
    (try! (set-burn-rate u3 u25))
    (try! (set-burn-rate u4 u10))
    (try! (set-burn-rate u5 u5))
    (ok true)
  )
)

(define-public (set-burn-rate (rarity uint) (points uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set burn-rates
      { rarity: rarity }
      { points: points }
    )
    (ok true)
  )
)

(define-public (burn-reward (reward-id uint) (quantity uint))
  (let
    (
      (reward-data (unwrap! (get-reward reward-id) err-invalid-reward))
      (current-inventory (get-player-inventory tx-sender reward-id))
      (current-quantity (get quantity current-inventory))
      (burn-rate-data (get-burn-rate (get rarity reward-data)))
      (points-per-item (get points burn-rate-data))
      (total-burn-points (* points-per-item quantity))
      (current-burn-points (get-player-burn-points tx-sender))
      (current-points (get points current-burn-points))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> quantity u0) err-zero-quantity)
    (asserts! (>= current-quantity quantity) err-reward-not-owned)
    (asserts! (> points-per-item u0) err-invalid-burn-quantity)
    (map-set player-inventory
      { player: tx-sender, reward-id: reward-id }
      { quantity: (- current-quantity quantity) }
    )
    (map-set player-burn-points
      { player: tx-sender }
      { points: (+ current-points total-burn-points) }
    )
    (var-set total-rewards-burned (+ (var-get total-rewards-burned) quantity))
    (ok { burned-quantity: quantity, points-earned: total-burn-points })
  )
)

(define-public (spend-burn-points-on-loot-box (loot-box-id uint) (points-to-spend uint))
  (let
    (
      (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
      (current-burn-points (get-player-burn-points tx-sender))
      (current-points (get points current-burn-points))
      (box-price (get price loot-box-data))
      (required-points (/ box-price u1000))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (get available loot-box-data) err-loot-box-not-available)
    (asserts! (> (get current-supply loot-box-data) u0) err-loot-box-not-available)
    (asserts! (>= points-to-spend required-points) err-insufficient-burn-points)
    (asserts! (>= current-points points-to-spend) err-insufficient-burn-points)
    (map-set player-burn-points
      { player: tx-sender }
      { points: (- current-points points-to-spend) }
    )
    (map-set loot-boxes
      { loot-box-id: loot-box-id }
      (merge loot-box-data { current-supply: (- (get current-supply loot-box-data) u1) })
    )
    (let
      (
        (current-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: tx-sender, loot-box-id: loot-box-id }))))
      )
      (map-set loot-box-purchases
        { player: tx-sender, loot-box-id: loot-box-id }
        { quantity: (+ current-purchases u1) }
      )
    )
    (ok { points-spent: points-to-spend, loot-box-acquired: true })
  )
)

(define-read-only (calculate-burn-points (reward-id uint) (quantity uint))
  (let
    (
      (reward-data (unwrap! (get-reward reward-id) err-invalid-reward))
      (burn-rate-data (get-burn-rate (get rarity reward-data)))
      (points-per-item (get points burn-rate-data))
    )
    (ok (* points-per-item quantity))
  )
)

(define-read-only (calculate-loot-box-cost-in-points (loot-box-id uint))
  (let
    (
      (loot-box-data (unwrap! (get-loot-box loot-box-id) err-invalid-loot-box))
      (box-price (get price loot-box-data))
    )
    (ok (/ box-price u1000))
  )
)

(define-public (create-fusion-recipe (source-loot-box-id uint) (target-loot-box-id uint) (required-quantity uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (get-loot-box source-loot-box-id)) err-invalid-loot-box)
    (asserts! (is-some (get-loot-box target-loot-box-id)) err-invalid-loot-box)
    (map-set fusion-recipes
      { source-loot-box-id: source-loot-box-id }
      {
        target-loot-box-id: target-loot-box-id,
        required-quantity: required-quantity,
        enabled: true
      }
    )
    (ok true)
  )
)

(define-public (toggle-fusion-recipe (source-loot-box-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (recipe-data (unwrap! (get-fusion-recipe source-loot-box-id) err-invalid-fusion-recipe))
        (current-enabled (get enabled recipe-data))
      )
      (map-set fusion-recipes
        { source-loot-box-id: source-loot-box-id }
        (merge recipe-data { enabled: (not current-enabled) })
      )
      (ok (not current-enabled))
    )
  )
)

(define-public (fuse-loot-boxes (source-loot-box-id uint))
  (let
    (
      (recipe-data (unwrap! (get-fusion-recipe source-loot-box-id) err-invalid-fusion-recipe))
      (target-box-id (get target-loot-box-id recipe-data))
      (required-qty (get required-quantity recipe-data))
      (recipe-enabled (get enabled recipe-data))
      (player-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: tx-sender, loot-box-id: source-loot-box-id }))))
      (target-box-data (unwrap! (get-loot-box target-box-id) err-invalid-loot-box))
      (fusion-stats (get-player-fusion-stats tx-sender))
      (current-total-fusions (get total-fusions fusion-stats))
      (current-boxes-fused (get boxes-fused fusion-stats))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! recipe-enabled err-fusion-not-enabled)
    (asserts! (>= player-purchases required-qty) err-insufficient-boxes-for-fusion)
    (asserts! (> (get current-supply target-box-data) u0) err-loot-box-not-available)
    (map-set loot-box-purchases
      { player: tx-sender, loot-box-id: source-loot-box-id }
      { quantity: (- player-purchases required-qty) }
    )
    (let
      (
        (target-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: tx-sender, loot-box-id: target-box-id }))))
      )
      (map-set loot-box-purchases
        { player: tx-sender, loot-box-id: target-box-id }
        { quantity: (+ target-purchases u1) }
      )
    )
    (map-set loot-boxes
      { loot-box-id: target-box-id }
      (merge target-box-data { current-supply: (- (get current-supply target-box-data) u1) })
    )
    (map-set player-fusion-stats
      { player: tx-sender }
      {
        total-fusions: (+ current-total-fusions u1),
        boxes-fused: (+ current-boxes-fused required-qty)
      }
    )
    (var-set total-fusions-completed (+ (var-get total-fusions-completed) u1))
    (ok { fused-boxes: required-qty, received-box-id: target-box-id })
  )
)

(define-read-only (can-fuse (player principal) (source-loot-box-id uint))
  (let
    (
      (recipe-data (unwrap! (get-fusion-recipe source-loot-box-id) err-invalid-fusion-recipe))
      (required-qty (get required-quantity recipe-data))
      (recipe-enabled (get enabled recipe-data))
      (player-purchases (default-to u0 (get quantity (map-get? loot-box-purchases { player: player, loot-box-id: source-loot-box-id }))))
    )
    (ok (and recipe-enabled (>= player-purchases required-qty)))
  )
)

(define-public (initialize-fusion-recipes)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (create-fusion-recipe u1 u2 u3))
    (try! (create-fusion-recipe u2 u3 u3))
    (ok true)
  )
)

(define-map craft-costs
  { reward-id: uint }
  { points: uint }
)

(define-read-only (get-craft-cost (reward-id uint))
  (default-to
    { points: u0 }
    (map-get? craft-costs { reward-id: reward-id })
  )
)

(define-public (set-craft-cost (reward-id uint) (points uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set craft-costs
      { reward-id: reward-id }
      { points: points }
    )
    (ok true)
  )
)

(define-public (craft-reward-with-points (reward-id uint))
  (let
    (
      (reward-data (unwrap! (get-reward reward-id) err-invalid-reward))
      (cost-data (get-craft-cost reward-id))
      (cost (get points cost-data))
      (burn-points-data (get-player-burn-points tx-sender))
      (current-points (get points burn-points-data))
      (current-inventory (get-player-inventory tx-sender reward-id))
      (current-quantity (get quantity current-inventory))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> cost u0) err-invalid-craft-cost)
    (asserts! (>= current-points cost) err-insufficient-burn-points)
    (map-set player-burn-points
      { player: tx-sender }
      { points: (- current-points cost) }
    )
    (map-set player-inventory
      { player: tx-sender, reward-id: reward-id }
      { quantity: (+ current-quantity u1) }
    )
    (ok { reward-id: reward-id, points-spent: cost })
  )
)

;; --------------------------------------------------------------------------
;; MARKETPLACE FEATURE
;; --------------------------------------------------------------------------

(define-constant err-invalid-price (err u116))
(define-constant err-listing-not-found (err u117))
(define-constant err-insufficient-listing-quantity (err u118))
(define-constant err-cannot-buy-own-listing (err u119))

(define-map market-listings
  { seller: principal, reward-id: uint }
  { price: uint, quantity: uint }
)

(define-read-only (get-listing (seller principal) (reward-id uint))
  (map-get? market-listings { seller: seller, reward-id: reward-id })
)

(define-public (list-reward (reward-id uint) (price uint) (quantity uint))
  (let
    (
      (listing-key { seller: tx-sender, reward-id: reward-id })
      (current-listing (default-to { price: u0, quantity: u0 } (map-get? market-listings listing-key)))
      (new-quantity (+ (get quantity current-listing) quantity))
    )
    (asserts! (> price u0) err-invalid-price)
    (asserts! (> quantity u0) err-zero-quantity)
    (try! (transfer-reward (as-contract tx-sender) reward-id quantity))
    (map-set market-listings
      listing-key
      { price: price, quantity: new-quantity }
    )
    (ok true)
  )
)

(define-public (cancel-listing (reward-id uint))
  (let
    (
      (listing-key { seller: tx-sender, reward-id: reward-id })
      (listing (unwrap! (map-get? market-listings listing-key) err-listing-not-found))
      (refund-quantity (get quantity listing))
      (seller tx-sender)
    )
    (map-delete market-listings listing-key)
    (as-contract (transfer-reward seller reward-id refund-quantity))
  )
)

(define-public (buy-reward (seller principal) (reward-id uint) (quantity uint))
  (let
    (
      (listing-key { seller: seller, reward-id: reward-id })
      (listing (unwrap! (map-get? market-listings listing-key) err-listing-not-found))
      (listing-price (get price listing))
      (listing-quantity (get quantity listing))
      (total-cost (* listing-price quantity))
      (buyer tx-sender)
    )
    (asserts! (not (is-eq buyer seller)) err-cannot-buy-own-listing)
    (asserts! (<= quantity listing-quantity) err-insufficient-listing-quantity)
    (try! (stx-transfer? total-cost buyer seller))
    (try! (as-contract (transfer-reward buyer reward-id quantity)))
    (if (is-eq quantity listing-quantity)
      (map-delete market-listings listing-key)
      (map-set market-listings
        listing-key
        { price: listing-price, quantity: (- listing-quantity quantity) }
      )
    )
    (ok true)
  )
)
