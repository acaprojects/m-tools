/**
 * Provide a simplified method for programmatically contructing table from
 * relationships between columns. Accepts a list of lists of the structure:
 *
 *     {<column name>, <column generator>, <type>}
 *
 * The chain may then be fed a table containing at least one column as a
 * seed.
 *
 * :: (Table a, Record b) => [(Text, b -> c, Type)] -> a -> a
 */
Compose(ChainOperations, Map(Cons(Table.AddColumn)))
