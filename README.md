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

# RX module
Am gandit implementarea acestuia sub forma unui automat finit de stari (FSM). Principala problema este cum citesc bitul de start si urmatorii biti.  
Vrem ca bitul de start sa fie citit la jumate adica dupa 7 tick uri iar urmatorii biti la 15 tickuri dupa ce a fost citit primul. Astfel citim mereu la mijlocul bitului curent.  
  
Codarea se realizeaza astefl incat conversia sa inceapa atunci cand se primeste un 0L valid, adica cand la jumatatea bitului de start conversie este tot 0 ca la inceput, daca nu este , inseamna ca a fost o perturbatie/zgomot.Asemanator si in cazul bitului de stop unde se asteapta 1L. Pana atunci automatul este in starea IDLE si nu se intampla nimic.  
Primi 0L-->Citim dupa 7 tick-uri bitul de start-->Citim dupa 15 tick-uri de 8 ori --> Citim  dupa alte 15 tick uri bitul de stop --> se genereaza un semnal de done (un impuls de 1L) .  


Starea idle
- aici sta pana primeste un 0
  
Starea de start  

- numara 7 tickuri
- daca inca este 0 dupa 7 tickuri intra in starea de receptie, inseamna ca bitul de start a fost receptionat corect
- avem nevoie de un counter intern care numara tick urile , in cazul acestei stari pana la 7 , iar dupa aceea se reseteaza , il numesc tick_count  

Starea de receptie
- tick_count e resetat la 0 
- aici avem nevoie de un counter care numara nr de biti de date , il numesc bit_count, acesta numara pana la 8, momentan, pana voi parametriza tot
- bit_count se incrementeaza de fiecare data cand tick_count ajunge la 15
- tick_count==15 -> se reseteaza, bit_count -> bit_count + 1
- cand bit_count==8 se intra in starea de stop
- avem nevoie si de un registru de shiftare in care intra fiecare bit de la msb catre lsb
- prima oara este transmis lsb catre msb al shiftreg

Starea de stop
- bit_count se reseteaza la 0 si cand tick_count ajunge iar la 15 se verifica daca bitul de stop e 1 se da un impuls de done
-  in registrul de date de iesire nu se mai adauga nimic ,
-  tick_ count se reseteaza si el si ne intoarcem in starea idle,
-  daca nu e 1 bitul de stop, ci 0 ne intoarcem in idle fara a da sgn de done

# TESTBENCH RX  
Pentru a putea citi un bit din byte ul de date trebuie sa asteptam 104166 ns, pentru un BaudRate de 9600 si o frecventa de clock de 100MHz, unde perioada ceasului e 10ns.
Problema:
In simulare nu ruleaza asa cum trebuie , chiar daca se asteapta destul timp pentru citirea corecta. 
Am verificat conditiile initiale :   
    reset<=1;   
    s_tick<=0;   
    rx<= 1'b0;   
  Tot sistemul a fost resetat .   
  S_tick este 0 initial si trebuie sa fie un impuls care se repeta in timpul citirii unui bit de 16 ori conform logicii modulului rx.   
  Citirea incepe atunci cand rx este 0 , conditie setata in conditiile initiale.    




