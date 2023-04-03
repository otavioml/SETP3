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
    Pow     : constant T_Power := 10;
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
            Pow : constant T_Power := 10;
            garder_loop : Boolean := True;
            Consigne : constant Float := 1.5;
            danger : T_Danger;
            centre : Float;
            somme : Integer := 0;
            compt : Integer := 0;
            correction : Float;
            i : Integer := 0;
        begin
            Le_Tank.Move (Pow);
            while garder_loop loop
                Echeance := Clock + periode;
                danger := Arret.Lire;
                if danger = Stop then
                    garder_loop := False;
                elsif danger = Pause then
                    Le_Tank.Stop;
                else
                    for I in T_Index_Sensors loop
                        if Le_Tank.Get_Track_Channel (Piste, I) = True then
                            somme := somme + i;
                            compt := compt + 1;
                        end if;
                        i := i + 1;
                    end loop;
                    if compt /= 0 then
                        centre := somme/compt;
                    else
                        centre := 0;
                    end if;
                    if Consigne - centre = 0 then
                        Le_Tank.Spin (Pow);
                    else
                        correction := (Consigne - centre) * 6 * 1.2;
                        Le_Tank.Left (Pow + correction);
                        Le_Tank.Right (Pow - correction);
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
