globals [
  ticks-at-last-change  ; value of the tick counter the last time a light changed
]

breed [eastcars eastcar]
breed [southcars southcar]
breed [northcars northcar]

breed [eastbikes eastbike]
breed [westbikes westbike]

breed [straightlights straightlight]
breed [turnlights turnlight]

breed [straights straight]
breed [car-straights car-straight]
breed [turns turn]

breed [crashes crash]
breed [graves grave]


to setup
  clear-all
  reset-ticks
  set-default-shape eastcars "car"
  set-default-shape southcars "car"
  set-default-shape northcars "car"
  set-default-shape turns "car"
  set-default-shape eastbikes "default"
  set-default-shape westbikes "default"
    ask turtles [set color one-of base-colors]

    ; turners
  create-turnlights 1 [setxy 2 -3 set color red set shape "arrow" set heading 90]
 ;create-turnlights 1 [setxy -1 -3 set color red set shape "arrow" set heading 180]

  ; straight-ahead
 create-straightlights 1 [setxy 0 3 set color green  set shape "cylinder"]
; create-straightlights 1 [setxy -1 -2 set color green set shape "cylinder"]
;create-straightlights 1 [setxy 2 -1 set color green set shape "cylinder"]

  create-space
end


to create-space
ask patches [
    ifelse pycor = -1 or pycor =  -2 ;biking lanes
    [set pcolor grey - 1  + random-float 0.25]
    [set pcolor green - random-float 0.5]]

  ask patches [ ;road
    if pycor = 2 or pycor = 1 or ((pycor = 0) and (pxcor < 1)) or ((pxcor = 1) and (pycor < 1)) or ((pxcor = 0) and (pycor < 1)) [


      set pcolor grey - 4 + random-float 0.25]]

  ask patches at-points [ [0 -1] [1 -1] [1 -2] [0 -2]] [ ;cykelsti
    set pcolor blue]

  ask patches at-points [[2 -3] [0 3]]
  [set pcolor black]
  end

to go
  move-eastcars
  move-southcars
  move-northcars

  move-eastbikes
  move-westbikes

  move-straights
  move-car-straights
  move-turns

if elapsed? green-length [
change-to-yellow]
  if any? turnlights with [color = yellow] and elapsed? yellow-length [
change-to-red]
 if any? straightlights with [color = yellow] and elapsed? yellow-length [
change-to-red]

    check-for-crashes
    add-new-graves
  tick

end

;;;;;;;;; blocked ? ;;;;;;;;;;;

to-report turn-block? ;turners
report
  any? southcars-on patch-ahead 1 or
  any? northcars-on patch-ahead 1 or
  any? eastcars-on patch-ahead 1 or
  any? turnlights with [color = red] or  ;one light is enough
  (any? turnlights with [color = yellow])
end



to-report straight-block?
report
  any? southcars-on patch-ahead 1 or
  any? northcars-on patch-ahead 1 or
  any? eastcars-on patch-ahead 1 or
  any? westbikes-on patch-ahead 1 or
  any? eastbikes-on patch-ahead 1 or
  any? straightlights with [color = red] or  ;one light is enough
  (any? straightlights with [color = yellow])
end




to move-eastcars
  ask eastcars with [pxcor = -1]
 [set breed car-straights]

 ask eastcars
 [if not any? turtles-on patch-ahead 1
 [fd 1]]

if random-float 100 < upper-lane-car-spawn
  [create-eastcars 1 [ setxy -16 2 set heading 90]]

   if random-float 100 < middle-lane-car-spawn
  [create-eastcars 1 [ setxy -16 1 set heading 90]]

  ask eastcars with [pxcor = 16]
    [die]
end


to move-car-straights
    ask car-straights
  [set shape "car"]

ask car-straights [
if straight-block? = false
[fd 1]]

  ask car-straights with [pxcor = 0]
[set breed eastcars]

  ask car-straights with [pxcor = 16]
  [die]
