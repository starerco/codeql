import cpp
import semmle.code.cpp.rangeanalysis.RangeSSA

/**
 * Holds if `guard` won't return the value `polarity` when either
 * operand is NaN.
 */
predicate nanExcludingComparison(ComparisonOperation guard, boolean polarity) {
  polarity = true and
  (
    guard instanceof LTExpr or
    guard instanceof LEExpr or
    guard instanceof GTExpr or
    guard instanceof GEExpr or
    guard instanceof EQExpr
  )
  or
  polarity = false and
  guard instanceof NEExpr
}

/**
 * Holds if `v` is a use of an SSA definition in `def` which cannot be NaN,
 * by virtue of the guard in `def`.
 */
private predicate excludesNan(RangeSsaDefinition def, VariableAccess v) {
  exists(VariableAccess inCond, ComparisonOperation guard, boolean branch, LocalScopeVariable lsv |
    def.isGuardPhi(inCond, guard, branch) and
    inCond.getTarget() = lsv and
    v = def.getAUse(lsv) and
    guard.getAnOperand() = inCond and
    nanExcludingComparison(guard, branch)
  )
}

/**
 * A variable access which cannot be NaN.
 */
class NonNanVariableAccess extends VariableAccess {
  NonNanVariableAccess() { excludesNan(_, this) }
}
