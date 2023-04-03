#!/usr/bin/wish8.6
set PI 3.1415926535897931
set PI_2 [expr $PI/2]
set PI_4 [expr $PI/4]
set _2_PI [expr 2*$PI]
# 1 pixel = 1 cm
set T(piste) [list 50 150 55 200 50 200 400 205 395 200 400 305]
# largeur robot
set T(wrobot) 16 
# offset de chaque capteur p.r. largeur robot
set T(offsetsensors) [list 3 7 9 13] 
# longueur robot
set T(lrobot) 25 
#position initiale
set T(reset) [list 50 160 [expr -(3*$PI_4-0.2)]]
# (x,y,a) point central avant et angle radian p.r. verticale
set initialpos [list 55 200 $PI_4] 
set T(leftmotor) 0
set T(rightmotor) 0
set T(sensors) [list red red red red]
set T(sensorsint) [list 0 0 0 0]
# cm par tick at full pow
set T(cm_per_tick) 0.5
# portée ultrason
set T(porteeUS) 100.0
set T(angleUS) [expr $PI/8.0]
set T(lmotor) 0
set T(rmotor) 0
set T(Led) black
 #----------------------------------------------------------------------
 #
 # RotateItem -- Rotates a canvas item any angle about an arbitrary point.
 # Works by rotating the coordinates of the object. Thus it works with:
 #  o polygon
 #  o line
 # It DOES NOT work correctly with:
 #  o rectangle
 #  o oval and arcs
 #  o text
 # 
 # Parameters:
 #       w - Path name of the canvas
 #       tagOrId - what to rotate -- may be composite items
 #       Ox, Oy - origin to rotate around
 #       angle - radian counter-clockwise to rotate by
 #
 # Results:
 #       Returns nothing
 #
 # Side effects:
 #       Rotates a canvas item by ANGLE degrees clockwise
 #
 #----------------------------------------------------------------------
 
proc RotateItem {w tagOrId Ox Oy angle} {
#    set angle [expr {$angle * atan(1) * 4 / 180.0}] ;# Radians
    set angle [expr -$angle]
    foreach id [$w find withtag $tagOrId] {     ;# Do each component separately
        set xy {}
        foreach {x y} [$w coords $id] {
            # rotates vector (Ox,Oy)->(x,y) by angle clockwise

            set x [expr {$x - $Ox}]             ;# Shift to origin
            set y [expr {$y - $Oy}]

            set xx [expr {$x * cos($angle) - $y * sin($angle)}] ;# Rotate
            set yy [expr {$x * sin($angle) + $y * cos($angle)}]

            set xx [expr {$xx + $Ox}]           ;# Shift back
            set yy [expr {$yy + $Oy}]
            lappend xy $xx $yy
        }
        $w coords $id $xy
    }
}

proc MoveRobot {w lpow rpow} {
    global T
    global _2_PI
    global PI
    foreach {x y a} $T(pos) {}
    set left_cm [expr $T(cm_per_tick)*$lpow/100.0]
    set right_cm [expr $T(cm_per_tick)*$rpow/100.0]
    set dep [expr ($left_cm+$right_cm)/2.0]
    set da [expr ($right_cm-$left_cm)/$T(wrobot)]
    set a [expr fmod($a+$da,$_2_PI)]
    if {[expr $a<-$PI]} {
        set a [expr $a+$_2_PI]
    } elseif {[expr $a>$PI]} {
        set a [expr $a-$_2_PI]
    }
    set dx [expr $dep*cos($a)]
    set dy [expr -1*$dep*sin($a)]
    foreach id [$w find withtag robot] {
        $w move $id $dx $dy
    }
    set x [expr $x+$dx]
    set y [expr $y+$dy]
    
    set T(pos) [list $x $y $a]
    RotateItem $w robot $x $y $da
}

proc DrawRobot {w Ox Oy angle} {
    global T
    set T(pos) [list $Ox $Oy $angle]
    set r [$w create polygon [expr $Ox-$T(lrobot)] [expr $Oy-$T(wrobot)/2] \
        $Ox [expr $Oy-$T(wrobot)/2] \
        $Ox [expr $Oy+$T(wrobot)/2] \
        [expr $Ox-$T(lrobot)] [expr $Oy+$T(wrobot)/2] \
        -tags robot -outline lightblue -fill lightblue]
    #$w bind $r <ButtonPress-1> "set T(leftmotor) 0;set T(rightmotor) 0"
    $w create text [expr $Ox-$T(lrobot)/2] [expr $Oy-$T(wrobot)/2] -text $T(leftmotor) -justify center -tags {left robot}
    $w create text [expr $Ox-$T(lrobot)/2] [expr $Oy+$T(wrobot)/2] -text $T(rightmotor) -justify center -tags {right robot}
    set sensorid 0
    foreach offs $T(offsetsensors) {
        $w create polygon [expr $Ox-1] [expr $Oy-$T(wrobot)/2+$offs-1] \
            [expr $Ox-1] [expr $Oy-$T(wrobot)/2+$offs+1] \
            [expr $Ox+1] [expr $Oy-$T(wrobot)/2+$offs+1] \
            [expr $Ox+1] [expr $Oy-$T(wrobot)/2+$offs-1] \
            -tags [list robot robot[expr $sensorid]] -width 0 -fill [lindex $T(sensors) $sensorid]
        incr sensorid
    }
    $w create polygon [expr $Ox-$T(lrobot)-10] [expr $Oy-10] \
        [expr $Ox-$T(lrobot)-1] [expr $Oy-10] \
        [expr $Ox-$T(lrobot)-1] [expr $Oy+10] \
        [expr $Ox-$T(lrobot)-10] [expr $Oy+10] \
        -tags [list robot Led] -width 0 -fill $T(Led)
    RotateItem $w robot $Ox $Oy $angle
}

