CREATE OR REPLACE PACKAGE angajat_package AS
    PROCEDURE add_employee (
        nume  IN angajat.nume_angajat%TYPE,
        cnp   IN detalii_angajat.cnp_angajat%TYPE,
        adr   IN detalii_angajat.adresa%TYPE,
        phone IN detalii_angajat.telefon%TYPE,
        mail  IN detalii_angajat.email%TYPE
    );

    PROCEDURE delete_employee (
        id_angajat IN angajat.angajat_id%TYPE
    );

    PROCEDURE update_employee (
        id_angajat IN angajat.angajat_id%TYPE,
        choice     IN VARCHAR2,
        updated    IN VARCHAR2
    );

    PROCEDURE afisare_informatii;

END angajat_package;
/

CREATE OR REPLACE PACKAGE BODY angajat_package AS

    PROCEDURE add_employee (
        nume  IN angajat.nume_angajat%TYPE,
        cnp   IN detalii_angajat.cnp_angajat%TYPE,
        adr   IN detalii_angajat.adresa%TYPE,
        phone IN detalii_angajat.telefon%TYPE,
        mail  IN detalii_angajat.email%TYPE
    ) IS
    BEGIN
        SAVEPOINT add_angajat_savepoint;
        BEGIN
            INSERT INTO angajat (
                librarie_id,
                nume_angajat
            ) VALUES (
                100,
                nume
            );

            INSERT INTO detalii_angajat VALUES (
                angajat_angajat_id_seq.CURRVAL,
                cnp,
                adr,
                phone,
                mail
            );

            COMMIT;
        EXCEPTION
            WHEN dup_val_on_index THEN
                ROLLBACK TO add_angajat_savepoint;
                raise_application_error(-20001, 'Numarul de telefon/cnp exista deja!');
            WHEN OTHERS THEN
                ROLLBACK TO add_angajat_savepoint;
                raise_application_error(-20002, 'Eroare in adaugarea angajatului: ' || sqlerrm);
        END;

    END;

    PROCEDURE delete_employee (
        id_angajat IN angajat.angajat_id%TYPE
    ) IS
        v_cnt NUMBER;
        v_bon vanzare.nr_bon%TYPE;
    BEGIN
        SAVEPOINT delete_angajat_savepoint;
        
        SELECT COUNT(*) into v_cnt FROM vanzare WHERE angajat_id=id_angajat;
        IF(v_cnt != 0) then
            SELECT nr_bon into v_bon FROM vanzare WHERE angajat_id=id_angajat;
            DELETE FROM detalii_vanzare WHERE vanzare_nr_bon = v_bon;
            DELETE FROM vanzare WHERE nr_bon=v_bon;
        END IF;
        DELETE FROM detalii_angajat
        WHERE
            angajat_id = id_angajat;

        IF SQL%notfound THEN
            ROLLBACK TO delete_angajat_savepoint;
            raise_application_error(-20201, 'Identificatorul '
                                            || id_angajat
                                            || ' al angajatului este invalid.');
        END IF;

        DELETE FROM angajat
        WHERE
            angajat_id = id_angajat;

        COMMIT;
    END;

    PROCEDURE update_employee (
        id_angajat IN angajat.angajat_id%TYPE,
        choice     IN VARCHAR2,
        updated    IN VARCHAR2
    ) IS
        e_angajat_not_found EXCEPTION;
        e_bad_choice EXCEPTION;
    BEGIN
        IF ( choice = 'adresa' ) THEN
            UPDATE detalii_angajat
            SET
                adresa = updated
            WHERE
                angajat_id = id_angajat;

        ELSIF ( choice = 'cnp' ) THEN
            UPDATE detalii_angajat
            SET
                cnp_angajat = updated
            WHERE
                angajat_id = id_angajat;

        ELSIF ( choice = 'telefon' ) THEN
            UPDATE detalii_angajat
            SET
                telefon = updated
            WHERE
                angajat_id = id_angajat;

        ELSIF ( choice = 'email' ) THEN
            UPDATE detalii_angajat
            SET
                email = updated
            WHERE
                angajat_id = id_angajat;

        ELSE
            RAISE e_bad_choice;
        END IF;

        IF SQL%notfound THEN
            RAISE e_angajat_not_found;
        END IF;
    EXCEPTION
        WHEN e_bad_choice THEN
            raise_application_error(-20201, 'Alegerea introdusa este invalida!');
        WHEN e_angajat_not_found THEN
            raise_application_error(-20201, 'Identificatorul '
                                            || id_angajat
                                            || ' al angajatului este invalid.');
        WHEN dup_val_on_index THEN
            raise_application_error(-20001, 'Numarul de telefon/cnp exista deja!');
        WHEN OTHERS THEN
            raise_application_error(-20002, 'Eroare in adaugarea angajatului '
                                            || id_angajat
                                            || ': '
                                            || sqlerrm);
    END;

    PROCEDURE afisare_informatii IS

        CURSOR crs IS
        SELECT
            *
        FROM
            angajat;

        CURSOR detalii (
            v_empno angajat.angajat_id%TYPE
        ) IS
        SELECT
            cnp_angajat,
            adresa,
            telefon,
            email
        FROM
            detalii_angajat
        WHERE
            angajat_id = v_empno;

        TYPE emp_record IS RECORD (
            cnp_angajat detalii_angajat.cnp_angajat%TYPE,
            adresa      detalii_angajat.adresa%TYPE,
            telefon     detalii_angajat.telefon%TYPE,
            email       detalii_angajat.email%TYPE
        );
        emp_table emp_record;
    BEGIN
        FOR rec IN crs LOOP
            OPEN detalii(rec.angajat_id);
            FETCH detalii INTO emp_table;
            CLOSE detalii;
            dbms_output.put_line(rec.angajat_id
                                 || '. '
                                 || rec.nume_angajat);
            dbms_output.put_line('         Librarie: ' || rec.librarie_id);
            dbms_output.put_line('         CNP: ' || emp_table.cnp_angajat);
            dbms_output.put_line('         Adresa: ' || emp_table.adresa);
            dbms_output.put_line('         Telefon: ' || emp_table.telefon);
            dbms_output.put_line('         Email: ' || emp_table.email);
        END LOOP;
    END;

