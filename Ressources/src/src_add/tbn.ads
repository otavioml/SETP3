generic

    type T_Element is private;
    --  Type générique stocké dans le tableau noir

package TbN is

    protected type T_TbN is

        function Lire return T_Element;
        --  Lire le contenu du tableau noir

        procedure Ecrire (Elem : T_Element);
        --  Mettre à jour le contenu du tableau noir

    private

        Element : T_Element;

    end T_TbN;

end TbN;
