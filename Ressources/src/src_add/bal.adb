package body BaL is

    protected body T_BaL is

        entry Envoyer (Msg : T_Message) when not Pleine is
        begin
            Message := Msg;
            Pleine  := True;
        end Envoyer;

        entry Recevoir (Msg : out T_Message) when Pleine is
        begin
            Msg    := Message;
            Pleine := False;
        end Recevoir;

    end T_BaL;

end BaL;
