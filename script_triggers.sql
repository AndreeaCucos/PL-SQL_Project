CREATE OR REPLACE TRIGGER trg_Angajat_nume 
    BEFORE INSERT OR UPDATE ON Angajat 
    FOR EACH ROW 
BEGIN
	IF(INSTR(:new.nume_angajat, ' ')=0)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Forma numelui nu este corecta!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Client_cnp 
    BEFORE INSERT OR UPDATE ON Client 
    FOR EACH ROW 
BEGIN
	IF( ADD_MONTHS( TO_DATE(  substr(:new.cnp_client, 6, 2) ||'.'||substr(:new.cnp_client, 4, 2) || '.' || case when substr(:new.cnp_client, 2, 2) > 21 then 19 || substr(:new.cnp_client, 2, 2) else 20||substr(:new.cnp_client, 2, 2) end, 'DD-MM-YYYY'), 168) > TRUNC(SYSDATE)) 
	THEN 
		RAISE_APPLICATION_ERROR(-20950, 'Clientul nu are varsta necesara pentru a cumpara din librarie!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Client_nume 
    BEFORE INSERT OR UPDATE ON Client 
    FOR EACH ROW 
BEGIN
	IF(INSTR(:new.nume_client, ' ')=0)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Forma numelui nu este corecta!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Detalii_angajat_cnp 
    BEFORE INSERT OR UPDATE ON Detalii_angajat 
    FOR EACH ROW 
BEGIN
	IF( ADD_MONTHS( TO_DATE(  substr(:new.cnp_angajat, 6, 2) ||'.'||substr(:new.cnp_angajat, 4, 2) || '.' || case when substr(:new.cnp_angajat, 2, 2) > 21 then 19 || substr(:new.cnp_angajat, 2, 2) else 20||substr(:new.cnp_angajat, 2, 2) end, 'DD-MM-YYYY'), 216) > TRUNC(SYSDATE)) 
	THEN 
		RAISE_APPLICATION_ERROR(-20950, 'Angajatul nu are varsta necesara pentru a lucra in librarie!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Detalii_vanzare_reduceri 
    BEFORE INSERT ON Detalii_vanzare 
    FOR EACH ROW 
BEGIN
	declare
	   p  produse.pret%type;
	   idp  detalii_vanzare.produse_produs_id%type;
	   bon  detalii_vanzare.vanzare_nr_bon%type;
	   idx  produse.produs_id%type;
	   idc  vanzare.client_id%type;
	   c    client.card_fidelitate%type;
	   d    vanzare.data%type;
	   cnt  detalii_vanzare.cantitate_cumparata%type;
	   cntd  produse.cantitate_disponibila%type;
	begin
	    idp := :new.produse_produs_id;
	    bon := :new.vanzare_nr_bon;
	    cnt := :new.cantitate_cumparata;
	    select pret into p from produse where idp=produse.produs_id;

	    select client_id into idc from vanzare where bon=vanzare.nr_bon;
	    select card_fidelitate into c from client where idc=client.client_id;
	    
	    select cantitate_disponibila into cntd from produse where idp=produse.produs_id;
	    
	    select data into d from vanzare where bon=vanzare.nr_bon;
	    
	    select produs_id into idx from produse where nume_produs='XEROX';
	    if( idp != idx)
	    then
	        p := p * cnt;
	        :new.pret_final := p;
	        update produse set cantitate_disponibila = cntd - cnt where idp=produse.produs_id;
	    else
	        p := p * cnt;
	        :new.pret_final := p;
	    end if;
	    if(c = 1)
	    then
	        p := p - p * 0.2;
	        if(p = 0)
	        then
	            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
	            :new.pret_final := 1;
	        else
	            :new.pret_final := p;
	        end if;
	    else
	        :new.pret_final := p;
	    end if;
	    
	    if( to_char(d, 'dd-mm') = to_char(to_date('01.06.2021', 'dd-mm-yyyy'), 'dd-mm'))
	    then
	        p := p - p * 0.5;
	        if(p = 0)
	        then
	            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
	            :new.pret_final := 1;
	        else
	            :new.pret_final := p;
	        end if;
	    else
	        :new.pret_final := p;
	    end if;
	    
	end;
END; 
/

CREATE OR REPLACE TRIGGER trg_Vanzare_data 
    BEFORE INSERT OR UPDATE ON Vanzare 
    FOR EACH ROW 
BEGIN
	IF(:new.data > SYSDATE)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Data bonului e incorecta!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER update_dt_vz 
    BEFORE UPDATE OF cantitate_cumparata ON Detalii_vanzare 
    FOR EACH ROW 
declare
    v_bon vanzare.nr_bon%TYPE;
    v_old_qty produse.cantitate_disponibila%TYPE;
    v_new_qty produse.cantitate_disponibila%TYPE;
    v_prodid produse.produs_id%TYPE;
    v_client_id client.client_id%TYPE;
    v_fidelitate client.card_fidelitate%TYPE;
    
    v_pret produse.pret%TYPE;
    v_total produse.pret%TYPE;
    
    v_xerox_id produse.produs_id%TYPE;
    v_data vanzare.data%TYPE;
    
    e_same_qty exception;
begin
    v_bon := :old.vanzare_nr_bon;
    v_old_qty := :old.cantitate_cumparata;
    v_new_qty := :new.cantitate_cumparata;
    v_prodid := :old.produse_produs_id;
--    extrag data
    select data into v_data from vanzare where nr_bon = v_bon;
-- extrag informatiile despre client
    select client_id into v_client_id from vanzare where nr_bon = v_bon;
    select card_fidelitate into v_fidelitate from client where client_id = v_client_id;
    
-- selectez identificatorul produsului xerox
    select produs_id into v_xerox_id from produse where nume_produs='XEROX';
    
    
-- selectez pretul produsului
    select pret into v_pret from produse where produs_id = v_prodid;

-- recalculez valoarea produsului
-- daca a cumparat o cantitate mai mare decat cea pe care o avea din nou vine pret * (v_new_qty - v_old_qty)
    v_total := v_pret * v_new_qty;
    
    if(v_fidelitate = 1 ) then
        v_total := v_total - v_total * 0.2;
        IF(v_total = 0) THEN
            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
            v_total := 1;
        END IF;
    end if;
    
    IF(TO_CHAR(v_data, 'dd-mm') = TO_CHAR(TO_DATE('01.06.2021', 'dd-mm-yyyy'), 'dd-mm')) THEN
        v_total := v_total - v_total * 0.5;
        IF(v_total = 0) THEN
            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
            v_total := 1;
        END IF;
    END IF;

--  actualizez tabela produse 
--  daca noua cantitate este mai mare decat cea veche scad cantitatea disponibila de la produs
--  daca este mai mica pun inapoi diferenta dintre cantitatea veche si cea noua 

    if(v_old_qty < v_new_qty) then
        if(v_prodid != v_xerox_id) then
            update produse set cantitate_disponibila = cantitate_disponibila - (v_new_qty - v_old_qty)
                where produs_id = v_prodid;
        end if;
    elsif(v_old_qty > v_new_qty) then
        if(v_prodid != v_xerox_id) then
            update produse set cantitate_disponibila = cantitate_disponibila + (v_old_qty - v_new_qty)
                where produs_id = v_prodid;
        end if;
    end if;
    :new.pret_final := v_total;

end; 
/

