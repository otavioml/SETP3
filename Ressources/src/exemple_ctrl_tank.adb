with Tank, Tk_Periph.Leds, Tk_Periph.Ultrasonic, Tk_Periph.Motors,
   Tk_Periph.Tracking;
use Tank, Tk_Periph.Leds, Tk_Periph.Motors, Tk_Periph.Tracking,
   Tk_Periph.Ultrasonic;
with Ada.Text_IO; use Ada.Text_IO;

procedure Exemple_Ctrl_Tank is
    Le_Tank : T_Tank;
    Piste   : T_Tracking;
    Pow     : constant T_Power := 35;
begin
    Le_Tank.Init ("Mon Tank");
    Le_Tank.Add_Tracking_Simu;
    Le_Tank.Add_Ultrasonic_Simu;
    Le_Tank.Add_Motors_Simu;
    Le_Tank.Add_Leds_Simu;

    Le_Tank.Track (Piste);
    for I in T_Index_Sensors loop
        Put (Boolean'Image (Le_Tank.Get_Track_Channel (Piste, I)) & "-");
    end loop;

    Le_Tank.Color_Leds (Green);

    Le_Tank.Move (Pow);
    delay 0.5;
    Le_Tank.Left (50);

    Boucle_Infinie :
    loop
        delay 2.0;
        Put_Line
           (Item =>
               "Dist. obst. = " &
               T_Distance'Image (Le_Tank.Get_Ultrasonic_Distance));
        Le_Tank.Track (Piste);
        for I in T_Index_Sensors loop
            Put (Item =>
                   Boolean'Image (Le_Tank.Get_Track_Channel (Piste, I)) & "-");
        end loop;
    end loop Boucle_Infinie;
end Exemple_Ctrl_Tank;
