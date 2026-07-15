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

