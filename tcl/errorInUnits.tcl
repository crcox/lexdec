proc errorInUnits {fhandle {groups 0}} {
  # This first part is added to mirror functionality of built-in
  # openNetOutputFile behavior of writing data for groups flagged as
  # WRITE_OUTPUT.
  if {$groups==0} {
    set groups [list]
    for {set i 0} {$i<[getObj numGroups]} {incr i} {
      set name [getObj group($i).name]
      set type [getObj group($i).type]
      set fullHex [format "%08s" [string range $type 2 end]]
      binary scan [binary format H8 $fullHex] B32 fullBin
      set WriteFlag [string index $fullBin end-29]
      if {$WriteFlag==1} {
        lappend groups $name
      }
    }
  }
  set crit [getObj testGroupCrit]
  set iUpdate [getObj totalUpdates]
  set nExample [getObj testingSet.numExamples]
  set testSetName [getObj testingSet.name]
  foreach GROUP $groups {
    set iGroup [getObj $GROUP.num]
    # CHECK GROUP TYPE
    # This operation only makes sense for output groups.
    # Group type is encoded in a hex encoding of a binary mask.
    # The last character in the hex string encodes the ``fixed''
    # group type, BIAS 0000 INPUT 0010 OUTPUT 0100 ELMAN 1000.
    # Hex codes of 4 (0100) or 5 (0101) are possible for OUTPUT
    # layers. Also check and warn if the TARGET_HIST and OUPUT_HIST
    # flags are not set on this group.
    set hex [string index [getObj $GROUP.type] end]
    if { $hex==4 || $hex==5 } {
      set hex [string index [getObj $GROUP.type] end-4]
      if { $hex!=3 && $hex!=7 && $hex=="B" && $hex!="F" } {
        puts [format "WARNING: USE_OUTPUT_HIST or USE_TARGET_HIST not set on group %s (%d)." $GROUP $iGroup]
      }
      set nUnit [getObj $GROUP.numUnits]
      for {set iExample 0} {$iExample < $nExample} {incr iExample} {
        doExample $iExample -set $testSetName -test
        set exampleName [getObj currentExample.name]
        set exampleNum [getObj currentExample.num]
        set exampleNameSplit [split $exampleName "_"]
        set word [lindex $exampleNameSplit 0]
        set from [lindex $exampleNameSplit 1]
        set to [lindex $exampleNameSplit 2]
        set key [join [list $GROUP $from $to] "_"]
        set errlist($key) [list]

        set nTick [getObj ticksOnExample]
        set lastTick [expr $nTick - 1]
        set mTick [getObj historyLength]
        set startPos [getObj exampleHistoryStart]

        # Ticks without targets can be skipped.
        # NB: In continuous net, tick 0 is a setup tick.
        # Tick 1 is the first that reflects ecample file.
        set actPos [expr ($lastTick + $startPos) % $mTick]
        set target [getObj $GROUP.unit(1).targetHistory($actPos)]
        if { $target=="-" } {
          continue
        }
#        set cumerr 0
        set misses 0
        set falsealarms 0
        set hits 0
        set correctrejections 0
        set errors 0
        for {set iUnit 0} {$iUnit < $nUnit} {incr iUnit} {
          set target [getObj $GROUP.unit($iUnit).targetHistory($actPos)]
          set output [getObj $GROUP.unit($iUnit).outputHistory($actPos)]
          set diff [expr {$target - $output}]
          set err [expr abs($diff)]
#          set cumerr [expr {$cumerr + $err}]
          if { $err > $crit } {
            incr errors 1
            if { $target == 1 } {
              incr misses 1
            } else {
              incr falsealarms 1
            }
          } else {
            if { $target == 1 } {
              incr hits 1
            } else {
              incr correctrejections 1
            }

          }
        }
        lappend errlist($key) $errors

#        set errFinal [expr $cumerr / $nUnit]
        set lineOfData [format "%d,%d,%s,%d,%s,%s,%s,%d,%d,%d,%d" $iUpdate $iGroup $GROUP $exampleNum $word $from $to $misses $falsealarms $hits $correctrejections]
        puts $fhandle $lineOfData
      }
    } else {
      puts [format "Group %s (%d) is not of type OUTPUT. Skipping..." $GROUP $iGroup]
    }
  }
  return [array get errlist]
}
