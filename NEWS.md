# tfautograph 0.2.0.9000

* Improved handling of `shape_invariants` supplied to `ag_while_opts`. A named list of user variable shapes can be passed directly now, without requiring users to manually specify shapes of internal loop tracking tensors.
* Deprecated `back_prop` arg in `ag_while_opts()`
* Move 'tensorflow' package from 'Imports' to 'Suggests' to avoid circular dependency.
* Added a `NEWS.md` file to track changes to the package.
