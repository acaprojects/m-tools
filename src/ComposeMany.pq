/**
 * Perform a right-to-left composition across a list of functions.
 *
 * :: ((y -> z), (x -> y), ..., (a -> b)) -> a -> z
 */
Foldr(Compose, Id)
