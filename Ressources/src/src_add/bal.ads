generic

    type T_Message is private;
    --  Type générique du contenu de la boîte aux lettres

package BaL is

    protected type T_BaL is

        entry Envoyer (Msg : T_Message);
        --  Déposer un message dans la boite dès qu'elle est vide

        entry Recevoir (Msg : out T_Message);
        --  Retirer un message de la boite dès qu'elle est pleine

    private

        Message : T_Message;
        Pleine  : Boolean := False;

    end T_BaL;

end BaL;
