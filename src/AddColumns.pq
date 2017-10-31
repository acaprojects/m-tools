/**
 * Provide a simplified method for programmatically contructing table from
 * relationships between columns. Accept a list of lists of the structure:
 *
 *     {<column name>, <column generator>, <type>}
 *
 * The chain may then be fed a table containing at least on column as a
 * seed.
 *
 * :: Table a => a -> [b] -> a
 */
Compose(ChainOperations, Map(Prepend(Table.AddColumn)))
