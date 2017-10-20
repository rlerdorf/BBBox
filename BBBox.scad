/*
   This is entirely based on:

              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -

*/

/* [Box dimensions] */
Length       = 96.5;
Width        = 66;
Height       = 34;
Thick        = 2; // Wall thickness. If you change this you will have to adjust a few things

LayerHeight = 0.2;  // LayerHeight for 3D printing

/* [Box options] */
Filet       = 5;   // Filet diameter [0.1:12]
Resolution  = 70;  // Filet smoothness [1:100]
m           = 0.9; // Tolerance (Panels/rails gap)
PCBFeet     = 0;   // PCB feet (x4) [0:No, 1:Yes]
Vent        = 1;   // Ventilation holes [0:No, 1:Yes]
Vent_width  = 1.5;
HoleDia     = 2.1; // Diameter of case screw holes

/* BreadBoard Mount */
BBMount   =  1;

BBPosX    = 3;
BBPosY    = 2;
BBLength  = 82.5;
BBHeight  =  9.5;
BBWidth   = 54.5;
TabWidth  =  3.2;
TabDepth  =  1.5;
TabHeight =  5.8;

/* [PCB_Feet] */
//All dimensions are from the center foot axis

PCBPosX         =  3;
PCBPosY         =  2;
PCBLength       = 68;
PCBWidth        = 40;
FootHeight      = 10;
FootDia         =  6;
FootHole        =  0;
TabHeight       =  6;

/* [STL elements to export] */
TShell          = 0;// [0:No, 1:Yes]
BShell          = 0;// [0:No, 1:Yes]
FPanL           = 1;// [0:No, 1:Yes]
BPanL           = 0;// [0:No, 1:Yes]

/* [Hidden] */
Couleur1        = "Orange";  // Shell Colour
Couleur2        = "OrangeRed"; // Panels Colour

// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size        = Vent ? Thick*2 : 0.8;

/////////// - Generic rounded box - //////////

module RoundBox($a=Length, $b=Width, $c=Height) {
    $fn=Resolution;
    translate([0,Filet,Filet]) {
        minkowski() {
            cube ([$a-(Length/2), $b-(2*Filet), $c-(2*Filet)], center = false);
            rotate([0,90,0]) {
                cylinder(r=Filet,h=Length/2, center = false);
            }
        }
    }
}


////////////////////////////////// - Shell - //////////////////////////////////

module Coque() {
    Thick = Thick*2;
    difference() {
        difference() { //sides decoration
            union() {
                difference() { // Substraction Fileted box
                    difference() { // Median cube slicer
                        union() { // union
                            difference() { // Shell
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]) {
                                    RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                }
                            }
                            difference() { //largeur Rails
                                translate([Thick + m, Thick/2, Thick/2]) { // Rails
                                    RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                }
                                translate([((Thick+m/2)*1.55), Thick/2, Thick/2+LayerHeight]) { // + LayerHeight to avoid artefacts
                                    RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                                }
                            }
                        }
                        translate([-Thick, -Thick, Height/2]) { // Cube à soustraire
                            cube ([Length+100, Width+100, Height], center=false);
                        }
                    }
                    translate([-Thick/2,Thick,Thick]) { // Forme de soustraction centrale
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);
                    }
                }

                difference() { // wall fixation box legs
                    union() {
                        translate([3*Thick +5,Thick,Height/2]) {
                            rotate([90,0,0]) {
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }
                        }

                        translate([Length-((3*Thick)+5),Thick,Height/2]) {
                            rotate([90,0,0]) {
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }
                        }

                    }
                    translate([4,Thick+Filet,Height/2-57]) {
                        rotate([45,0,0]) {
                            cube([Length, 40, 40]);
                        }
                    }
                    translate([0, -(Thick*1.46), Height/2]) {
                        cube([Length, Thick*2, 10]);
                    }
                }
            }

            union() { // outbox sides decorations
                if(Vent) for(i=[0:Thick:Length/4]) {
                    // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([10+i,-Dec_Thick+Dec_size,1]) {
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]) {
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_size,1]) {
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_size,1]) {
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                }
            }
        }


        union() { // side holes
            $fn=50;
            translate([3*Thick+5, 8, Height/2+4]) {
                rotate([90,0,0]) {
                    cylinder(d=HoleDia, 10);
                }
            }
            translate([Length-((3*Thick)+5), 8, Height/2+4]) {
                rotate([90,0,0]) {
                    cylinder(d=HoleDia, 10);
                }
            }
            translate([3*Thick+5, Width+4, Height/2-4]) {
                rotate([90,0,0]) {
                    cylinder(d=HoleDia, 10);
                }
            }
            translate([Length-((3*Thick)+5), Width+4, Height/2-4]) {
                rotate([90,0,0]) {
                    cylinder(d=HoleDia, 10);
                }
            }
        }
    }
}
/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia,FootHole,FootHeight) {
    Filet=2;
    color(Couleur1) translate([0,0,Filet-1.5]) difference() {
        difference() {
        //  translate ([0,0,-Thick]) {
                cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
        //  }
            rotate_extrude($fn=100) {
                translate([(FootDia+Filet*2)/2,Filet,0]) {
                    minkowski() {
                        square(10);
                        circle(Filet, $fn=100);
                    }
                }
            }
        }
        cylinder(d=FootHole, FootHeight+1, $fn=100);
    }
}

