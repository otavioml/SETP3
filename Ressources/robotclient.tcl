#!/usr/bin/wish8.6
set sock [socket 127.0.0.1 4242]

proc ShowWindow {w} {
    pack [frame $w.f] -side top
    pack [scale $w.f.l -from 100 -to -100 -showvalue 1 -resolution 1 \
    -command "Power L"] -side left
    pack [scale $w.f.r -from 100 -to -100 -showvalue 1 -resolution 1\
    -command "Power R"] -side right
    pack [frame $w.f2] -side top
    pack [button $w.f2.b -text Lire -command "LireCapteursLigne $w.f2.b"] -side left
    for {set i 0} {$i<4} {incr i} {
        pack [label $w.f2.b$i -text $i] -side left
    }
    pack [frame $w.f3] -side top
    pack [button $w.f3.b -text Lire -command "LireUS $w.f3.l"] -side left
    pack [label $w.f3.l -text 255] -side left
}

proc Power {LR v} {
    global sock
    puts $sock "$LR $v"
    flush $sock
}

proc LireCapteursLigne {w} {
    global sock
    puts $sock "LIGHT"
    flush $sock
    set etats [gets $sock]
    for {set i 0} {$i<4} {incr i} {
        if {[lindex $etats $i]} {
            $w$i configure -fg green
        } else {
            $w$i configure -fg red
        }
    }
}

proc LireUS {w} {
    global sock
    puts $sock "US"
    flush $sock
    set dist [gets $sock]
    $w configure -text $dist
}
ShowWindow ""

