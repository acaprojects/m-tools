/**
 * Perform a left-to-right composition across a list of functions.
 *
 * :: ((a -> b), (b -> c), ..., (y -> z)) -> a -> z
 */
Foldl(Flip(Compose), Id)
