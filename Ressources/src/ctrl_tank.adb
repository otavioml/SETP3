with Tank, Tk_Periph.Leds, Tk_Periph.Ultrasonic, Tk_Periph.Motors,
   Tk_Periph.Tracking;
use Tank, Tk_Periph.Leds, Tk_Periph.Motors, Tk_Periph.Tracking,
   Tk_Periph.Ultrasonic;
with TbN;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;

procedure Ctrl_Tank is
    Le_Tank : T_Tank;
    Piste   : T_Tracking;
    Pow     : constant T_Power := 40;
    package Danger is
        type T_Danger is (Aucun, Pause, Stop);
    end Danger;
    use Danger;
    package TbN_Danger is new TbN (T_Danger);
    Arret : TbN_Danger.T_TbN;
begin
    Le_Tank.Init ("Mon Tank 2");
    Le_Tank.Add_Tracking_Simu;
    Le_Tank.Add_Ultrasonic_Simu;
    Le_Tank.Add_Motors_Simu;
    Le_Tank.Add_Leds_Simu;
    Le_Tank.Color_Leds (Green);

    declare
        task Detecter_Afficher;
        task body Detecter_Afficher is
            periode : constant Time_Span := Ada.Real_Time.Milliseconds (20);
            Echeance : Time;
            distance : T_Distance;
            garder_loop : Boolean := True;
        begin
            while garder_loop loop
                Echeance := Clock + periode;
                distance := Le_Tank.Get_Ultrasonic_Distance;
                if distance > 50 then
                    Le_Tank.Color_Leds (Green);
                    Arret.Ecrire (Aucun);
                elsif distance > 30 and distance < 50 then
                    Le_Tank.Color_Leds (Yellow);
                    Arret.Ecrire (Aucun);
                elsif distance > 10 and distance < 30 then
                    Le_Tank.Color_Leds (Magenta);
                    Arret.Ecrire (Aucun);
                else
                    Le_Tank.Color_Leds (Red);
                    if distance > 5 then
                        Arret.Ecrire (Pause);
                    else
                        Arret.Ecrire (Stop);
                        garder_loop := False;
                    end if;
                end if;
                delay until Echeance;
            end loop;
        end Detecter_Afficher;

        task Suivre_Commander;
        task body Suivre_Commander is
            periode : constant Time_Span := Ada.Real_Time.Milliseconds (20);
            Echeance : Time;
            danger : T_Danger;
            centre : Float;
            somme : Float;
            compt : Float;
            Pui : T_Power;
            Piste : T_Tracking;
        begin
            Le_Tank.Move (Pow);
            loop
                compt := 0.0;
                somme := 0.0;
                Echeance := Clock + periode;
                danger := Arret.Lire;
                if danger = Stop then
                    exit;
                elsif danger = Pause then
                    Le_Tank.Stop;
                else
                    Le_Tank.Track (Piste);
                    for I in T_Index_Sensors loop
                        if Le_Tank.Get_Track_Channel (Piste, I) = True then
                            somme := somme + Float (I);
                            compt := compt + 1.0;
                        end if;
                    end loop;
                    if compt = 0.0 then
                        Spin (Le_Tank, Pow);
                    else
                        centre := somme / compt;
                        Pui := T_Power ((centre - 1.5) * 6.0 * 0.6);
                        Le_Tank.Left (Pow - Pui);
                        Le_Tank.Right (Pow + Pui);
                    end if;
                end if;
                delay until Echeance;
            end loop;
        end Suivre_Commander;

    begin
        null;
    end;
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
end Ctrl_Tank;