END angajat_package;
/

CREATE OR REPLACE PACKAGE client_package IS

    PROCEDURE add_client (nume in client.nume_client%TYPE,
        cnp in client.cnp_client%TYPE,
        card in client.nr_card%TYPE,
        phone in client.telefon%TYPE,
        adr in client.adresa%TYPE,
        cardF in client.card_fidelitate%TYPE);
    PROCEDURE delete_client(cnp in client.cnp_client%TYPE);
    PROCEDURE update_client(id_client in client.client_id%TYPE,choice in varchar2, updated in varchar2);
    PROCEDURE afisare_informatii;
END client_package;
/
CREATE OR REPLACE PACKAGE BODY client_package AS
    PROCEDURE add_client (nume IN client.nume_client%TYPE,
        cnp IN client.cnp_client%TYPE,
        card IN client.nr_card%TYPE,
        phone IN client.telefon%TYPE,
        adr IN client.adresa%TYPE,
        cardF IN client.card_fidelitate%TYPE
    ) 
    IS 
    BEGIN
         INSERT INTO client(nume_client, cnp_client, nr_card, telefon, adresa, card_fidelitate)
                VALUES(nume, cnp, card, phone, adr, cardF);
    EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN 
                RAISE_APPLICATION_ERROR ( -20001 , 'Numarul de telefon/cnp/numarul cardului exista deja!' );
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Eroare in adaugarea clientului: ' || SQLERRM);
    END;
    
    PROCEDURE delete_client(cnp in client.cnp_client%TYPE) IS
            CURSOR cursor1 IS SELECT client_id FROM client WHERE cnp_client=cnp;
            id_client vanzare.client_id%TYPE;
            CURSOR cursor2 IS SELECT nr_bon FROM vanzare WHERE client_id=id_client;
            bon detalii_vanzare.vanzare_nr_bon%TYPE;
        BEGIN
            OPEN cursor1;
            FETCH cursor1 INTO id_client;
            CLOSE cursor1;
            IF id_client IS NULL THEN
                    RAISE_APPLICATION_ERROR ( -20201 , 'Clientul nu exista in baza de date' ) ;
            END IF;
            OPEN cursor2;
            FETCH cursor2 INTO bon;
            CLOSE cursor2;
            IF bon IS NOT NULL THEN
                DELETE FROM detalii_vanzare WHERE vanzare_nr_bon=bon;
                DELETE FROM vanzare WHERE client_id=id_client;
            END IF;
            DELETE FROM client WHERE client_id=id_client;
    END;
    
    PROCEDURE update_client(id_client IN client.client_id%TYPE,choice IN varchar2, updated IN varchar2) 
    IS
        e_no_rows exception;
        e_bad_choice EXCEPTION;

    BEGIN
        IF(choice = 'cnp') THEN
            UPDATE client SET cnp_client=updated WHERE client_id=id_client;
        ELSIF(choice = 'telefon') THEN
            UPDATE client SET telefon=updated WHERE client_id=id_client;
        ELSIF(choice = 'adresa') THEN
            UPDATE client SET adresa=updated WHERE client_id=id_client;
        ELSE
            RAISE e_bad_choice;
        END IF;
        IF SQL %NOTFOUND THEN
            RAISE e_no_rows;
        END IF;
        
        EXCEPTION
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Alegerea introdusa este invalida!' );
            WHEN DUP_VAL_ON_INDEX THEN 
                RAISE_APPLICATION_ERROR ( -20001 , 'Numarul de telefon/cnp/numarul cardului exista deja!' );
            WHEN e_no_rows THEN  
                RAISE_APPLICATION_ERROR ( -20201 , 'Clientul cu identificatorul ' || id_client || ' nu exista' ) ;
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Eroare in actualizarea clientului ' || id_client ||': ' || SQLERRM);
    end;
    
    PROCEDURE afisare_informatii 
    IS
       cursor crs is
        select * from client;
    BEGIN
        for rec in crs loop
            DBMS_OUTPUT.PUT_LINE(rec.client_id);
            DBMS_OUTPUT.PUT_LINE('      Nume: ' || rec.nume_client || ';');
            DBMS_OUTPUT.PUT_LINE('      Cnp: ' || rec.cnp_client || ';');
            DBMS_OUTPUT.PUT_LINE('      Telefon: ' || rec.telefon || ';');
            DBMS_OUTPUT.PUT_LINE('      Adresa: ' || rec.adresa || ';');
            DBMS_OUTPUT.PUT_LINE('      Card fidelitate: ' || rec.card_fidelitate || ';');
        end loop;
    END;