module BBTabs() {
    translate([Thick+2*m + 0.1, 2*Thick, Thick+0.2]) {
        union() {
            %cube([BBLength, BBWidth, BBHeight]);
            translate([13, -TabDepth, 0]) {
                %cube([TabWidth, TabDepth*2, TabHeight]);
            }
            translate([BBLength-13, -TabDepth, 0]) {
                %cube([TabWidth, TabDepth*2, TabHeight]);
            }
            translate([13, BBWidth-TabDepth, 0]) {
                %cube([TabWidth, TabDepth*2, TabHeight]);
            }
            translate([BBLength-13, BBWidth-TabDepth, 0]) {
                %cube([TabWidth, TabDepth*2, TabHeight]);
            }
            translate([-TabDepth, 3, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
            translate([-TabDepth, BBWidth/2-TabWidth/2, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
            translate([-TabDepth, BBWidth-TabWidth-3, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
            translate([BBLength-TabDepth, 3, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
            translate([BBLength-TabDepth, BBWidth/2-TabWidth/2, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
            translate([BBLength-TabDepth, BBWidth-TabWidth-3, 0]) {
                %cube([TabDepth*2, TabWidth, TabHeight]);
            }
        }
    }
}

module Feet() {
    // - PCB only visible in the preview mode
    translate([3*Thick+2,Thick+5,FootHeight+(Thick/2)-0.5]) {
        %square ([PCBLength+10,PCBWidth+10]);
        translate([PCBLength/2,PCBWidth/2,0.5]) {
            color("Olive") %text("PCB", halign="center", valign="center", font="Arial black");
       }
    }


    // - 4 Feet
    translate([3*Thick+4,Thick+7,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }
    translate([(3*Thick)+PCBLength+10,Thick+7,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }
    translate([(3*Thick)+PCBLength+10,(Thick)+PCBWidth+13,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }
    translate([3*Thick+4,(Thick)+PCBWidth+13,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }

}

////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////

//                           <- Panel ->
module Panel(Length,Width,Thick,Filet) {
    scale([0.5,1,1])
    minkowski() {
        cube([Thick,Width-(Thick*2+Filet*2+m),Height-(Thick*2+Filet*2+m)]);
        translate([0,Filet,Filet]) rotate([0,90,0]) {
            cylinder(r=Filet,h=Thick, $fn=100);
        }
    }
}



//                          <- Circle hole ->
// Cx=Cylinder X position | Cy=Cylinder Y position | Cdia= Cylinder dia | Cheight=Cyl height
module CylinderHole(OnOff,Cx,Cy,Cdia) {
    if(OnOff==1) {
        translate([Cx,Cy,-1]) {
            cylinder(d=Cdia,10, $fn=50);
        }
    }
}

//                          <- Square hole ->
// Sx=Square X position | Sy=Square Y position | Sl= Square Length | Sw=Square Width | Filet = Round corner
module SquareHole(OnOff,Sx,Sy,Sl,Sw,Filet) {
    if(OnOff==1)
    minkowski() {
        translate([Sx+Filet/2,Sy+Filet/2,-1]) {
            cube([Sl-Filet,Sw-Filet,10]);
        }
        cylinder(d=Filet,h=10, $fn=100);
    }
}


//                      <- Linear text panel ->
module LText(OnOff,Tx,Ty,Font,Size,Content) {
    if(OnOff==1)
    translate([Tx,Ty,Thick+.5]) linear_extrude(height = 0.5) {
        text(Content, size=Size, font=Font);
    }
}

//                     <- Circular text panel->
module CText(OnOff,Tx,Ty,Font,Size,TxtRadius,Angl,Turn,Content) {
    if(OnOff==1) {
        Angle = -Angl / len(Content);
        translate([Tx,Ty,Thick+.5]) {
            for (i= [0:len(Content)-1] ) {
                rotate([0,0,i*Angle+90+Turn]) translate([0,TxtRadius,0]) {
                    linear_extrude(height = 0.5) {
                        text(Content[i], font = Font, size = Size,  valign ="baseline", halign ="center");
                    }
                }
            }
        }
    }
}

////////////////////// <- New module Panel -> //////////////////////
module FPanL() {
    difference() {
        color(Couleur2)
        Panel(Length,Width,Thick,Filet);

        rotate([90,0,90]) {
            color(Couleur2) {
//                     <- Cutting shapes from here ->
//              SquareHole  (1,20,20,15,10,1); //(On/Off, Xpos,Ypos,Length,Width,Filet)
//              SquareHole  (1,40,20,15,10,1);

              CylinderHole(1,49.5,19.5,8);       //(On/Off, Xpos, Ypos, Diameter)
              translate([Thick,14-Thick, -1]) {
                cube([Width-4*Thick-1,2,1.8]);
              }
              translate([40-2*Thick,15-Thick, -1]) {
                cube([20,13,1.8]);
              }
//              CylinderHole(1,47,40,8);
//              CylinderHole(1,67,40,8);
//              SquareHole  (1,20,50,80,30,3);
//              CylinderHole(1,93,30,10);
//              SquareHole  (1,120,20,30,60,3);
//                            <- To here ->
           }
       }
}

    color(Couleur1) {
        translate ([-.5,0,0]) rotate([90,0,90]) {
//                      <- Adding text from here ->
//          LText(1,20,83,"Arial Black",4,"Digital Screen");//(On/Off, Xpos, Ypos, "Font", Size, "Text")
//          LText(1,30,7,"Arial Black",4,"Sensor");
//          LText(1,22.5,14,"Arial Black",4,"USB");
//          CText(1,20,10,"Arial Black",4,7,225,0,"9V-DC");//(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
//                            <- To here ->
            }
      }
}


/////////////////////////// <- Main part -> /////////////////////////

if(TShell==1) color( Couleur1,1) {
    translate([0,Width,Height+0.2]) {
        rotate([0,180,180]) {
            difference() {
                Coque();
                // Cut holes in the top shell
                CylinderHole(1, 65, Width/2, 11.8);
                CylinderHole(1, 25, Width/2, 5);
                SquareHole(1,8.5, Width/2-1.25-10, 7, 2.5, 1);
                SquareHole(1,8.5, Width/2-1.25-5, 7, 2.5, 1);
                SquareHole(1,8.5, Width/2-1.25, 7, 2.5, 1);
                SquareHole(1,8.5, Width/2-1.25+5, 7, 2.5, 1);
                SquareHole(1,8.5, Width/2-1.25+10, 7, 2.5, 1);
            }
        }
    }
}

if(BShell==1) color(Couleur1) {
    difference() {
        Coque();
        if(BBMount) {
            translate([2*Thick, 2*Thick+BBPosY+3-0.15, Thick+0.3]) {
                cube([Length-4*Thick, TabWidth+0.3, TabHeight]);
            }
            translate([2*Thick, 2*Thick+BBPosY+BBWidth-3-TabWidth-0.15, Thick+0.3]) {
                cube([Length-4*Thick, TabWidth+0.3, TabHeight]);
            }
            translate([2*Thick, 2*Thick+BBPosY+BBWidth/2-TabWidth/2-0.15, Thick+0.3]) {
                cube([Length-4*Thick, TabWidth+0.3, TabHeight]);
            }
        }
    }
}

if (PCBFeet==1) {
    translate([PCBPosX, PCBPosY, 0]) {
        Feet();
    }
}

if(BBMount==1) {
    translate([BBPosX, BBPosY, 0]) {
        BBTabs();
    }
}

// Front Panel
if(FPanL==1) {
    translate([Length-(Thick*2+m/2),Thick+m/2,Thick+m/2]) {
        FPanL();
    }
}

// Back panel
if(BPanL==1) {
    color(Couleur2) {
        translate([Thick+m/2,Thick+m/2,Thick+m/2]) {
            difference() {
                Panel(Length,Width,Thick,Filet);
                /*
                rotate([90,0,90]) {
                    CylinderHole(1,37.5,23,2);
                    SquareHole  (1,24,20,12,6,1);
                    CylinderHole(1,22.5,23);
                }
                */
            }
        }
    }
}
