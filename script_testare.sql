-- actualizare informatii librarie + afisare informatii before and after
execute librarie_package.afisare_informatii;
/
execute librarie_package.update_librarie(100, 'email', 'librarie_new@yahoo.com');
/
execute librarie_package.afisare_informatii;
/



-- testare proceduri din pachetul angajat_package
execute angajat_package.afisare_informatii;
/
accept nume prompt 'Nume=';
accept cnp prompt 'CNP=';
accept adresa prompt 'Adresa=';
accept telefon prompt 'Telefon=';
accept mail prompt 'Email=';

execute angajat_package.add_employee('&nume', '&cnp', '&adresa', '&telefon', '&mail');
/
execute angajat_package.afisare_informatii;
/
execute angajat_package.delete_employee(28);
/
execute angajat_package.afisare_informatii;
/
accept choice prompt 'Alege valoare de modificat(cnp, adresa, telefon, email)=';
accept updated prompt 'Voi pune: ';
execute angajat_package.update_employee(27, '&choice', '&updated');
/
execute angajat_package.afisare_informatii;
/

-- testare pachet client_package
execute client_package.afisare_informatii;
/
accept nume prompt 'Nume=';
accept cnp prompt 'CNP=';
accept nr_card prompt 'Numar card=';
accept telefon prompt 'Telefon=';
accept adresa prompt 'Adresa=';
accept card_fidelitate prompt 'Card de fidelitate?=';

execute client_package.add_client('&nume', '&cnp', &nr_card, '&telefon', '&adresa', &card_fidelitate);
/
execute client_package.afisare_informatii;
/
accept cnp prompt 'CNP=';
execute client_package.delete_client('&cnp');
/
execute client_package.afisare_informatii;
/
accept identif prompt 'ID client:';
accept choice prompt 'Alege valoare de modificat(cnp, adresa, telefon)=';
accept updated prompt 'Voi pune: ';

execute client_package.update_client(&identif, '&choice', '&updated');
/
execute client_package.afisare_informatii;
/


-- testare pachet furnizori_package
execute furnizori_package.afisare_informatii;
/
accept nume prompt 'Nume=';
accept adresa prompt 'Adresa=';
accept email prompt 'Email=';
execute furnizori_package.add_furnizor('&nume', '&adresa', '&email');
/
execute furnizori_package.afisare_informatii;
/
accept nume prompt 'Nume=';
accept choice prompt 'Alege valoare de modificat(email, adresa)=';
accept updated prompt 'Voi pune: ';
execute furnizori_package.update_furnizor('&nume', '&choice', '&updated');
/
execute furnizori_package.afisare_informatii;
/
accept nume prompt 'Nume=';
execute furnizori_package.delete_furnizor('&nume');
/
execute furnizori_package.afisare_informatii;
/

-- testare pachet vanzare_package
execute vanzare_package.afisare_informatii;
/
execute vanzare_package.add_vanzare(to_date('01.06.2022', 'dd-mm-yyyy'), 22, 10);
/
execute vanzare_package.afisare_informatii;
/
execute vanzare_package.add_product_to_cart(220, 2);
/
execute vanzare_package.afisare_informatii;
/
execute vanzare_package.delete_vanzare(205);
/
execute vanzare_package.afisare_informatii;
/
VARIABLE res NUMBER;
EXECUTE :res := vanzare_package.get_total(190);
PRINT res;

execute delete_product_from_bon(190, 205);
/
execute vanzare_package.afisare_informatii;
/
execute vanzare_package.update_cantitate_produs(235, 115, 3);
/
execute vanzare_package.afisare_informatii;


-- testare pachet produse_package
execute produse_package.afisare_informatii;
/
accept nume prompt 'Nume=';
accept pret prompt 'Pret=';
accept cantitate prompt 'Cantitate=';
accept furnizor prompt 'Furnizor=';
execute produse_package.add_produs('&nume', &pret, &cantitate, '&furnizor');
/
execute produse_package.afisare_informatii;
/
execute produse_package.update_produs_cantitate(250, 60);
/
execute produse_package.afisare_informatii;
/
execute produse_package.update_produs_pret(250, 25.0);
/
execute produse_package.afisare_informatii;
/
execute produse_package.update_produs_name(250, 'Culegere mate');
/
execute produse_package.afisare_informatii;
/
execute produse_package.delete_produs(235);
/
execute produse_package.afisare_informatii;
/

-- inserare client + creare bon + adaugare produse + afisare total
VARIABLE pret_final NUMBER;
execute client_transaction(to_date('01.06.2022', 'dd-mm-yyyy'), 23, 'Sorina Ruscanu', '6000721270016', 1234567893443443, '0719193465', 'Pacurari', 1, 130, 2, :pret_final);
print pret_final; 


-- stergere produs de pe un bon utilizand procedura delete_product_from_bon
savepoint mysvp;
VARIABLE res NUMBER;
EXECUTE :res := vanzare_package.get_total(235);
PRINT res;

execute delete_product_from_bon(235, 160);
/
EXECUTE :res := vanzare_package.get_total(235);
PRINT res;

rollback to mysvp;