END client_package;
/

CREATE OR REPLACE PACKAGE furnizori_package IS

    PROCEDURE add_furnizor (nume in furnizori.nume_furnizor%TYPE,
        adr in furnizori.adresa%TYPE,
        mail in furnizori.email%TYPE);
    PROCEDURE delete_furnizor(nume in furnizori.nume_furnizor%TYPE);
    PROCEDURE update_furnizor(nume in furnizori.nume_furnizor%TYPE,choice in varchar2, updated in varchar2);
    PROCEDURE afisare_informatii ;

END furnizori_package;
/
CREATE OR REPLACE PACKAGE BODY furnizori_package AS
    PROCEDURE add_furnizor (nume IN furnizori.nume_furnizor%TYPE,
        adr IN furnizori.adresa%TYPE,
        mail IN furnizori.email%TYPE) 
    IS 
    BEGIN
        INSERT INTO furnizori(nume_furnizor, adresa, email) VALUES(nume, adr, mail);
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Eroare in adaugarea furnizorului ' || nume || ': ' || SQLERRM);
    END;
    
    PROCEDURE delete_furnizor(nume in furnizori.nume_furnizor%TYPE) 
    IS
        CURSOR cursor1 IS SELECT furnizor_id FROM furnizori WHERE nume_furnizor=nume;
        id_furnizor furnizori.furnizor_id%TYPE;
        CURSOR cursor2 Is SELECT produs_id FROM produse WHERE furnizor_id=id_furnizor;
        id_prod produse.produs_id%TYPE;

        e_not_found EXCEPTION;
    BEGIN
        BEGIN
            OPEN cursor1;
            FETCH cursor1 INTO id_furnizor;
            IF id_furnizor IS NULL THEN
                RAISE e_not_found;
            END IF;
            CLOSE cursor1;
            
            FOR rec IN cursor2 LOOP
                DELETE FROM detalii_vanzare WHERE produse_produs_id=rec.produs_id;
                DELETE FROM produse WHERE produs_id=rec.produs_id;
            END LOOP;
            DELETE FROM furnizori WHERE nume_furnizor=nume;
        EXCEPTION
            WHEN e_not_found THEN  RAISE_APPLICATION_ERROR ( -20201 , 'Furnizorul nu exista' );
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR ( -20002 , 'Eroare intampinata la stergerea furnizorului ' || nume ||': ' || SQLERRM || '.' ) ;
        END ;
    END;
    
    PROCEDURE update_furnizor(nume in furnizori.nume_furnizor%TYPE,choice in varchar2, updated in varchar2)
    IS
        e_not_found EXCEPTION;
        e_alegere_invalida EXCEPTION;
    BEGIN
        IF(choice = 'adresa') THEN
            UPDATE furnizori SET adresa=updated WHERE nume_furnizor=nume;
        ELSIF(choice = 'email') then
            UPDATE furnizori SET email=updated WHERE nume_furnizor=nume;
        ELSE
            RAISE e_alegere_invalida;
        END IF;
        IF SQL%NOTFOUND THEN
            RAISE e_not_found;
        END IF;
        EXCEPTION
            WHEN e_not_found THEN RAISE_APPLICATION_ERROR ( -20201 , 'Furnizorul nu exista' );
            WHEN e_alegere_invalida THEN RAISE_APPLICATION_ERROR ( -20201 , 'Alegerea introdusa este invalida!' );
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR ( -20002 , 'Eroare intampinata la acutalizarea furnizorului ' || nume || ': ' || SQLERRM || '.' ) ;
    end;

    PROCEDURE afisare_informatii 
    IS
       cursor crs is
        select * from furnizori;
    BEGIN
        for rec in crs loop
            DBMS_OUTPUT.PUT_LINE(rec.furnizor_id);
            DBMS_OUTPUT.PUT_LINE('      Denumire: ' || rec.nume_furnizor|| ';');
            DBMS_OUTPUT.PUT_LINE('      Adresa: ' || rec.adresa || ';');
            DBMS_OUTPUT.PUT_LINE('      Email: ' || rec.email || ';');
        end loop;
    END;
