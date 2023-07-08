# BQN Ledger

This is an attempt at implementing a [ledger-alike](https://ledger-cli.org/) in BQN. 

## References
The parser uses the same basic ideas as this implementation in K shown by John Earnest on [nsl.com](http://nsl.com/k/kparse/pcomb.k), especially the monadic return format.

The balance report uses an incomplete implementation of an graph structure along Aaron Hsu's [Tree Wrangling the APL Way](https://www.dyalog.com/uploads/conference/dyalog18/presentations/U19_Tree_Wrangling_the_APL_Way.pdf) to represent hierarchies of accounts.