proc DrawLine {w} {
    global T
    foreach {x1 y1 x2 y2} $T(piste) {
        $w create rectangle $x1 $y1 $x2 $y2 -fill black -tags piste
    }
    $w bind piste <ButtonPress-1> "AddObstacle $w %x %y"
}

proc ComputeAndColorSensors {w} {
    global T
    set sensors [list]
    set sensorsint [list]
    for {set i 0} {$i<[llength $T(offsetsensors)]} {incr i} {
        foreach {x1 y1 x2 y2} [$w coords robot$i] {}
        if {[expr $x1>$x2]} {
            set tmpx $x1
            set tmpy $y1
            set x1 $x2
            set y1 $y2
            set x2 $tmpx
            set y2 $tmpy
        }
        set onpiste 0
        foreach {px1 py1 px2 py2} $T(piste) {
            if {[expr !($x2<$px1 || $px2<$x1 || $y2<$py1 || $py2<$y1)]} {
                set onpiste 1
            }
        }
        if {$onpiste} {
            set col green
        } else {
            set col red
        }
        lappend sensors $col
        lappend sensorsint $onpiste
        $w itemconfigure robot$i -fill $col
    }
    set T(sensors) $sensors
    set T(sensorsint) $sensorsint
}

proc AddObstacle {w x y} {
    global T
    set obs [$w create rectangle [expr $x-5] [expr $y-5] [expr $x+5] [expr $y+5] -fill red -tags obstacle]
    $w bind $obs <ButtonPress-3> "$w delete $obs"
    $w bind $obs <ButtonPress-1> "$w delete $obs"
}

proc DetectObstacle {w} {
    global T
    set dist 255.0
    foreach {x0 y0 a} $T(pos) {}
    foreach id [$w find withtag obstacle] {
        foreach {x1 y1 x2 y2} [$w coords $id] {}
        #On prend le milieu de l'obstacle
        set x [expr $x1+5]
        set y [expr $y1+5]
        set theta [expr atan2($y0-$y,$x-$x0)]
		set A [expr abs($theta-$a)]
        if {[expr $A<$T(angleUS)]} {
            # Dans l'angle de vision
            set l [expr sqrt(($x-$x0)**2+($y-$y0)**2)]
            if {[expr $l<$dist]} {
                set dist $l
            }
        }
    }
    return [expr round($dist)]
}



proc trace {txt} {
	catch {console show}
	puts $txt
}

proc acceptcx {ch radr rport} {
	Reset .c
	fconfigure $ch -translation {auto}
	fileevent $ch readable "readcx $ch"
	trace "Connexion de $radr"
}

proc Reset {w} {
	global T
    global PI_4
    foreach id [$w find withtag robot] {
        $w delete $id
    }
    foreach id [$w find withtag obstacle] {
        $w delete $id
    }
    set T(leftmotor) 0
    set T(rightmotor) 0
	set T(led) black
	$w itemconfigure [$w find withtag Led] -fill $T(Led)
    eval DrawRobot $w $T(reset)
    ComputeAndColorSensors $w
}

proc readcx {ch} {
    global T
	set cmd [gets $ch]
	switch -regexp -- $cmd {
		{LIGHT.*} {puts $ch $T(sensorsint);flush $ch}
		{US.*} {puts $ch [DetectObstacle .c];flush $ch}
		{L[ \t]+[-+]?[0-9]+.*} {set T(leftmotor) [lindex $cmd 1];.c itemconfigure [.c find withtag left] -text $T(leftmotor)}
		{R[ \t]+[-+]?[0-9]+.*} {set T(rightmotor) [lindex $cmd 1];.c itemconfigure [.c find withtag right] -text $T(rightmotor)}
		{LED[ \t]+.*} {set T(Led) [lindex $cmd 1];.c itemconfigure [.c find withtag Led] -fill $T(Led)}
		default {close $ch}
	}
}

proc Simulate {w} {
    global T
    MoveRobot $w $T(leftmotor) $T(rightmotor)
    ComputeAndColorSensors $w
    after 20 Simulate $w
}
pack [canvas .c -width 500 -height 500] -fill both
DrawLine .c
eval DrawRobot .c $T(reset)
ComputeAndColorSensors .c
catch {console show}

# Variable mise a 1 lorsque l'application est detruite par l'utilisateur
if {[catch {socket -server acceptcx 4242}]} {
	tk_messageBox -icon error -title "Erreur d'initialisation" -message "Erreur lors de la création du serveur TCP port 4242\nV�rifiez qu'un autre simulateur ne tourne pas déjà!!!"
	exit
}
Simulate .c
