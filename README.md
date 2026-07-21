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
  Rezolvare:
  rx trebuie sa fie 1 initial altfel primeste "incepe conversia" pe reset activ.    
  Tinem reset activ si pe rx pe 1 pentru starea idle in care asteapta conversia pana cand resetul e inactiv.    
 In codul initial s_tick era 1 la transmisia fiecarui bit. Nu se schimba , am tinut totul pe 1 ca sa treaca prin stari pentru ca in modulul lui rx intram in bucla cu starile doar pt s_tick e 1, deci a fost o confuzie deoarece trebuie sa numere pana la 15 pentru fiecare bit .  
 Am nevoie de 16 tick uri pe perioada unui bit. Daca unul dureaza 104166ns am nevoie de un tick la fiecare 6500ns, fiecare trebuie sa dureze cat un impuls de ceas -> 10ns.   
Vreau sa transmit 'a' din codul ascii dar codul meu e scris astfel incat se transmite lsb ul prima oara, iar eu in codul initial am transmis msb ul ceea ce ducea la o eroare la rx_dout.
Las reset ul activ timp de 1000 ns si il dezactivez, iar dupa alte 2000 ns trec in rx valoarea 0 pt a incepe conversia.  
Am lasat o perioada de 104166 intre fiecare bit transmis. s_tick se repeta de 16 ori in acest interval de timp intr un bloc separat .  
Am pus si un bloc de stop pentru simulare .

# TX module  
Am abordat metoda inversa a modulului RX. In cazul modulului TX avem un semnal de start, nu de done. In configuratia loopback RX trimite un semnal de done care este interpretat ca semnal de start pentru procesul de transmisie. Cand a fost receptionat tot setul de date, TX primeste semnal de start / enable pentru inceperea transmisiei.

IDLE:  
Pe tx avem 1L, pentru a mentine starea de IDLE (fata de modulul rx unde asteptam sa primim de la intrare , aici trebuie sa fortam iesirea,  deoarece transmisia se face asincron)   
La semnalul de start acesta muta ce se afla la intrarea tx_datain (ce se afla la iesirea rx_dataout) intr_un registru intern denumit shiftreg, ca in cazul modulului RX si schimba starea in starea de START  


START  
Avem nevoie sa fortam un bit de start pentru iesirea tx : 0L si pentru a putea incepe transmisia bit cu bit.
Dupa ce au trecut 15 batai de ceas , adica dupa ce am terminat transmiterea primului bit de start ,intram in starea de TRANSMISIE. 
La RX am asteptat sa citim bitul la jumatate pentru sincronizare si sa nu avem probleme cu zgomotul, in acest caz asteptam 15 tick uri deoarece transmisia se realizeaza asincron si doar duce mai departe ceea ce a primit de la rx.   


TRANSMISIE:
In aceasta stare incepem transmiterea catre PC bit cu bit incepand cu LSB ul. Bit_count numara intern la ce bit am ajuns , si in tx este transpus bitul din shiftreg de pe pozitia specificata de bit_count. Cand bit_count ajunge la numarul maxim, adica la MSB , acesta se reseteaza la 0 si intra in starea de stop. 


STOP: 
In starea de Stop, transmisia tuturor bitilor de date este incheiata si trebuie sa fortam iesirea in 1 pentru a reveni in starea idle si pentru a semnaliza bitul de STOP(finalul transmisiei).

 # PARAMETRIZARE module 
Am parametrizat modulele astfel incat sa poata fi transmise si receptionate date de diferite dimensiuni, avand in vedere si etapa a 2 a in care modulul va trebui sa primeasca date pe 16 biti de la counter.
Parametrizate au fost : nr de biti, frecventa de ceas, baud rate ul , iar final value se adapteaza automat din interiorul modulului BaudRate .
  # PARAMETRIZARE TETBENCH
 Am modificat testbenchurile incat sa fie si ele parametrizabile definind niste parametrii locali
    localparam BITS =8;
    localparam BaudRate= 9600;
    localparam BitPeriod=1000000000/BaudRate;
    localparam TickWait= BitPeriod/16;
    
La inceput testbenchul nu functiona deoarece am pus BitPeriod= 1/BaudRate. Aceasta forma era gresita deoarece nu am tinut cont de unitatea de timp care este in nanosecunde, iar BaudRateul se masoara in bit/secunda. Dupa ce am transformat 1s in ns a functionat.






  