end



to move-straights
  ask straights
[set shape "default"]

ask straights [
if straight-block? = false
[fd 1]]

ask straights at-points [[1 -1]]
[set breed westbikes]

ask straights at-points [[0 -2]]
[set breed eastbikes]
end



to move-turns
ask turns [
if turn-block? = false
[fd 1]]

ask turns at-points [[1 -2]]
[set breed northcars]

ask turns at-points [[0 0]]
[set heading 180
set breed southcars]
end


to move-southcars
ask southcars at-points [[-1 0]]
[set breed turns]

  ask southcars [
  if not any? turtles-on patch-ahead 1
    [fd 1]]

if random-float 100 < bottom-lane-car-spawn [
    create-southcars 1 [ setxy -16 0 set heading 90]]

  ask southcars at-points [[0 -16]][
    die]
end


to move-northcars
ask northcars at-points [[1 -3]]
[set breed turns]

  ask northcars [
  if not any? turtles-on patch-ahead 1
    [fd 1]]

if random-float 100 < north-car-spawn
    [create-northcars 1 [ setxy 1 -16 set heading 0]]

  ask northcars at-points [[1 2]]
  [set heading 90]

  ask northcars with [pxcor = 16]
    [die]
end


to move-westbikes
   ask westbikes at-points [[2 -1]][
 set breed straights]

 ask westbikes
 [if not any? turtles-on patch-ahead 1
 [fd 1]]

  if random-float 100 < upper-lane-bike-spawn [
    create-westbikes 1 [ setxy 16 -1 set heading 270]]

  ask westbikes at-points [[-16 -1]] [
    die]
end


to move-eastbikes
 ask eastbikes at-points [[-1 -2]][
 set breed straights]

 ask eastbikes
 [if not any? turtles-on patch-ahead 1
 [fd 1]]

  if random-float 100 < bottom-lane-bike-spawn [
    create-eastbikes 1 [ setxy -16 -2 set heading 90]]

  ask eastbikes with [pxcor = 16] [
    die]
end


to change-to-yellow
  ask turnlights with [ color = green ] [
    set color yellow
    set ticks-at-last-change ticks]

     ask straightlights with [ color = green ] [
    set color yellow
    set ticks-at-last-change ticks]
end


to change-to-red
  ask turnlights with [color = red][ set color green ]
  ask turnlights with [ color = yellow ] [
    set color red
    set ticks-at-last-change ticks]

    ask straightlights with [color = red][ set color green ]
  ask straightlights with [ color = yellow ] [
    set color red
    set ticks-at-last-change ticks]
end


; reports `true` if `time-length` ticks
; has elapsed since the last light change
to-report elapsed? [ time-length ]
  report (ticks - ticks-at-last-change) > time-length
end



;;;;;;;;;;;;;
;; crashes ;;
;;;;;;;;;;;;;
;; not actuallu appplicable in this condition ;;
to check-for-crashes
  ask crashes [setxy random-pxcor 3
set breed graves]
 ask patches with [(count eastcars-here > 0 and count westbikes-here > 0)
    or (count northcars-here > 0 and count westbikes-here > 0)
    or (count southcars-here > 0 and count westbikes-here > 0)
     or (count eastcars-here > 0 and count eastbikes-here > 0)
    or (count northcars-here > 0 and count eastbikes-here > 0)
    or (count southcars-here > 0 and count eastbikes-here > 0)
 ]
    [sprout-crashes 1
 ask westbikes-here [ die ]
    ask eastbikes-here [ die ]
    ask northcars-here [die]
     ask eastcars-here [die]
  ask southcars-here [die]]
end


