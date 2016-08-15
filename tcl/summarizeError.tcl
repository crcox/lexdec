proc summarizeError {errorSerial {threshold 0}} {
  array set errorArray $errorSerial
  set nExample [getObj testingSet.numExamples]
  set m [array size errorArray]
  set errorSummary(any) 0
  set errorSummary(all) 0
  foreach {group errorList} [array get errorArray] {
    if {![info exists errCounts]} {
      set errCounts [list]
      foreach err $errorList {lappend errCounts 0}
    }
    set errorSummary($group) 0
    set index -1
    foreach err $errorList count $errCounts {
      incr index
      if { $err > $threshold } {
        incr errorSummary($group) 1
        lset errCounts $index [incr count]
      }
    }
  }
  set anyErr [lmap c $errCounts {expr $c > 0}]
  set allErr [lmap c $errCounts {expr $c == $m}]
  foreach any $anyErr all $allErr {
    incr errorSummary(any) $any
    incr errorSummary(all) $all
  }
  foreach {group err} [array get errorSummary] {
    lappend errorSummary($group) [expr $err / double($nExample)]
    puts [format "%12s: %d (%.3f)" $group $err [expr $err / double($nExample)]]
  }
  return [array get errorSummary]
}