END furnizori_package;
/

CREATE OR REPLACE PACKAGE librarie_package IS
   PROCEDURE add_librarie (adr in librarie.adresa%TYPE,
        phone in librarie.telefon%TYPE,
        mail in librarie.email%TYPE);
   PROCEDURE update_librarie(lb_id in librarie.librarie_id%TYPE,choice in varchar2, updated in varchar2);
   PROCEDURE afisare_informatii;
END librarie_package;
/
CREATE OR REPLACE PACKAGE BODY librarie_package AS
    PROCEDURE add_librarie (adr in librarie.adresa%TYPE,
        phone in librarie.telefon%TYPE,
        mail in librarie.email%TYPE) is 
    begin
        insert into librarie(adresa, telefon, email) values(adr, phone, mail);
    exception
        when DUP_VAL_ON_INDEX then RAISE_APPLICATION_ERROR ( -20001 , 'Numarul de telefon exista deja!' ) ;
    end;
    
     PROCEDURE update_librarie(lb_id in librarie.librarie_id%TYPE,choice in varchar2, updated in varchar2) 
     is
        e_bad_choice EXCEPTION;
     begin
            if(choice = 'adresa') then
                update librarie set adresa=updated where librarie_id=lb_id;
            elsif(choice = 'telefon') then
                update librarie set telefon=updated where librarie_id=lb_id;
            elsif (choice = 'email') then
                update librarie set email=updated where librarie_id=lb_id;
            else
                RAISE e_bad_choice;
            end if;
            IF SQL %NOTFOUND THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Libraria nu exista' ) ;
            END IF;
        exception
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Alegerea introdusa este invalida!' );
            when DUP_VAL_ON_INDEX then RAISE_APPLICATION_ERROR ( -20001 , 'Introducere de valoare duplicata!' ) ;
        end;
    PROCEDURE afisare_informatii 
    IS
        cursor crs is
            select * from librarie;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID      ADRESA                  TELEFON     EMAIL      ');
        for rec in crs loop
            DBMS_OUTPUT.PUT_LINE(rec.librarie_id ||'    ' || rec.adresa || '    ' || rec.telefon || '   ' || rec.email);
        end loop;
    END;