to add-new-graves
  ask graves [set color black
set heading 0  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
34
78
100
111
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
33
37
96
70
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
25
366
197
399
green-length
green-length
0
1000
111.0
1
1
NIL
HORIZONTAL

SLIDER
23
407
195
440
yellow-length
yellow-length
0
100
8.0
1
1
NIL
HORIZONTAL

BUTTON
103
39
184
72
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
107
80
178
113
switch
change-to-yellow
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
677
63
883
96
upper-lane-car-spawn
upper-lane-car-spawn
0
100
4.0
0.01
1
%
HORIZONTAL

SLIDER
676
139
891
172
bottom-lane-car-spawn
bottom-lane-car-spawn
0
100
1.1
0.01
1
%
HORIZONTAL

SLIDER
681
203
876
236
north-car-spawn
north-car-spawn
0
100
2.6
0.01
1
%
HORIZONTAL

SLIDER
682
255
894
288
upper-lane-bike-spawn
upper-lane-bike-spawn
0
100
0.0522
0.01
1
%
HORIZONTAL

SLIDER
683
295
903
328
bottom-lane-bike-spawn
bottom-lane-bike-spawn
0
100
0.18
0.01
1
%
HORIZONTAL

SLIDER
677
101
888
134
middle-lane-car-spawn
middle-lane-car-spawn
0
100
3.6
0.01
1
%
HORIZONTAL

PLOT
7
210
207
360
Totals
time
totals
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"cars" 1.0 0 -16777216 true "" "plot count eastcars + count southcars  + count northcars  + count turns + count car-straights"
"bikes" 1.0 0 -7500403 true "" "plot count eastbikes + count westbikes"

MONITOR
37
138
99
183
crashes
count graves
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

eyeball
false
0
Circle -1 true false 22 20 248
Circle -7500403 true true 83 81 122
Circle -16777216 true false 122 120 44

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

stop
false
14
Polygon -2674135 true false 75 105 75 45 120 15 180 15 225 45 225 90 225 105 180 135 120 135 75 105
Line -1 false 105 60 90 60
Line -1 false 90 60 90 75
Line -1 false 90 75 105 75
Line -1 false 105 90 105 75
Line -1 false 90 90 105 90
Line -1 false 120 60 135 60
Line -1 false 135 90 135 60
Line -1 false 135 60 150 60
Line -1 false 165 60 165 90
Line -1 false 180 60 180 90
Line -1 false 180 60 165 60
Line -1 false 180 90 165 90
Line -1 false 195 90 195 60
Line -1 false 210 60 195 60
Line -1 false 210 75 195 75
Line -1 false 210 60 210 75
Rectangle -7500403 true false 135 135 165 300

stop2
false
0
Polygon -2674135 true false 0 75 60 15 240 15 300 75 300 165 240 225 60 225 0 180 0 75
Line -1 false 270 60 225 60
Line -1 false 270 60 270 105
Line -1 false 225 105 270 105
Line -1 false 225 60 225 150
Line -1 false 210 150 210 60
Line -1 false 165 150 165 60
Line -1 false 210 60 165 60
Line -1 false 210 150 165 150
Line -1 false 150 60 90 60
Line -1 false 120 150 120 60
Line -1 false 75 60 30 60
Line -1 false 75 150 30 150
Line -1 false 30 105 30 60
Line -1 false 75 105 75 150
Line -1 false 30 105 75 105
Polygon -2674135 true false 45 45
Polygon -2674135 true false 60 210 75 225 225 225 240 210

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="traffic-light-timer_" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="293333"/>
    <metric>count turtles</metric>
    <metric>count eastbikes</metric>
    <metric>count westbikes</metric>
    <metric>count straights</metric>
    <metric>count straightlights</metric>
    <metric>count turnlights</metric>
    <metric>count crashes</metric>
    <metric>count graves</metric>
    <enumeratedValueSet variable="bottom-lane-car-spawn">
      <value value="1.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="yellow-length">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-lane-bike-spawn">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-lane-car-spawn">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-lane-bike-spawn">
      <value value="0.0522"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="north-car-spawn">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-lane-car-spawn">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-length">
      <value value="111"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
