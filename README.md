# UART
UART loopback + logger interactiv cu counter binar si PUTTY  

 # Etapa 1 — UART Loopback (TX + RX) 
În această etapă am implementat și verificat modulele UART de bază. Scopul este să demonstrez că tot ce trimit
din PuTTY  vine înapoi corect pe același terminal.
In aceasta configuratie depindem doar de   
  - nr de biti
  - bitul de start
  - bitul de stop,
nu si de clock, fiind o interfata de comunicare seriala putem avea clock diferit, insa RX si TX trebuir totusi sa fie in concordanta in ceea ce priveste Baud-Rate ul , adica cati biti se transmit si se receptioneaza pe secunda. Altfel, apar erori de sincronizare si transmisie.  
Am inceput realizarea temei facand schema de baza si conexiunea loopback : pulsul de done al RX este puls de start pentru TX, iar iesirea rx_dataout al RX este intrarea tx_datain pentru TX . Baud Rate generator-ul genereaza un semnal de done care devine semnal de enable pentru citirea si manipularea bitului curent.
Pinii rx al RX si tx al TX sunt conectate la PC. Prin rx intra caracterul primit de la PC iar prin tx se intoarce caracterul la PC. La scrierea unui caracter in Putty , acest circuit trebuie sa returneze inapoi in consola acelasi caracter.
 # BaudRate Module
Din punct de vedere structural acesta are un semnal de reset, semnal de clock si o iesire done care genereaza un impuls de 1L care devine semnal de enable pentru citirea si manipularea bitului curent ale RX si TX. Are de asemenea un parametru intern Final_Value care trebuie ales cu atentie pentru procesul de Oversampling 16x.     

Conceptul de oversampling:  
Uartul primeste un bit de date si pentru a-l citi fara erori cauzate de zgomot sau nesincronizari (variatii rapide de 0 si 1 ) avem nevoie de o metoda de a citi bitul fix la mijloc. Aceasta metoda se numeste oversampling 16x si imparte bitul in 16 segmente egale pe care le vom numi ticks, iar noi vrem sa citim bitul la tick ul 7 (adica la mijloc). Cele 16 segmente reprezinta durata unui bit- o perioada. Durata unui segmen din cele 16 segmente este 1/16xb, unde b este viteza in bit/sec sau BaudRate ul.  
Intern, BaudRate generator-ul foloseste un counter care dupa fiecare segment genereaza un tick si se freseteaza la 0. Acesta numara pentru fiecare segment de la 0 la final_value. Counterul este sincronizat la frecventa sistemului in cazul nostru 100MHz . Prin urmare Final_Value trebuie calculat in functie de frecventa sistemului , pentru a avea baud-rate ul dorit.Timpul total de care are nevoie numaratorul (ciclii de ceas) pt a finaliza un ciclu complet de numarare , adica pana la Final_Value este (F.V. +1)xT unde T este perioada ceasului de sistem. Acest timp total trebuie sa fie egal cu durata unui segmen / tick (latimea intervalului pt oversampling) de care are nevoie UART ul. Acesta este modul in care am gandit sincronizarea uartului cu placa de dezvoltare.  




