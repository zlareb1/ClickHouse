ATTACH VIEW _ UUID '3a48ecce-120b-43af-89cf-e526705e679d'
(
    `val` UInt8,
    `is_zero` UInt8
)
AS SELECT
    val,
    val = 0 AS is_zero
FROM default.t
