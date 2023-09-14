--------------------- LIBRARIE ---------------------------------
execute librarie_package.add_librarie('Aleea Decebal nr 9', '0757772576', 'librarie@yahoo.com');

---------------------ANGAJAT-------------------------------------
execute angajat_package.add_employee('Ana Maria', '6010728270016', '1 Mai', '0754675891', 'anamaria@yahoo.com');
execute angajat_package.add_employee('Maria Ioana',  '6910812270016', 'Aleea Decebal', '0768594632', 'maria@yahoo.com');
execute angajat_package.add_employee('Alexandru Ion','6001123270016', 'Bulevardul Decebal', '0712345678', 'alexandru@yahoo.com');
execute angajat_package.add_employee('Marian Mihai', '6020330270016', 'Bulevardul Stefan', '0765473829', 'marian@yahoo.com');
execute angajat_package.add_employee('Diana Elena', '6010527270016', 'Bulevardul Chimiei', '0785947352', 'diana@yahoo.com');
execute angajat_package.add_employee('Ioana Pascaru', '6000327270016', 'Strada Garii', '0765473645', 'ioana@yahoo.com');
execute angajat_package.add_employee('Bianca Creanga', '6020513270016', 'Aleea Decebal', '0765748392', 'biancac@yahoo.com'); 
execute angajat_package.add_employee('Bogdan Alexandru', '6020510270016', 'Strada Petrodava', '0745628965', 'bogdan@yahoo.com');


------------------------CLIENT----------------------------------------
execute client_package.add_client('Mihai Florin', '6010730270016', 1234567890123456, '0718293456', 'Aleea Decebal', 1);
execute client_package.add_client('Ana Mihaela', '6960829270016', 6578490123456923, '0794756382', 'Soseaua Nationala', 0);
execute client_package.add_client('Mihai Constantin', '6980506270016', 7685903764536728, '0745678904', 'Strada Garii', 1);
execute client_package.add_client('Andreea Bianca', '6990517270016', 7685940375647382, '0786950465', 'Bulevardul Decebal', 0);
execute client_package.add_client('Andrei Bogdan', '6030829270016', 5768594089376582, '0735467283', 'Starada Garii', 1);
execute client_package.add_client('Amalia Ioana', '6010330270016', 5463728907685946, '0745362786', '1 Mai', 0);
execute client_package.add_client('Ioana Bianca', '6020112270016', 6574890243517869, '0754638901', '1 Mai', 1);

------------------------FURNIZORI----------------------------------------

execute furnizori_package.add_furnizor('Pelikan', 'Strada Covaci', 'pelikan@yahoo.com');
execute furnizori_package.add_furnizor('Bic', 'Strada Ilfov', 'bic@yahoo.com');
execute furnizori_package.add_furnizor('Daco', 'Strada Doamnei', 'daco@yahoo.com');
execute furnizori_package.add_furnizor('Herlitx', 'Strada Franceza', 'herlitx@yahoo.com');
execute furnizori_package.add_furnizor('Schneider', 'Centrul Vechi', 'schneider@yahoo.com');
execute furnizori_package.add_furnizor('Castell', 'Starada Garii', 'castell@yahoo.com');
execute furnizori_package.add_furnizor('Centropen', 'Bulevardul Decebal', 'centro@yahoo.com');
execute furnizori_package.add_furnizor('Crayola', 'Bld Gral Dascalescu', 'crayola@yahoo.com');
execute furnizori_package.add_furnizor('Niculescu', 'Aleea Decebal', 'niculescu@yahoo.com');


-------------------------------------------PRODUSE-----------------------------------------------------
execute produse_package.add_produs('Caiet A4', 5.4 , 20, 'Daco');
execute produse_package.add_produs('Stilou', 20, 30, 'Crayola');
execute produse_package.add_produs('Pix', 2.3, 10, 'Bic');
execute produse_package.add_produs('Manual', 15.6, 10, 'Centropen');
execute produse_package.add_produs('Pasta corectoare', 2.4, 12, 'Bic');
execute produse_package.add_produs('Acuarele', 7.8, 9, 'Pelikan');
execute produse_package.add_produs('XEROX', 0.50, 0, 'Daco');
execute produse_package.add_produs('Marker', 2.5, 40, 'Schneider');
execute produse_package.add_produs('Culegere', 18.67, 30, 'Castell');
execute produse_package.add_produs('Bloc de desen', 9.50, 28, 'Centropen');


----------------------------------------VANZARE--------------------------------------------------------


execute vanzare_package.add_vanzare (to_date('18.12.2021', 'dd-mm-yyyy'), 25, 13);  
execute vanzare_package.add_product_to_cart(100, 2);


execute vanzare_package.add_vanzare(to_date('17.10.2021', 'dd-mm-yyyy'), 23, 12);
execute vanzare_package.add_product_to_cart(160,  3);
execute vanzare_package.add_product_to_cart(175,  1);


execute vanzare_package.add_vanzare(to_date('21.05.2023', 'dd-mm-yyyy'), 24, 16);
execute vanzare_package.add_product_to_cart(190, 10);
execute vanzare_package.add_product_to_cart(175,  1);
execute vanzare_package.add_product_to_cart(130, 2);


execute vanzare_package.add_vanzare(to_date('15.10.2022', 'dd-mm-yyyy'), 25, 14);
execute vanzare_package.add_product_to_cart(205,8);


execute vanzare_package.add_vanzare(to_date('01.05.2023', 'dd-mm-yyyy'), 27, 12);
execute vanzare_package.add_product_to_cart(145,3);


execute vanzare_package.add_vanzare(to_date('10.01.2023', 'dd-mm-yyyy'), 26, 15);
execute vanzare_package.add_product_to_cart(235, 1);
execute vanzare_package.add_product_to_cart(190, 5);



execute vanzare_package.add_vanzare(to_date('24.05.2023', 'dd-mm-yyyy'), 25, 16);
execute vanzare_package.add_product_to_cart(205, 4);
execute vanzare_package.add_product_to_cart(235, 1);
execute vanzare_package.add_product_to_cart(190,  1);
execute vanzare_package.add_product_to_cart(160, 3);


execute vanzare_package.add_vanzare(to_date('20.05.2023', 'dd-mm-yyyy'), 21, 11);
execute vanzare_package.add_product_to_cart(160, 3);


execute vanzare_package.add_vanzare(to_date('01.05.2023', 'dd-mm-yyyy'), 20, 12);
execute vanzare_package.add_product_to_cart(205,  2);
