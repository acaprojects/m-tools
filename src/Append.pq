/**
 * Add a single element to the tail of a list and return a new list
 * containing the merged result.
 *
 * :: a -> [a] -> [a]
 */
(a as any) =>
    (b as list) =>
        b & Of(a)