END librarie_package;
/

create or replace PACKAGE produse_package IS

    PROCEDURE add_produs (nume in produse.nume_produs%TYPE,
        pret_produs in produse.pret%TYPE,
        cantitate in produse.cantitate_disponibila%TYPE,
        furnizor in furnizori.nume_furnizor%TYPE);
    PROCEDURE delete_produs(prod_id in produse.produs_id%TYPE);
    PROCEDURE update_produs_name(prod_id in produse.produs_id%TYPE,name in produse.nume_produs%TYPE);
    PROCEDURE update_produs_pret(prod_id in produse.produs_id%TYPE,pret_prod in produse.pret%TYPE);
    PROCEDURE update_produs_cantitate(prod_id in produse.produs_id%TYPE,cant in produse.cantitate_disponibila%TYPE);
    PROCEDURE restock(prod_id in produse.produs_id%TYPE,cant in produse.cantitate_disponibila%TYPE);
    PROCEDURE afisare_informatii;

END produse_package;
/
create or replace PACKAGE BODY produse_package AS
    PROCEDURE add_produs (nume in produse.nume_produs%TYPE,
        pret_produs in produse.pret%TYPE,
        cantitate in produse.cantitate_disponibila%TYPE,
        furnizor in furnizori.nume_furnizor%TYPE) 
    IS 
        -- selectare identificator furnizor din tabela dupa denumirea furnizorului
        cursor get_furnizor is
            select furnizor_id from furnizori
                where nume_furnizor = furnizor;
        furn_id furnizori.furnizor_id%TYPE;

        e_furnizor_not_found EXCEPTION;
    BEGIN
        OPEN get_furnizor;
        FETCH get_furnizor INTO furn_id;
        CLOSE get_furnizor;
        IF furn_id IS NULL THEN
            RAISE e_furnizor_not_found;
        END IF;
        insert into produse(nume_produs, pret, cantitate_disponibila, furnizor_id)  values(nume, pret_produs , cantitate, furn_id);
        EXCEPTION
            WHEN e_furnizor_not_found THEN  RAISE_APPLICATION_ERROR ( -20201 , 'Furnizorul cautat nu exista!' );
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20002, 'Eroare in introducerea produsului ' || nume ||': ' || SQLERRM);
    END;

    PROCEDURE delete_produs(prod_id in produse.produs_id%TYPE) is
        begin
            delete from detalii_vanzare 
                where produse_produs_id = prod_id;
            delete from produse where produs_id=prod_id; 
            IF SQL%NOTFOUND THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Produsul ' || prod_id || ' nu exista!' ) ;
            END IF ;
        end;

    PROCEDURE update_produs_name(prod_id in produse.produs_id%TYPE, name in produse.nume_produs%TYPE) is
        begin
            update produse set nume_produs=name where produs_id=prod_id;
            IF SQL %NOTFOUND THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Produsul ' || prod_id || ' nu exista!' ) ;
            END IF;
        end;

    PROCEDURE update_produs_pret(prod_id in produse.produs_id%TYPE,pret_prod in produse.pret%TYPE) is
        begin
            update produse set pret=pret_prod where produs_id=prod_id;
            IF SQL %NOTFOUND THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Produsul ' || prod_id || ' nu exista!' ) ;
            END IF;
        end;

    PROCEDURE update_produs_cantitate(prod_id in produse.produs_id%TYPE,cant in produse.cantitate_disponibila%TYPE) is
        begin
            update produse set cantitate_disponibila=cant where produs_id=prod_id;
            IF SQL %NOTFOUND THEN
                RAISE_APPLICATION_ERROR ( -20201 , 'Produsul ' || prod_id || ' nu exista!' ) ;
            END IF;
        end;
    
    PROCEDURE restock(prod_id in produse.produs_id%TYPE,cant in produse.cantitate_disponibila%TYPE)
    IS
    BEGIN
        UPDATE produse SET cantitate_disponibila = cantitate_disponibila + cant WHERE produs_id=prod_id;
        IF SQL %NOTFOUND THEN
            RAISE_APPLICATION_ERROR ( -20201 , 'Produsul ' || prod_id || ' nu exista!' ) ;
        END IF;
    END;
    
    PROCEDURE afisare_informatii
    IS
        cursor crs is
            select * from produse;
        cursor furnizor(id furnizori.furnizor_id%TYPE) is 
            select nume_furnizor from furnizori where furnizor_id = id;
        v_denumire furnizori.nume_furnizor%TYPE;
    BEGIN
        for rec in crs loop
            DBMS_OUTPUT.PUT_LINE(rec.produs_id || '. ' || rec.nume_produs);
            DBMS_OUTPUT.PUT_LINE('       Pret: ' || rec.pret|| ';');
            DBMS_OUTPUT.PUT_LINE('       Cantitate: ' || rec.cantitate_disponibila|| ';');
            open furnizor(rec.furnizor_id);
            fetch furnizor into v_denumire;
            close furnizor;
            DBMS_OUTPUT.PUT_LINE('       Furnizor: ' || v_denumire|| '.');
        end loop;
    END;

