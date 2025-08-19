(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-loot-box (err u102))
(define-constant err-invalid-reward (err u103))
(define-constant err-loot-box-not-available (err u104))
(define-constant err-reward-not-owned (err u105))

(define-data-var loot-box-counter uint u0)
(define-data-var reward-counter uint u0)
(define-data-var total-boxes-opened uint u0)

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
    (asserts! (<= quantity u10) (err u106))
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
    (ok true)
  )
)
