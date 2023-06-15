with
    Tank,
    Tk_Periph.Leds,
    Tk_Periph.Ultrasonic,
    Tk_Periph.Motors,
    Tk_Periph.Tracking,
    Ada.Text_IO,
    Pcmc_Simple_Frame,
    Pcmc_Header,
    Pcmc_Notes,
    Pcmc_Simple_Frame.Io,
    GNAT.Sockets;
use
    Tank,
    Tk_Periph.Leds,
    Tk_Periph.Ultrasonic,
    Tk_Periph.Motors,
    Tk_Periph.Tracking,
    Ada.Text_IO,
    Pcmc_Simple_Frame,
    Pcmc_Header,
    Pcmc_Notes,
    Pcmc_Simple_Frame.Io,
    GNAT.Sockets;
with TbN;
with Ada.Real_Time; use Ada.Real_Time;

procedure Ctrl_Tank is
    Le_Tank : T_Tank;
    package TbN_Puissance is new TbN (Pcmc_Header.T_Power);
    use TbN_Puissance;
    Puissance : T_TbN;
begin
    Le_Tank.Init ("Mon Tank 2");
    Le_Tank.Add_Tracking_Simu;
    Le_Tank.Add_Ultrasonic_Simu;
    Le_Tank.Add_Motors_Simu;
    Le_Tank.Add_Leds_Simu;
    Le_Tank.Color_Leds (Green);

    declare
        task Recv_Trame;
        task body Recv_Trame is
            Socket  : Socket_Type;
            Client  : Socket_Type;
            Addr    : Sock_Addr_Type;
            Cmpt    : Integer := 0;
        begin
            Create_Socket (Socket, Family_Inet, Socket_Stream);
            Addr.Addr := Any_Inet_Addr;
            Addr.Port := Port_Type'Value ("7777");
            Bind_Socket (Socket, Addr);
            Put_Line ("Listening on port" & Port_Type'Image (Addr.Port));
            Listen_Socket (Socket);
            Accept_Socket (Server => Socket,
                Socket => Client, Address => Addr);
            Put_Line ("Connecte !!");
            Ctrl_C_Handle;
            Boucle_Principale : loop
                declare
                    Frame : constant T_Pcmc_Simple_Frame :=
                        Receive (Client);
                    Header : constant T_Pcmc_Frame_Header :=
                        Get_Header (Frame);
                    Pui : constant Pcmc_Header.T_Power := Get_Power (Header);
                begin
                    Cmpt := Cmpt + 1;
                    Put_Line ("===> Trame " & Positive'Image (Cmpt) &
                        " :");
                    Put ("Receiving the power " &
                        Pcmc_Header.T_Power'Image (Pui));
                    New_Line;
                    Puissance.Ecrire (Pui);
                end;
                exit Boucle_Principale when PCMC_Stop;
            end loop Boucle_Principale;
            New_Line;
            Put_Line ("==> Programme serveur interrompu " &
                "Fermeture des connexions ...");
            Close_Socket (Client);
            Close_Socket (Socket);
        exception
            when PCMC_Network_Exception =>
                Put_Line ("==> Client déconnecté !");
                Close_Socket (Client);
                Close_Socket (Socket);
        end Recv_Trame;

        task Suivre_Commander;
        task body Suivre_Commander is
            periode : constant Time_Span := Ada.Real_Time.Milliseconds (20);
            Echeance : Time;
            centre : Float;
            somme : Float;
            compt : Float;
            Pui_trame : Pcmc_Header.T_Power;
            Pui_integer : Integer;
            Pui : Tk_Periph.Motors.T_Power;
            Pui_Motor : Tk_Periph.Motors.T_Power;
            Piste : T_Tracking;
        begin
            loop
                Pui_trame := Puissance.Lire;
                Put_Line ("puissance lue " &
                    Pcmc_Header.T_Power'Image (Pui_trame));
                Pui_integer := Pcmc_Header.T_Power'Pos (Pui_trame);
                Pui_Motor :=
                    Tk_Periph.Motors.T_Power ((Pui_integer * 100) / 32767);
                    Put_Line ("Moving with power " &
                        Tk_Periph.Motors.T_Power'Image (Pui_Motor));
                Le_Tank.Move (Pui_Motor);
                compt := 0.0;
                somme := 0.0;
                Echeance := Clock + periode;
                Le_Tank.Track (Piste);
                for I in T_Index_Sensors loop
                    if Le_Tank.Get_Track_Channel (Piste, I) = True then
                        somme := somme + Float (I);
                        compt := compt + 1.0;
                    end if;
                end loop;
                if compt = 0.0 then
                    Spin (Le_Tank, Pui_Motor);
                    Put_Line ("Stuck at this condition");
                else
                    Put_Line ("Calculating the new center of the track");
                    centre := somme / compt;
                    Pui := Tk_Periph.Motors.T_Power
                        ((centre - 1.5) * 6.0 * 0.6);
                    Le_Tank.Left (Pui_Motor - Pui);
                    Le_Tank.Right (Pui_Motor + Pui);
                end if;
                delay until Echeance;
            end loop;
        end Suivre_Commander;

    begin
        null;
    end;
end Ctrl_Tank;
