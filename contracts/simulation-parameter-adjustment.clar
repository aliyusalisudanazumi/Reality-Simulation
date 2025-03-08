;; Simulation Parameter Adjustment Contract

(define-map simulations
  { id: uint }
  {
    name: (string-utf8 64),
    creator: principal,
    active: bool,
    creation-time: uint
  }
)

(define-map simulation-parameters
  { simulation-id: uint, parameter-id: (string-utf8 32) }
  {
    value: int,
    last-modified: uint,
    modifier: principal
  }
)

(define-data-var next-simulation-id uint u0)

(define-public (create-simulation (name (string-utf8 64)))
  (let
    ((new-id (var-get next-simulation-id)))
    (var-set next-simulation-id (+ new-id u1))
    (ok (map-set simulations
      { id: new-id }
      {
        name: name,
        creator: tx-sender,
        active: true,
        creation-time: block-height
      }
    ))
  )
)

(define-public (set-parameter (simulation-id uint) (parameter-id (string-utf8 32)) (value int))
  (match (map-get? simulations { id: simulation-id })
    simulation
      (begin
        (asserts! (is-eq tx-sender (get creator simulation)) (err u403))
        (asserts! (get active simulation) (err u400))
        (ok (map-set simulation-parameters
          { simulation-id: simulation-id, parameter-id: parameter-id }
          {
            value: value,
            last-modified: block-height,
            modifier: tx-sender
          }
        )))
    (err u404)
  )
)

(define-public (deactivate-simulation (simulation-id uint))
  (match (map-get? simulations { id: simulation-id })
    simulation
      (begin
        (asserts! (is-eq tx-sender (get creator simulation)) (err u403))
        (ok (map-set simulations
          { id: simulation-id }
          (merge simulation { active: false })
        )))
    (err u404)
  )
)

(define-read-only (get-simulation (simulation-id uint))
  (map-get? simulations { id: simulation-id })
)

(define-read-only (get-parameter (simulation-id uint) (parameter-id (string-utf8 32)))
  (map-get? simulation-parameters { simulation-id: simulation-id, parameter-id: parameter-id })
)