END produse_package;
/

CREATE OR REPLACE PACKAGE vanzare_package IS

    PROCEDURE add_vanzare (data_curenta in vanzare.data%TYPE,
        id_angajat in vanzare.angajat_id%TYPE,
        id_client in vanzare.client_id%TYPE);
    PROCEDURE add_product_to_cart(
        prod_id in detalii_vanzare.produse_produs_id%TYPE,
        cantitate in detalii_vanzare.cantitate_cumparata%TYPE);
    PROCEDURE delete_vanzare(bon in vanzare.nr_bon%TYPE);
    FUNCTION get_total(nr_bon IN vanzare.nr_bon%TYPE) RETURN NUMBER;
    PROCEDURE afisare_informatii;
    PROCEDURE update_cantitate_produs(p_nr_bon IN vanzare.nr_bon%TYPE,
                                      p_prodid IN produse.produs_id%TYPE,
                                     p_cant IN produse.cantitate_disponibila%TYPE);
    PROCEDURE delete_product_from_vanzare(
        bon IN vanzare.nr_bon%TYPE,
        product IN detalii_vanzare.produse_produs_id%TYPE);
END vanzare_package;
/
CREATE OR REPLACE PACKAGE BODY vanzare_package AS
   PROCEDURE add_vanzare (data_curenta IN vanzare.data%TYPE,
        id_angajat IN vanzare.angajat_id%TYPE,
        id_client IN vanzare.client_id%TYPE)
    IS
        cursor c1 is select nr_card from client where client_id=id_client;
        v_card vanzare.nr_card%TYPE;
        v_nume angajat.nume_angajat%TYPE;
        e_client_not_found EXCEPTION;
        e_angajat_not_found EXCEPTION;

    BEGIN
        OPEN c1;
        FETCH c1 INTO v_card;
        IF v_card IS NULL THEN
            RAISE e_client_not_found;
        END IF;
        SELECT nume_angajat INTO v_nume FROM angajat WHERE angajat_id=id_angajat;
        IF v_nume IS NULL THEN
            RAISE e_angajat_not_found;
        END IF;
        INSERT INTO vanzare(data, angajat_id, client_id, nr_card) VALUES(data_curenta, id_angajat, id_client, v_card);  
        CLOSE c1;
        EXCEPTION
            WHEN e_client_not_found THEN RAISE_APPLICATION_ERROR( -20201, 'Clientul nu exista' );
            WHEN e_angajat_not_found THEN RAISE_APPLICATION_ERROR( -20201, 'Angajatul nu exista' );
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20002, 'Eroare in crearea vanzarii pentru clientul ' || id_client ||' cu angajatul '|| id_angajat ||': ' || SQLERRM);
    END;
    
    PROCEDURE add_product_to_cart(prod_id IN detalii_vanzare.produse_produs_id%TYPE,
        cantitate IN detalii_vanzare.cantitate_cumparata%TYPE) 
        IS
        BEGIN
            INSERT INTO detalii_vanzare(produse_produs_id, vanzare_nr_bon, cantitate_cumparata, pret_final) 
                VALUES(prod_id, vanzare_nr_bon_seq.CURRVAL, cantitate, 0.0);
            EXCEPTION
                WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20002, 'Eroare la adugarea produsului in vanzare: ' || SQLERRM);
        END;
    
    PROCEDURE delete_vanzare(bon IN vanzare.nr_bon%TYPE)
    IS
    BEGIN 
        DELETE FROM detalii_vanzare WHERE vanzare_nr_bon=bon;
        DELETE FROM vanzare WHERE nr_bon=bon;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR ( -20201 , 'Bonul nu exista' ) ;
        END IF ;
    end;
    
    PROCEDURE delete_product_from_vanzare(
        bon IN vanzare.nr_bon%TYPE,
        product IN detalii_vanzare.produse_produs_id%TYPE)
    IS
    BEGIN
        DELETE FROM detalii_vanzare WHERE produse_produs_id=product and vanzare_nr_bon=bon;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR ( -20201 , 'Produsul nu exista pe bon!' ) ;
        END IF ;
    end;
    
    FUNCTION get_total(nr_bon IN vanzare.nr_bon%TYPE)
    RETURN NUMBER
    IS 
        cursor detalii is 
            select sum(pret_final) from detalii_vanzare where vanzare_nr_bon=nr_bon;
        pret detalii_vanzare.pret_final%TYPE;
        result NUMBER;
    BEGIN
        OPEN detalii;
        FETCH detalii into pret;
        CLOSE detalii;
        IF pret IS NULL THEN
            RAISE_APPLICATION_ERROR ( -20201 , 'Bonul nu exista!' ) ;
        END IF;
        result := pret; 
        RETURN (result);
    END;
    
    
    PROCEDURE afisare_informatii
    IS
        cursor crs is
            select * from vanzare;
        cursor crs2(bon vanzare.nr_bon%TYPE) is
            select produse_produs_id, cantitate_cumparata, pret_final from detalii_vanzare where vanzare_nr_bon=bon;
        cursor nume_prod(prodid produse.produs_id%TYPE)
            is select nume_produs from produse where produs_id=prodid;
        cnt NUMBER;
        v_nume_produs produse.nume_produs%TYPE;
    BEGIN
        for rec in crs loop
            DBMS_OUTPUT.PUT_LINE(rec.nr_bon);
            DBMS_OUTPUT.PUT_LINE('      Data: ' || rec.data|| ';');
            DBMS_OUTPUT.PUT_LINE('      Angajat: ' || rec.angajat_id|| ';');
            DBMS_OUTPUT.PUT_LINE('      Client: ' || rec.client_id|| ';');
            for rec2 in crs2(rec.nr_bon) loop
                open nume_prod(rec2.produse_produs_id);
                fetch nume_prod into v_nume_produs;
                close nume_prod;
                DBMS_OUTPUT.PUT_LINE('      Denumire produs: ' || v_nume_produs|| ';');
                DBMS_OUTPUT.PUT_LINE('          - Cantitate: ' || rec2.cantitate_cumparata || ';');
                DBMS_OUTPUT.PUT_LINE('          - Pret: ' || rec2.pret_final || '.');
                exit when crs2%NOTFOUND;
            end loop;
        end loop;
    END;

    PROCEDURE update_cantitate_produs(p_nr_bon IN vanzare.nr_bon%TYPE,
                                      p_prodid IN produse.produs_id%TYPE,
                                     p_cant IN produse.cantitate_disponibila%TYPE)
    IS
        e_not_found exception;
    BEGIN
        update detalii_vanzare set cantitate_cumparata=p_cant
            where vanzare_nr_bon = p_nr_bon and produse_produs_id = p_prodid;
        IF SQL%NOTFOUND THEN
            RAISE e_not_found;
        END IF;
        EXCEPTION
            WHEN e_not_found THEN RAISE_APPLICATION_ERROR ( -20201 , 'Inregistrarea nu exista' );
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR ( -20002 , 'Eroare intampinata la acutalizarea cantitatii produslui ' || p_prodid || ': ' || SQLERRM || '.' ) ;
    END update_cantitate_produs;
