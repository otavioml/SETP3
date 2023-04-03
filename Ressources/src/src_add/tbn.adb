package body TbN is

    protected body T_TbN is

        function Lire return T_Element is
        begin
            return Element;
        end Lire;

        procedure Ecrire (Elem : T_Element) is
        begin
            Element := Elem;
        end Ecrire;

    end T_TbN;

end TbN;
