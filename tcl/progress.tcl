proc progress {cur tot} {
    # if you don't want to redraw all the time, uncomment and change ferquency
    #if {$cur % ($tot/300)} { return }
    # set to total width of progress bar
    set total 70
    set half [expr {$total/2}]
    set percent [expr {100.*$cur/$tot}]
    set val (\ [format "%6.2f%%" $percent]\ )
    set str "\r|[string repeat = [
                expr {round($percent*$total/100)}]][
                        string repeat { } [expr {$total-round($percent*$total/100)}]]|"
    set str "[string range $str 0 $half]$val[string range $str [expr {$half+[string length $val]-1}] end]"
    puts -nonewline stderr $str
}