END vanzare_package;
/

create or replace procedure client_transaction
(data IN vanzare.data%TYPE,
 angajat_id IN angajat.angajat_id%TYPE,
 nume IN client.nume_client%TYPE,
 cnp IN client.cnp_client%TYPE,
 nr_card IN client.nr_card%TYPE,
 telefon IN client.telefon%TYPE,
 adresa IN client.adresa%TYPE,
 card_fidelitate IN client.card_fidelitate%TYPE,
 produs IN produse.produs_id%TYPE,
 cant IN produse.cantitate_disponibila%TYPE,
 pret_final OUT produse.pret%TYPE
)
IS
BEGIN
  SAVEPOINT my_savepoint;
  BEGIN
    client_package.add_client(nume, cnp, nr_card, telefon, adresa, card_fidelitate);    
    vanzare_package.add_vanzare(data, angajat_id, client_client_id_seq.CURRVAL);
    vanzare_package.add_product_to_cart(produs, cant);
    pret_final := vanzare_package.get_total(vanzare_nr_bon_seq.CURRVAL);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO my_savepoint;
      DBMS_OUTPUT.PUT_LINE('Eroare in executarea tranzactiei: ' || SQLERRM);
  END;
END;
/

create or replace procedure delete_product_from_bon
(p_nr_bon detalii_vanzare.vanzare_nr_bon%TYPE,
 p_prodid detalii_vanzare.produse_produs_id%TYPE)
 is
    v_qty_cumparata detalii_vanzare.cantitate_cumparata%TYPE;
 begin
    SAVEPOINT my_savepoint;
    begin
    --  selectez cantitatea cumparata de pe bon 
        select cantitate_cumparata into v_qty_cumparata
            from detalii_vanzare 
                where produse_produs_id = p_prodid and vanzare_nr_bon = p_nr_bon;
    -- sterg produsul de pe bon
        vanzare_package.delete_product_from_vanzare(p_nr_bon, p_prodid);
    --  actualizez stocul produsul care a fost eliminat de pe bon
        produse_package.restock(p_prodid, v_qty_cumparata);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            ROLLBACK TO my_savepoint;
            DBMS_OUTPUT.PUT_LINE('Bonul sau produsul nu exista!');

        WHEN OTHERS THEN
            ROLLBACK TO my_savepoint;
            DBMS_OUTPUT.PUT_LINE('Eroare in executarea tranzactiei: ' || SQLERRM);
    end;
 end;
/
