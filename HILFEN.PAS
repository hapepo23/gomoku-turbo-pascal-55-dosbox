unit Hilfen;

{ Die Unit Hilfen stellt einige allgemeine Hilfprogramme
  zur Verfuegung: String-Routinen, Konvertierungsroutinen,
  usw. }

{ Datei in Zei.-Satz IBM850 -> „=84 ”=94 =81 Ž=8E ™=99 š=9A á=E1,
  Zeilenende DOS/Windows -> 0D+0A }


interface


  function WiederholeString (
             inZeichenkette : string;
             inAnzahl : integer) : string;
  { Eine Zeichenkette inZeichenkette inAnzahl-mal wiederholen }

  procedure LoescheTasten;
  { Den Tastaturpuffer loeschen }

  procedure WarteAufTaste;
  { Einen Hinweis ausgeben und auf beliebige Taste warten }

  function IntegerNachString (
             inGanzzahl : integer) : string;
  { Umwandlung einer Ganzzahl inGanzzahl in eine Zeichenkette }

  function IntegerNachStringMitNullen (
             inGanzzahl : integer;
             inLaenge : integer) : string;
  { Umwandlung einer Ganzzahl inGanzzahl in eine Zeichenkette
    mit vorangestellten Nullen mit einer Laenge inLaenge }

  procedure Warten ( inMillisek: integer );
  { Wartet inMillisek Millisekunden ueber einen 'geeichten'
    delay-Befehl }



implementation


  uses
  Crt,
  Dos;




  const
  TESTMILLIS = 200;  { Testwartezeit in ms zur Bestimmung
                       des WartenFaktors; nicht zu lang, da sonst
                       zu hohe Wartezeit zu Programmbeginn :-( }
  DELAYPARM = 10;  { fester Parameter fuer TP-Pascal-Delay (ms);
                     DELAYPARM << TESTMILLIS, sonst ungenaue Zeiten
                     auf alten, langsamen Rechnern }

  var
  WartenFaktor : LongInt;  { Faktor fuer Warten-Routine }





  function WiederholeString (
             inZeichenkette : string;
             inAnzahl : integer) : string;

  { Eine Zeichenkette inZeichenkette inAnzahl-mal wiederholen
    inZeichenkette: Zeichenkette
    inAnzahl: Anzahl Wiederholungen
    Rueckgabewert: die eingegebene Zeichenkette, inAnzahl-mal }

    var
    Ergebnis : string;
    i : integer;

  begin

    Ergebnis := inZeichenkette;
    for i := 2 to inAnzahl do
      Ergebnis := Ergebnis + inZeichenkette;
    WiederholeString := Ergebnis

  end;  { WiederholeString }





  procedure LoescheTasten;

  { Den Tastaturpuffer loeschen }

    var
    Taste : char;

  begin

    while keyPressed do
      Taste := readKey;

  end;  { LoescheTasten }





  procedure WarteAufTaste;

  { Einen Hinweis ausgeben und auf beliebige Taste warten }

  begin

    writeln ('Bitte beliebige Taste druecken...');
    repeat
    until keyPressed;
    LoescheTasten

  end;  { WarteAufTaste }





  function IntegerNachString (
             inGanzzahl : integer) : string;

  { Umwandlung einer Ganzzahl inGanzzahl in eine Zeichenkette
    inGanzzahl: umzuwandelnde Ganzzahl
    Rueckgabewert: Zeichenkette }

    var
    Ergebnis : string;

  begin

    Str (inGanzzahl, Ergebnis);
    IntegerNachString := Ergebnis

  end;  { IntegerNachString }





  function IntegerNachStringMitNullen (
             inGanzzahl : integer;
             inLaenge : integer) : string;

  { Umwandlung einer Ganzzahl inGanzzahl in eine Zeichenkette
    mit vorangestellten Nullen mit einer Laenge inLaenge
    inGanzzahl: umzuwandelnde Ganzzahl
    inLaenge: Laenge der Zeichenkette; falls die
    umzuwandelnde Ganzzahl laenger als inLaenge ist,
    wird eine laengere Zeichenkette zurueckgegeben.
    Rueckgabewert: Zeichenkette
    Beispiel: IntegerNachStringMitNullen(6,4) ergibt '0006' }

    var
    Ergebnis : string;
    Laenge : integer;

  begin

    Str (inGanzzahl, Ergebnis);
    Laenge := length (Ergebnis);
    if Laenge < inLaenge then
      Ergebnis := WiederholeString ('0', inLaenge - Laenge) + Ergebnis;
    IntegerNachStringMitNullen := Ergebnis

  end;  { IntegerNachStringMitNullen }





  function ErmittleWartenFaktor ( inMillisek: integer ) : LongInt;

  { LOKALE HILFSROUTINE:
    Der Delay-Befehl arbeitet in TP ungenau.
    Deshalb wird hier gemessen, wie oft der delay(..)-Befehl
    aufgerufen werden muss, um die gewuenschte
    Verzoegeungsdauer inMillsek zu erzielen.
    inMillisek: Testwartezeit in Millisek (> 200, < 1000)
    Rueckgabewert: Faktor = Anzahl delay(..)-Aufrufe, um etwa
                   inMillisek zu warten. }

    var
    i : LongInt;
    ms1 : LongInt;
    ms2 : LongInt;
    j : word;
    mo : word;
    t1 : word;
    t2 : word;
    wt : word;
    h1 : word;
    h2 : word;
    m1 : word;
    m2 : word;
    s1 : word;
    s2 : word;
    hs1 : word;
    hs2 : word;

  begin

    repeat
      getDate(j, mo, t1, wt);
      i := 0;
      getTime(h1,m1,s1,hs1);
      ms1 := h1 * 3600000 + m1 * 60000 + s1 * 1000 + hs1 * 10;
      repeat
        i := i + 1;
        delay(DELAYPARM);
        getTime(h2,m2,s2,hs2);
        ms2 := h2 * 3600000 + m2 * 60000 + s2 * 1000 + hs2 * 10;
      until abs((ms2 - ms1)) >= inMillisek;
      getDate(j, mo, t2, wt);
    until t1 = t2;  { Tag hat sich nicht geaendert }

    ErmittleWartenFaktor := i;

  end;  { ErmittleDelayFaktor }





  procedure Warten ( inMillisek: integer );

  { Der Delay-Befehl arbeitet in TP ungenau - deshalb diese Ersatzroutine.
    Wartet inMillisek Millisekunden ueber einen via ErmittleWartenFaktor
    'geeichten' delay(..)-Befehl.
    inMillisek: Wartezeit in Millisek (> 0, < 32000) }

    var
    i : LongInt;
    Anzahl : LongInt;

  begin

    Anzahl := (inMillisek * WartenFaktor) div TESTMILLIS;
    for i := 1 to Anzahl do
      delay(DELAYPARM)

  end; {Warten}





begin   { Initialisierung der Unit }


  { Bestimmung des Faktors fuer die Prozedur Warten }
  WartenFaktor := ErmittleWartenFaktor(TESTMILLIS);


end.  { Hilfen }
