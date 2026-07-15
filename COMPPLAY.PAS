unit CompPlay;

{ Diese Unit ist der Gomoku-Computerspieler. }

{ Datei in Zei.-Satz IBM850 -> „=84 ”=94 =81 Ž=8E ™=99 š=9A á=E1,
  Zeilenende DOS/Windows -> 0D+0A }


interface

  { Dies ist das in der Aufgabenstellung vorgegebene
    Gomoku-Computerspieler-Interface: }

  { Status-Typen }
  type tStatus = ( EINS_AM_ZUG, ZWEI_AM_ZUG,
                   EINS_GEWINNT, ZWEI_GEWINNT, UNENTSCHIEDEN,
                   UNDEFINIERT );

  procedure gibStatus ( var Status: tStatus );
  { Der Status des aktuellen Spiels kann abgefragt werden.
    Am Anfang (ohne neuesSpiel) UNDEFINIERT.
    Nach neuesSpiel EINS_AM_ZUG, spaeter nach setzeStein
    oder ComputerZug entsprechend EINS_AM_ZUG bzw. ZWEI_AM_ZUG.
    Wenn die Partie durch den letzten Zug beendet wurde, dann
    EINS_GEWINNT, ZWEI_GEWINNT oder UNENTSCHIEDEN. }

  procedure neuesSpiel ( var ok: boolean );
  { Ein neues Spiel wird mit den aktuellen Einstellungen begonnen.
    ok = false, falls das aus irgendeinem Grund unmoeglich sein sollte. }

  procedure setzeStein (     x: integer;
                             y: integer;
                         var ok: boolean );
  { Es wird ein Stein auf das Brett gesetzt ( Koordinaten x,y )
    setzeStein kann beliebig oft HINTEREINANDER aufgerufen werden,
    z. B. um eine Stellung auf dem Brett darzustellen.
    Sollte dieser Zug nicht moeglich sein, ist ok = false. }

  procedure computerZug ( var x: integer;
                          var y: integer;
                          var ok: boolean );
  { Der Computer macht einen Zug fuer EINS oder ZWEI, wer grad am Zug ist.
    computerZug kann beliebig oft HINTEREINANDER aufgerufen werden, der
    Computer kann also JEDERZEIT einen Zug fuer die entsprechende Seite
    machen. Sollte kein Zug moeglich sein, ist ok = false. }

  procedure zugZurueck ( var x: integer;
                         var y: integer;
                         var ok: boolean );
  { Die Ruecknahme eines Zuges. ok = false wenn nicht moeglich.
    zugZurueck kann beliebig oft hintereinander aufgerufen werden.
    zugZurueck nimmt NUR EINEN Zug zurueck. }

  procedure zugVor ( var x: integer;
                     var y: integer;
                     var ok: boolean );
  { Ein Zug, der mit zugZurueck zurueckgenommen wurde, wird wieder gesetzt.
    zugVor macht KEINE NEUEN ZUEGE. ok = false, falls kein Zug mehr
    vorhanden ist. zugVor kann beliebig oft aufgerufen werden.
    zugVor setzt NUR EINEN Zug. }

  procedure setzeSpielstufe (     Stufe: integer;
                              var ok: boolean );
  { Die aktuelle Spielstufe des Computers wird gesetzt,
    ok = false bei illegaler Spielstufe.
    Bei Eingabe einer illegalen Spielstufe wird
    die aktuelle Spielstufe beibehalten. }

  procedure gibSpielstufe ( var Stufe: integer );
  { Die aktuelle Spielstufe wird abgefragt.
    Vor dem ersten Aufruf von setzeSpielstufe ist Stufe=2. }

  procedure setzeFeldgroesse (     x: integer;
                                   y: integer;
                               var ok: boolean );
  { Die Groesse des Spielfeldes wird gesetzt. Das Spielfeld ist rechteckig
    und besteht aus x mal y Kaestchen, beide zwischen 5 und 30.
    Bei Erfolg ist der Status = UNDEFINIERT, danach ist neuesSpiel
    notwendig, ok = false bei illegaler Feldgroesse.
    Die aktuelle Feldgroesse wird bei einer
    illegalen Eingabe beibehalten, ebenso der Status. }

  procedure gibFeldgroesse ( var x: integer;
                             var y: integer );
  { Die Groesse des Spielfeldes wird abgefragt.
    Vor dem ersten Aufruf von setzeFeldgroesse gilt x=y=18. }

  procedure gibGewinnreihe ( var x1: integer;
                             var y1: integer;
                             var x2: integer;
                             var y2: integer;
                             var ok: boolean);
  { Der Anfangsstein x1,y1 und der Endstein x2,y2 einer Gewinnreihe wird
    uebergeben. ok = false falls noch kein Gewinner existiert. }


implementation

  { Konstanten }

  { verfuegbare Staerken des Computerspielers }

  const
  MAXCSSTAERKE = 2;
  MINCSSTAERKE = 0;


  { Spielbrettgroesse & min/max. Koordinaten }

  const
  MINBRETTGROESSE = 5;
  MAXBRETTGROESSE = 30;
  MINBRETTKOORD = 1;
  MAXBRETTKOORD = MAXBRETTGROESSE;
  MINBRETTKOORDMINUS2 = MINBRETTKOORD - 2;
  MAXBRETTKOORDPLUS2 = MAXBRETTKOORD + 2;
  MINBRETTKOORDMINUS5 = MINBRETTKOORD - 5;
  MAXBRETTKOORDPLUS5 = MAXBRETTKOORD + 5;
  INITBRETTGROESSE = 18;


  { Inhalt einer Brettposition (Feldinhalt), Spielertypen }

  LEER = 0;
  SPIELER1 = 1;
  SPIELER2 = 2;


  { Spielbrettrichtungen }

  const
  RICHTUNGNORDOST = 1;
  RICHTUNGOST = 2;
  RICHTUNGSUEDOST = 3;
  RICHTUNGSUED = 4;


  { DEBUG-Dateiname }

  const
  DEBUGDATEINAME = 'DEBUG.TXT';


  { diverse Typen }

  type
  tFeldinhalt = LEER..SPIELER2;
                { Inhalt einer Brettposition }
  tSpieler = SPIELER1..SPIELER2;
             { Spieler }
  tBrettGroesse = MINBRETTGROESSE..MAXBRETTGROESSE;
                  { Bretthoehe bzw. -breite }
  tBrettKoord = MINBRETTKOORD..MAXBRETTKOORD;
                { Brettkoordinaten }
  tBrettKoordErw2 = MINBRETTKOORDMINUS2..MAXBRETTKOORDPLUS2;
                    { um 2 erweiterte Brettkoordinaten }
  tBrettKoordErw5 = MINBRETTKOORDMINUS5..MAXBRETTKOORDPLUS5;
                    { um 5 erweiterte Brettkoordinaten }
  tBrettRichtung = RICHTUNGNORDOST..RICHTUNGSUED;
                   { Richtung von Steinreihen }
  tCSStaerke = MINCSSTAERKE..MAXCSSTAERKE;
               { Staerken des Computerspielers }

  { Typen fuer die Speicherung einer lin. Liste von Spiel-
    positionen (Zuegen) zur zufaelligen Zugauswahl }

  tZugListe = ^tZugListeRecord;
  tZugListeRecord = record
                      NaechsterZug : tZugListe;
                      BrettZeile : tBrettKoord;
                      BrettSpalte : tBrettKoord
                    end;

  { Typen fuer die Speicherung des Spielverlaufs }

  tSpielzug = ^tSpielzugRecord;
  tSpielzugRecord = record
                      BrettZeile : tBrettKoord;
                      BrettSpalte : tBrettKoord;
                      StatusDanach : tStatus;
                      ZugArt : integer; {0..2 Computerzug, -1 manuell}
                      NaechsterZug : tSpielzug;
                      VorherigerZug : tSpielzug
                    end;

  { Weitere Spielbrett-Typen zur Speicherung des Spielbrettstatus }

  type
  tStellung = array [tBrettKoord, tBrettKoord] of tFeldinhalt;
              { Spielbrettbelegung }
  tReihenanzahl = 0..5;
                  { Anzahl Steine in einer 5er-Reihe }
  tReihenAnzahlGesamt = 0..maxint;
                        { Gesamtanzahl moegl. Reihen }
  tReihe = array [tBrettKoord, tBrettKoord, tBrettRichtung, tSpieler]
                  of tReihenanzahl;
           { Reihenbelegung (Anzahl Steine) fuer jede Position,
             jede Richtung und jeden Spieler }
  tBewertung = array [tBrettKoord, tBrettKoord, tSpieler] of integer;
               { Bewertungskennzahl fuer jede Position & jeden Spieler }
  tSpieldaten = ^tSpieldatenRecord;
                { Handle (Zeiger) auf den Spieldaten-Record, siehe
                  im folgenden... }

  { Aufbau des Spieldaten-Records }

  tSpieldatenRecord = record
                        BrettHoehe : tBrettGroesse;
                                  { Anzahl Felder in Y-Richtung }
                        BrettBreite : tBrettGroesse;
                                  { Anzahl Felder in X-Richtung }
                        Spielstatus : tStatus;
                                  { Spielstatus (wer ist am Zug,
                                    Gewinn, Unentschieden),
                                    redundant fuer Interface }
                        Stellung : tStellung;
                                  { der aktuelle Brettzustand }
                        Reihen : tReihe;
                                  { der Status aller Reihen }
                        Bewertung : tBewertung;
                                  { die Bewertung jedes Feldes fuer
                                    jeden Spieler }
                        NochNichtBelegt : integer;
                                  { Anzahl Felder, die noch frei sind;
                                    wenn 0: Unentschieden (wenn voll) }
                        NochMoeglicheReihen : tReihenAnzahlGesamt;
                                  { Anzahl Reihen, die noch eine
                                    Gewinnmoeglichkeit darstellen;
                                    wenn 0: Unentschieden (wenn keine
                                    Gewinnmoeglichkeit mehr) }
                        Gewinner : tFeldinhalt;
                                  { Gewinnender Spieler oder LEER;
                                    wenn LEER sind die folg. drei
                                    Datenelemente undefiniert }
                        GewinnerBrettZeile : tBrettKoord;
                                  { Zeile des 1. Steins
                                    der Gewinnreihe }
                        GewinnerBrettSpalte : tBrettKoord;
                                  { Spalte des 1. Steins
                                    der Gewinnreihe }
                        GewinnerRichtung : tBrettRichtung
                                  { Richtung der Gewinnreihe }
                      end;


  { Unit-lokale Variablen }

  var
  Spielstufe : tCSStaerke;  { aktuelle Spielstaerke des CS }
  Liste : tZugListe;  { die lineare Liste von Spiel-
                        positionen (Zuegen) zur
                        zufaelligen Zugauswahl }
  Anzahl : integer;   { Anzahl Zuege in dieser Liste }
  ErsterZug : tSpielzug;    { zeigt auf den ersten Zug
                              des Spielverlaufs oder nil }
  LetzterZug : tSpielzug;   { zeigt auf den letzten Zug
                              des Spielverlaufs oder nil }
  AktuellerZug : tSpielzug; { zeigt auf den aktuellen Zug
                              des Spielverlaufs oder nil }
  Spieldaten : tSpieldaten; { Spiel-Daten (akt. Brettzustand) }
  Debugging : boolean;   { Aufrufschalter /D = true }
  ReihenwertAdd : array[0..5] of integer;
                  { Reihenwerte fuer Bewertung von Reihen, additiv }
  ReihenwertAkk : array[0..5] of integer;
                  { Reihenwerte fuer Bewertung von Reihen, akkum. }
  Bewertungsfaktor : integer;
                  { 10: bedeutet identische Bewertung von
                    Spieler und Gegner, >10 bedeutet hoehere
                    Spielerbewertung, <10 bedeutet hoehere
                    Gegnerbewertung (nicht sinnvoll) }
  Zufallsfaktor : integer;
             { zufaelliger Bewertungszuschlag 1..Zufallsfaktor }
  UnentschiedenExakt : boolean;
             { true: mittels NochMoeglicheReihen wird 0;
               false: mittels NochNichtBelegt wird 0 }





  { ----- Unit-lokale Prozeduren ----- }





  function BestimmeZufallsZahl (
             inVon : integer;
             inBis : integer) : integer;

  { Bestimmung einer ganzzahligen Zufallszahl im Bereich
    inVon ... inBis (die Differenz muss im Bereich 0..65534
    sein)
    inVon: untere Grenze
    inBis: obere Grenze (muss >= inVon sein!)
    Rueckgabewert: zufaellige Zahl im Bereich inVon ... inBis }

    var
    Diff : word;
    Zufall : word;
    Ergebnis : integer;

  begin

    Diff := 1 + inBis - inVon;
    Zufall := random (Diff);
    Ergebnis := inVon + Zufall;
    if (Ergebnis < inVon) or (Ergebnis > inBis) then
      Ergebnis := inVon;
    BestimmeZufallsZahl := Ergebnis

  end;  { BestimmeZufallsZahl }





  function ExistiertDatei (
             inDatei : string) : Boolean;

  { Pruefen, ob eine Datei mit Namen inDatei existiert
    inDatei: Dateiname
    Rueckgabewert: true: ja, existiert; false: nein, existiert nicht }

    var
    Datei : file;

  begin

    {$I-}
    Assign (Datei, inDatei);
    Reset (Datei);
    Close (Datei);
    {$I+}
    ExistiertDatei := (IOResult = 0) and (inDatei <> '')

  end;  { ExistiertDatei }





  procedure LoescheDatei (
              inDatei : string);

  { Datei loeschen
    inDatei: Dateiname der zu loeschenden Datei }

    var
    Datei : file;

  begin

    if ExistiertDatei (inDatei) then
    begin
      Assign (Datei, inDatei);
      Erase (Datei)
    end

  end;  { LoescheDatei }





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





  procedure VerarbeiteAufrufParameter;

  { Auslesen und Speichern der Aufrufparameter:
    /D: Debugging: eine Datei DEBUG.TXT wird geschrieben.
        Die Datei wird zu Beginn geloescht, falls sie existiert.
    /U: Falls angegeben, exaktes Unentschieden im Gegensatz zum
        laxen Unentschiedenkriterium (Spiel bis Brett voll) }

    var
    ParamNr : word;

  begin

    Debugging := false;
    UnentschiedenExakt := false;

    for ParamNr := 1 to ParamCount do
      begin
        if (ParamStr (ParamNr) = '/D')
            or (ParamStr (ParamNr) = '/d') then
          Debugging := true;
        if (ParamStr (ParamNr) = '/U')
            or (ParamStr (ParamNr) = '/u') then
          UnentschiedenExakt := true;
      end;

    if Debugging then
      LoescheDatei (DEBUGDATEINAME)

  end;  { VerarbeiteAufrufParameter }





  procedure LeereZugListe;

  { Die Elemente der linearen Liste von Spiel-
    positionen (Zuegen) zur zufaelligen Zugauswahl werden geloescht }

    var
    ZuLoeschen : tZugListe;

  begin

    while Liste <> nil do
    begin
      ZuLoeschen := Liste;
      Liste := ZuLoeschen^.NaechsterZug;
      dispose (ZuLoeschen)
    end;
    Anzahl := 0

  end;  { LeereZugListe }





  procedure SpeichereZug (
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord);

  { Ein Zug wird in der Liste von Spiel-
    positionen (Zuegen) zur zufaelligen Zugauswahl gespeichert.
    inBrettZeile, inBrettSpalte: Position }

    var
    Neu : tZugListe;

  begin

    new (Neu);
    Neu^.BrettZeile := inBrettZeile;
    Neu^.BrettSpalte := inBrettSpalte;
    Neu^.NaechsterZug := Liste;
    Liste := Neu;
    Anzahl := Anzahl + 1

  end;  { SpeichereZug }





  function HoleZufallsZug (
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord) : Boolean;

  { Aus der Liste von Spielpositionen (Zuegen) zur
    zufaelligen Zugauswahl wird ein zufaelliger Zug zurueckgegeben.
    Falls die Liste leer ist, ist das Ergebnis false, sonst
    true.
    outBrettZeile, outBrettSpalte: zufaelliger Zug aus der Liste
    Rueckgabe: true: Zug wurde zurueckgegeben
               false: Liste ist leer, outBrettZeile und
               outBrettSpalte sind undefiniert }

    var
    Zufallszahl : integer;
    Ergebnis : Boolean;
    Zeiger : tZugListe;
    i : integer;

  begin

    if Anzahl = 0 then
      Ergebnis := false
    else
    begin
      Ergebnis := true;
      Zufallszahl := BestimmeZufallsZahl (1, Anzahl);
      Zeiger := Liste;
      for i := 2 to Zufallszahl do
        Zeiger := Zeiger^.NaechsterZug;
      outBrettZeile := Zeiger^.BrettZeile;
      outBrettSpalte := Zeiger^.BrettSpalte
    end;  { if }

    HoleZufallsZug := Ergebnis

  end;   { HoleZufallsZug }




  procedure LeereSpielverlauf;

  { Die Elemente des Spielverlaufs werden geloescht. }

    var
    ZuLoeschen : tSpielzug;

  begin

    while ErsterZug <> nil do
    begin
      ZuLoeschen := ErsterZug;
      ErsterZug := ZuLoeschen^.NaechsterZug;
      dispose (ZuLoeschen)
    end;
    LetzterZug := nil;
    AktuellerZug := nil

  end;  { LeereSpielverlauf }




  procedure NeuerZugInSpielverlauf ( inBrettZeile : tBrettKoord;
                                     inBrettSpalte : tBrettKoord;
                                     inStatusDanach : tStatus;
                                     inZugArt : integer );

  { Ein neuer Zug wird hinter der aktuellen Position im
    Spielverlauf angefuegt.
    Dabei werden alle alten Folgezuege automatisch geloescht.
    Status vorher/nachher und wer den Zug gemacht hat, wird
    ebenfalls gespeichert. (nicht verwendet) }

    var
    Neu : tSpielzug;
    ZuLoeschen : tSpielzug;
    Naechster : tSpielzug;

  begin

    { Loeschen des Spielverlaufs hinter dem aktuellen Zug }
    if AktuellerZug <> nil then
    begin
      Naechster := AktuellerZug^.NaechsterZug;
      while Naechster <> nil do
      begin
        ZuLoeschen := Naechster;
        Naechster := ZuLoeschen^.NaechsterZug;
        dispose (ZuLoeschen)
      end;
      LetzterZug := AktuellerZug
    end
    else
      { AktuellerZug = nil, vor dem ersten Zug }
      LeereSpielverlauf;

    new (Neu);
    Neu^.BrettZeile := inBrettZeile;
    Neu^.BrettSpalte := inBrettSpalte;
    Neu^.StatusDanach := inStatusDanach;
    Neu^.ZugArt := inZugArt;
    if AktuellerZug = nil then
    begin
      { kein Zug, dies ist der erste }
      Neu^.NaechsterZug := nil;
      Neu^.VorherigerZug := nil;
      ErsterZug := Neu;
      LetzterZug := Neu;
      AktuellerZug := Neu
    end
    else
    begin
      { schon Zug/Zuege da, hinter akt. anfuegen }
      Neu^.NaechsterZug := nil;
      Neu^.VorherigerZug := AktuellerZug;
      AktuellerZug^.NaechsterZug := Neu;
      LetzterZug := Neu;
      AktuellerZug := Neu
    end;

  end;  { NeuerZugInSpielverlauf }





  procedure SchreibeSpielfeldDaten (
              inDaten : tSpieldaten;
              intext : string;
              inDateiname : string);

  { Schreibt alle Daten der Spieldaten-Datenstruktur, auf die
    inDaten zeigt, in die Datei inDateiname (im Append-Modus,
    wenn die Datei existiert).
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inText: Erlaeuterungstext
    inDateiname: Name der Datei, in die die Daten ausgegeben
                 werden }

    var
    Datei : text;
    i : tBrettKoord;
    j : tBrettKoord;
    k : tBrettRichtung;
    l : tSpieler;

  begin

    assign (Datei, inDateiname);
    if ExistiertDatei (inDateiname) then
      append (Datei)
    else
      rewrite (Datei);
    writeln (Datei, '-- SpielfeldDaten -- ' + intext + ' --');

    with inDaten^ do
    begin
      writeln (Datei, 'BrettHoehe=', BrettHoehe);
      writeln (Datei, 'BrettBreite=', BrettBreite);
      write (Datei, 'Spielstatus=');
      case Spielstatus of
        EINS_AM_ZUG :
          writeln (Datei, 'EINS_AM_ZUG');
        ZWEI_AM_ZUG :
          writeln (Datei, 'ZWEI_AM_ZUG');
        EINS_GEWINNT :
          writeln (Datei, 'EINS_GEWINNT');
        ZWEI_GEWINNT :
          writeln (Datei, 'ZWEI_GEWINNT');
        UNENTSCHIEDEN :
          writeln (Datei, 'UNENTSCHIEDEN');
        UNDEFINIERT :
          writeln (Datei, 'UNDEFINIERT');
      end;  { case }
      writeln (Datei, 'Stellung=');
      for i := 1 to BrettHoehe do
        begin
          for j := 1 to BrettBreite do
            write (Datei, Stellung[i, j], ' ');
          writeln (Datei, ' ');
        end;
      for l := SPIELER1 to SPIELER2 do
        begin
          writeln (Datei, 'Bewertung=  (Spieler:', l, ')');
          for i := 1 to BrettHoehe do
            begin
              for j := 1 to BrettBreite do
                write (Datei, Bewertung[i, j, l]:3, ' ');
              writeln (Datei, ' ');
            end;
        end;
      for l := SPIELER1 to SPIELER2 do
        for k := RICHTUNGNORDOST to RICHTUNGSUED do
          begin
            writeln (Datei, 'Reihen=  (Spieler:', l, ', Richtung:', k,
                     ')');
            for i := 1 to BrettHoehe do
              begin
                for j := 1 to BrettBreite do
                  write (Datei, Reihen[i, j, k, l], ' ');
                writeln (Datei, ' ');
              end;
          end;
      writeln (Datei, 'NochNichtBelegt=', NochNichtBelegt);
      writeln (Datei, 'NochMoeglicheReihen=', NochMoeglicheReihen);
      writeln (Datei, 'Gewinner=', Gewinner);
      writeln (Datei, 'GewinnerBrettZeile=', GewinnerBrettZeile);
      writeln (Datei, 'GewinnerBrettSpalte=', GewinnerBrettSpalte);
      writeln (Datei, 'GewinnerRichtung=', GewinnerRichtung);
    end;  { with }

    writeln (Datei, '-- ENDE SpielfeldDaten --');
    writeln (Datei, ' ');
    close (Datei)

  end;  { SchreibeSpielfeldDaten }





  procedure AktualisiereReihe (
              inDaten : tSpieldaten;
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord;
              inSpieler : tSpieler;
              inRichtung : tBrettRichtung;
              inArt : integer );

  { Hilfsroutine zum Aktualisieren der Reihenbelegung (Anzahl Steine)
    einer Reihe, der noch verbleibenden Anzahl Reihen, die noch
    eine Gewinnmoeglichkeit darstellen (und damit Bestimmung
    der korrekten Unentschieden-Situation), Bewertung der
    Spielpositionen aus Sicht der beiden Spieler, sowie Bestimmung
    der Gewinnsituation, sofern eine solche entdeckt wird.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile des 1. Steins der betrachteten Reihe
    inBrettSpalte: Spalte des 1. Steins der betrachteten Reihe
    inSpieler: betrachteter Spieler
    inRichtung: Richtung der Reihe
    inArt: -1 bedeutet Zuruecksetzen, +1 bedeutet Setzen }

    var
    Stein : integer;
    Zeile : tBrettKoord;
    Spalte : tBrettKoord;
    SpielerAnzahl : tReihenanzahl;
    GegnerAnzahl : tReihenanzahl;
    Gegner : tSpieler;

  begin

    with inDaten^ do
    begin

      { Aktualisierung der Reihenbelegung (normaler Ablauf)}
      if inArt = 1 then
      begin
        if Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
            = 0 then
          NochMoeglicheReihen := NochMoeglicheReihen - 1;
        Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
         := Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
             + 1;
      end;

      { Aktualisierung der Bewertung fuer jeden Stein in der Reihe }
      Zeile := inBrettZeile;
      Spalte := inBrettSpalte;
      Gegner := 3 - inSpieler;
      SpielerAnzahl :=
           Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler];
      GegnerAnzahl :=
           Reihen[inBrettZeile, inBrettSpalte, inRichtung, Gegner];
      for Stein := 0 to 4 do
        begin
          case inRichtung of
            RICHTUNGNORDOST :
              begin
                Zeile := inBrettZeile - Stein;
                Spalte := inBrettSpalte + Stein
              end;
            RICHTUNGOST :
              Spalte := inBrettSpalte + Stein;
            RICHTUNGSUEDOST :
              begin
                Zeile := inBrettZeile + Stein;
                Spalte := inBrettSpalte + Stein
              end;
            RICHTUNGSUED :
              Zeile := inBrettZeile + Stein;
          end;  { case }
          { kein Gegnerstein in der Reihe: Bewertung fuer
            Spieler entsprechend erhoehen }
          if GegnerAnzahl = 0 then
            Bewertung[Zeile,Spalte,inSpieler] :=
               ReihenwertAdd[SpielerAnzahl] * inArt +
               Bewertung[Zeile,Spalte,inSpieler]
          else
            { erster Stein des Spielers in der Reihe:
              diese Reihe ist fuer Gegner verloren:
              Bewertung reduzieren }
            if SpielerAnzahl = 1 then
              Bewertung[Zeile,Spalte,Gegner] :=
                 Bewertung[Zeile,Spalte,Gegner] -
                 ReihenwertAkk[GegnerAnzahl] * inArt;
        end;  { for }

      { Aktualisierung der Reihenbelegung bei Ruecknahme}
      if inArt = -1 then
      begin
        Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
         := Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
             - 1;
        if Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
            = 0 then
          NochMoeglicheReihen := NochMoeglicheReihen + 1
      end;

      { Pruefung der Gewinnsituation beim Setzen }
      if inArt = 1 then
      begin
        if (Reihen[inBrettZeile, inBrettSpalte, inRichtung, inSpieler]
             = 5) and (Gewinner = LEER) then
        begin
          Gewinner := inSpieler;
          GewinnerBrettZeile := inBrettZeile;
          GewinnerBrettSpalte := inBrettSpalte;
          GewinnerRichtung := inRichtung;
        end  { if }
      end  { if }

    end  { with }

  end;  { AktualisiereReihe }





  procedure AktualisiereNordostReihen (
              inDaten : tSpieldaten;
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord;
              inSpieler : tSpieler;
              inArt : integer );

  { Hilfsroutine zum Aktualisieren der Reihenbelegungen (Anzahl Steine)
    aller moeglichen Reihen einer Position in Nordost-Richtung,
    der noch verbleibenden Anzahl Reihen, die noch eine
    Gewinnmoeglichkeit darstellen (und damit Bestimmung der
    Unentschieden-Situation) sowie Bestimmung
    der Gewinnsituation, sofern eine solche entdeckt wird.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    inSpieler: betrachteter Spieler
    inArt: -1 bedeutet Zuruecksetzen, +1 bedeutet Setzen }

    var
    Reihe : tReihenanzahl;
    StartZeile : tBrettKoordErw5;
    StartSpalte : tBrettKoordErw5;

  begin

    for Reihe := 0 to 4 do
      begin
        StartZeile := inBrettZeile + Reihe;
        StartSpalte := inBrettSpalte - Reihe;
        if (StartZeile <= inDaten^.BrettHoehe) and (StartZeile >= 5)
            and (StartSpalte >= 1)
            and (StartSpalte <= inDaten^.BrettBreite - 4) then
          AktualisiereReihe (inDaten, StartZeile, StartSpalte,
                             inSpieler, RICHTUNGNORDOST,inArt)
      end

  end;  { AktualisiereNordostReihen }





  procedure AktualisiereOstReihen (
              inDaten : tSpieldaten;
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord;
              inSpieler : tSpieler;
              inArt : integer );

  { Hilfsroutine zum Aktualisieren der Reihenbelegungen (Anzahl Steine)
    aller moeglichen Reihen einer Position in Ost-Richtung,
    der noch verbleibenden Anzahl Reihen, die noch eine
    Gewinnmoeglichkeit darstellen (und damit Bestimmung der
    Unentschieden-Situation) sowie Bestimmung
    der Gewinnsituation, sofern eine solche entdeckt wird.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    inSpieler: betrachteter Spieler
    inArt: -1 bedeutet Zuruecksetzen, +1 bedeutet Setzen }

    var
    Reihe : tReihenanzahl;
    StartZeile : tBrettKoordErw5;
    StartSpalte : tBrettKoordErw5;

  begin

    for Reihe := 0 to 4 do
      begin
        StartZeile := inBrettZeile;
        StartSpalte := inBrettSpalte - Reihe;
        if (StartSpalte >= 1)
            and (StartSpalte <= inDaten^.BrettBreite - 4) then
          AktualisiereReihe (inDaten, StartZeile, StartSpalte,
                             inSpieler, RICHTUNGOST,inArt)
      end

  end;  { AktualisiereOstReihen }






  procedure AktualisiereSuedostReihen (
              inDaten : tSpieldaten;
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord;
              inSpieler : tSpieler;
              inArt : integer );

  { Hilfsroutine zum Aktualisieren der Reihenbelegungen (Anzahl Steine)
    aller moeglichen Reihen einer Position in Suedost-Richtung,
    der noch verbleibenden Anzahl Reihen, die noch eine
    Gewinnmoeglichkeit darstellen (und damit Bestimmung der
    Unentschieden-Situation) sowie Bestimmung
    der Gewinnsituation, sofern eine solche entdeckt wird.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    inSpieler: betrachteter Spieler
    inArt: -1 bedeutet Zuruecksetzen, +1 bedeutet Setzen }

    var
    Reihe : tReihenanzahl;
    StartZeile : tBrettKoordErw5;
    StartSpalte : tBrettKoordErw5;

  begin

    for Reihe := 0 to 4 do
      begin
        StartZeile := inBrettZeile - Reihe;
        StartSpalte := inBrettSpalte - Reihe;
        if (StartZeile >= 1) and (StartZeile <= inDaten^.BrettHoehe - 4)
            and (StartSpalte >= 1)
            and (StartSpalte <= inDaten^.BrettBreite - 4) then
          AktualisiereReihe (inDaten, StartZeile, StartSpalte,
                             inSpieler, RICHTUNGSUEDOST, inArt)
      end

  end;  { AktualisiereSuedostReihen }





  procedure AktualisiereSuedReihen (
              inDaten : tSpieldaten;
              inBrettZeile : tBrettKoord;
              inBrettSpalte : tBrettKoord;
              inSpieler : tSpieler;
              inArt : integer );

  { Hilfsroutine zum Aktualisieren der Reihenbelegungen (Anzahl Steine)
    aller moeglichen Reihen einer Position in Sued-Richtung,
    der noch verbleibenden Anzahl Reihen, die noch eine
    Gewinnmoeglichkeit darstellen (und damit Bestimmung der
    Unentschieden-Situation) sowie Bestimmung
    der Gewinnsituation, sofern eine solche entdeckt wird.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    inSpieler: betrachteter Spieler
    inArt: -1 bedeutet Zuruecksetzen, +1 bedeutet Setzen }

    var
    Reihe : tReihenanzahl;
    StartZeile : tBrettKoordErw5;
    StartSpalte : tBrettKoordErw5;

  begin

    for Reihe := 0 to 4 do
      begin
        StartZeile := inBrettZeile - Reihe;
        StartSpalte := inBrettSpalte;
        if (StartZeile >= 1)
            and (StartZeile <= inDaten^.BrettHoehe - 4) then
          AktualisiereReihe (inDaten, StartZeile, StartSpalte,
                             inSpieler, RICHTUNGSUED,inArt)
      end

  end;  { AktualisiereSuedReihen }





  procedure ZuruecksetzenSpieldaten ( inDaten : tSpieldaten;
                                      inBrettHoehe : tBrettGroesse;
                                      inBrettBreite : tBrettGroesse );

  { Initialisierung der Spieldaten-Struktur mit Startwerten
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettHoehe: Hoehe des Spielbretts
    inBrettBreite: Breite des Spielbretts }

    var
    Zeile : tBrettKoord;
    Spalte : tBrettKoord;
    Richtung : tBrettRichtung;

  begin

    with inDaten^ do
    begin
      BrettHoehe := inBrettHoehe;
      BrettBreite := inBrettBreite;
      Spielstatus := UNDEFINIERT;
      for Zeile := 1 to inBrettHoehe do
        for Spalte := 1 to inBrettBreite do
          begin
            Stellung[Zeile, Spalte] := LEER;
            Bewertung[Zeile, Spalte, SPIELER1] := 0;
            Bewertung[Zeile, Spalte, SPIELER2] := 0;
            for Richtung := RICHTUNGNORDOST to RICHTUNGSUED do
              begin
                Reihen[Zeile, Spalte, Richtung, SPIELER1] := 0;
                Reihen[Zeile, Spalte, Richtung, SPIELER2] := 0
              end
          end;
      NochNichtBelegt := inBrettHoehe * inBrettBreite;
      NochMoeglicheReihen := 8*(NochNichtBelegt - 3*inBrettHoehe -
                                3*inBrettBreite + 8);
      Gewinner := LEER;
      GewinnerBrettZeile := 1;
      GewinnerBrettSpalte := 1;
      GewinnerRichtung := RICHTUNGNORDOST
    end;  { with }

    LeereZugListe;
    LeereSpielverlauf;

    if Debugging then
      SchreibeSpielfeldDaten (inDaten,
        'Start',
        DEBUGDATEINAME);

  end;  { ZuruecksetzenSpieldaten }





  function IstSpielfeldGueltig (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord) : Boolean;

  { Ueberpruefung, ob ein Feld auf dem Spielbrett gueltig
    (vorhanden) ist
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    Rueckgabe: true: ist gueltig; false: ist ungueltig }

  begin

    if (inBrettZeile > inDaten^.BrettHoehe) or (inBrettZeile < 1)
        or (inBrettSpalte > inDaten^.BrettBreite)
        or (inBrettSpalte < 1) then
      IstSpielfeldGueltig := false
    else
      IstSpielfeldGueltig := true

  end;  { IstSpielfeldGueltig }





  function IstSpielfeldSetzbar (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord) : Boolean;

  { Ueberpruefung, ob ein Feld auf dem Spielbrett setzbar
    (vorhanden und leer) ist
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    Rueckgabe: true: ist setzbar; false: ist nicht setzbar }

  begin

    if not IstSpielfeldGueltig (inDaten, inBrettZeile,
                                inBrettSpalte) then
      IstSpielfeldSetzbar := false
    else
      IstSpielfeldSetzbar := (inDaten^.Stellung[inBrettZeile,
                                                inBrettSpalte] = LEER)

  end;  { IstSpielfeldSetzbar }





  function HoleSpielfeldStatus (
                 inDaten : tSpieldaten;
                 inBrettZeile : tBrettKoord;
                 inBrettSpalte : tBrettKoord;
             var outGueltig : Boolean) : tFeldinhalt;

  { Abruf des Feldstatus eines Feldes auf dem Spielbrett
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition
    inBrettSpalte: Spalte der Brettposition
    outGueltig: true: Feld ist gueltig; false: Feld ist ungueltig
    Rueckgabe: SPIELER1, SPIELER2 oder LEER, wenn Feld gueltig;
               LEER wenn Feld ungueltig }

  begin

    if not IstSpielfeldGueltig (inDaten, inBrettZeile,
                                inBrettSpalte) then
    begin
      HoleSpielfeldStatus := LEER;
      outGueltig := false
    end
    else
    begin
      HoleSpielfeldStatus := inDaten^.Stellung[inBrettZeile,
                                               inBrettSpalte];
      outGueltig := true
    end  { if }

  end;  { HoleSpielfeldStatus }





  function IstBeendet (
             inDaten : tSpieldaten) : Boolean;

  { Pruefung, ob das laufende Spiel beendet ist (also gewonnen oder
    unentschieden ist)
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    Rueckgabe: true: Spiel ist unentschieden oder gewonnen
               false: Spiel ist noch nicht entschieden }

  begin

    if UnentschiedenExakt then
      IstBeendet := ((inDaten^.Gewinner <> LEER)
                    or (inDaten^.NochMoeglicheReihen <= 0))
    else
      IstBeendet := ((inDaten^.Gewinner <> LEER)
                    or (inDaten^.NochNichtBelegt <= 0));

  end;  { IstBeendet }





  function IstUnentschieden (
             inDaten : tSpieldaten) : Boolean;

  { Pruefung, ob das laufende Spiel unentschieden ist)
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    Rueckgabe: true: Spiel ist unentschieden
               false: sonst }

  begin

    if UnentschiedenExakt then
      IstUnentschieden := ((inDaten^.Gewinner = LEER)
                          and (inDaten^.NochMoeglicheReihen <= 0))
    else
      IstUnentschieden := ((inDaten^.Gewinner = LEER)
                          and (inDaten^.NochNichtBelegt <= 0));

  end;  { IstUnentschieden }





  function IstGewonnen (
                 inDaten : tSpieldaten;
             var outSieger : tSpieler;
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord;
             var outRichtung : tBrettRichtung) : Boolean;

  { Pruefung, ob das laufende Spiel gewonnen ist, mit Rueckgabe der
    Gewinn-relevanten Daten
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    outSieger: Gewinnender Spieler
    outBrettZeile: Zeile des 1. Steins der Gewinnreihe
    outBrettSpalte: Spalte des 1. Steins der Gewinnreihe
    outRichtung: Richtung der Gewinnreihe
    Rueckgabe: true: Spiel ist gewonnen
               false: sonst; dann sind die out...-Parameter undef. }

    var
    Ergebnis : Boolean;

  begin

    Ergebnis := (inDaten^.Gewinner <> LEER);
    if Ergebnis then
    begin
      outSieger := inDaten^.Gewinner;
      outBrettZeile := inDaten^.GewinnerBrettZeile;
      outBrettSpalte := inDaten^.GewinnerBrettSpalte;
      outRichtung := inDaten^.GewinnerRichtung
    end;  { if }
    IstGewonnen := Ergebnis;

  end;  { IstGewonnen }





  procedure BestimmeStatusNachZug;

  { Bestimmung des Status nach einem Zug }

  begin

    if IstBeendet(Spieldaten) then
    begin
      if IstUnentschieden(Spieldaten) then
        Spieldaten^.Spielstatus := UNENTSCHIEDEN
      else
      begin
        case Spieldaten^.Gewinner of
          SPIELER1 :
            Spieldaten^.Spielstatus := EINS_GEWINNT;
          SPIELER2 :
            Spieldaten^.Spielstatus := ZWEI_GEWINNT;
        end;  { case }
      end
    end
    else
    begin
      case Spieldaten^.Spielstatus of
        EINS_AM_ZUG :
          Spieldaten^.Spielstatus := ZWEI_AM_ZUG;
        ZWEI_AM_ZUG :
          Spieldaten^.Spielstatus := EINS_AM_ZUG;
      end;  { case }
    end;

  end;  { BestimmeStatusNachZug }





  procedure BestimmeSpielerGegnerVorZug
            ( var outSpieler : tSpieler;
              var outGegner : tSpieler );

  { Bestimmung von Spieler/Gegner aus dem Status vor
    einem Zug.
    Vorbedingung: Status ist entweder
    EINS_AM_ZUG oder ZWEI_AM_ZUG!
    outSpieler: Spieler, SPIELER1 oder SPIELER2
    outGegner: Gegner, SPIELER1 oder SPIELER2 }

  begin

    case Spieldaten^.Spielstatus of
      EINS_AM_ZUG :
        begin
          outSpieler := SPIELER1;
          outGegner := SPIELER2
        end;
      ZWEI_AM_ZUG :
        begin
          outSpieler := SPIELER2;
          outGegner := SPIELER1
        end;
    end;  { case }

  end;  { BestimmeSpielerGegnerVorZug }





  function SetzeSpielfeld (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord;
             inSpieler : tSpieler) : Boolean;

  { Spieler inSpieler setzt auf Feld (inBrettZeile,inBrettSpalte).
    Falls Debugging angeschaltet ist, wird der Status in die Debug-
    Datei geschrieben.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition, die gesetzt werden soll
    inBrettSpalte: Spalte der Brettposition, die gesetzt werden soll
    inSpieler: Spieler, der setzt
    Rueckgabe: true: Zug war erfolgreich und wurde gesetzt;
               false: Feld war ungueltig oder nicht setzbar }

    var
    Ergebnis : Boolean;

  begin

    if IstSpielfeldSetzbar (inDaten, inBrettZeile, inBrettSpalte) then
    begin
      inDaten^.Stellung[inBrettZeile, inBrettSpalte] := inSpieler;
      inDaten^.NochNichtBelegt := inDaten^.NochNichtBelegt - 1;
      AktualisiereNordostReihen (inDaten, inBrettZeile, inBrettSpalte,
                                 inSpieler,1);
      AktualisiereOstReihen (inDaten, inBrettZeile, inBrettSpalte,
                             inSpieler,1);
      AktualisiereSuedostReihen (inDaten, inBrettZeile, inBrettSpalte,
                                 inSpieler,1);
      AktualisiereSuedReihen (inDaten, inBrettZeile, inBrettSpalte,
                              inSpieler,1);
      BestimmeStatusNachZug;
      Ergebnis := true
    end
    else
      Ergebnis := false;

    if Debugging then
      SchreibeSpielfeldDaten (inDaten,
      'Setzen(' +
      IntegerNachString(inBrettZeile) + ',' +
      IntegerNachString(inBrettSpalte) + ',' +
      IntegerNachString(inSpieler) + ')',
      DEBUGDATEINAME);
    SetzeSpielfeld := Ergebnis

  end;  { SetzeSpielfeld }






  function ZuruecksetzenSpielfeld (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord) : Boolean;

  { Spielstein wird zurueckgenommen.
    Falls Debugging angeschaltet ist, wird der Status in die Debug-
    Datei geschrieben.
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition, die zurueckgenommen werden soll
    inBrettSpalte: Spalte der Brettposition, die zurueckgenommen werden soll
    Rueckgabe: true: Zug wurde erfolgreich zurueckgenommen;
               false: Feld war ungueltig oder leer }

    var
    Ergebnis : Boolean;
    Spieler : tSpieler;

  begin

    if IstSpielfeldGueltig (inDaten, inBrettZeile, inBrettSpalte) then
    begin
      if inDaten^.Stellung[inBrettZeile,inBrettSpalte] <> LEER then
      begin
        Spieler := inDaten^.Stellung[inBrettZeile, inBrettSpalte];
        case Spieler of
          SPIELER1 :
            Spieldaten^.Spielstatus := ZWEI_AM_ZUG;
          SPIELER2 :
            Spieldaten^.Spielstatus := EINS_AM_ZUG;
        end;  { case }
        inDaten^.Stellung[inBrettZeile, inBrettSpalte] := LEER;
        inDaten^.NochNichtBelegt := inDaten^.NochNichtBelegt + 1;
        AktualisiereNordostReihen (inDaten, inBrettZeile, inBrettSpalte,
                                   Spieler,-1);
        AktualisiereOstReihen (inDaten, inBrettZeile, inBrettSpalte,
                               Spieler,-1);
        AktualisiereSuedostReihen (inDaten, inBrettZeile, inBrettSpalte,
                                   Spieler,-1);
        AktualisiereSuedReihen (inDaten, inBrettZeile, inBrettSpalte,
                                Spieler,-1);
        inDaten^.Gewinner := LEER;
        inDaten^.GewinnerBrettZeile := 1;
        inDaten^.GewinnerBrettSpalte := 1;
        inDaten^.GewinnerRichtung := RICHTUNGNORDOST;
        BestimmeStatusNachZug;
        Ergebnis := true
      end
    end
    else
      Ergebnis := false;

    if Debugging then
      SchreibeSpielfeldDaten (inDaten,
      'Zuruecksetzen(' +
      IntegerNachString(inBrettZeile) + ',' +
      IntegerNachString(inBrettSpalte) + ',' +
      IntegerNachString(Spieler) + ')',
      DEBUGDATEINAME);

    ZuruecksetzenSpielfeld := Ergebnis

  end;  { ZuruecksetzenSpielfeld }






  function HoleReihenAnzahl (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord;
             inRichtung : tBrettRichtung;
             inSpieler : tSpieler) : tReihenanzahl;

  { Bestimmung der Reihenbelegung (Anzahl Steine) fuer eine Position,
    eine Richtung und einen Spieler
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der Brettposition des 1. Steins der Reihe
    inBrettSpalte: Spalte der Brettposition des 1. Steins der Reihe
    inRichtung : Richtung der Reihe
    inSpieler: betrachter Spieler
    Rueckgabe: Anzahl Steine, die der betrachtete Spieler in der
               Reihe gesetzt hat (0..5) }

  begin

    HoleReihenAnzahl := inDaten^.Reihen[inBrettZeile, inBrettSpalte,
                                        inRichtung, inSpieler]

  end;  { HoleReihenAnzahl }





  function IstUmgebungBelegt (
             inDaten : tSpieldaten;
             inBrettZeile : tBrettKoord;
             inBrettSpalte : tBrettKoord) : Boolean;

  { Ueberpruefung, ob in den Nachbarfeldern einer Brettposition
    Steine gesetzt sind
    inDaten: Zeiger auf die Spieldaten-Datenstruktur
    inBrettZeile: Zeile der betrachteten Brettposition
    inBrettSpalte: Spalte der betrachteten Brettposition
    Rueckgabe: true: mindestens eine Nachbarposition belegt;
               false: alle Nachbarpositionen leer }

    var
    NochNichtBelegt : Boolean;
    Zeile : tBrettKoordErw2;
    Spalte : tBrettKoordErw2;

  begin

    NochNichtBelegt := false;
    Zeile := inBrettZeile - 1;
    while (not NochNichtBelegt) and (Zeile <= (inBrettZeile + 1)) do
    begin
      if (Zeile >= 1) and (Zeile <= inDaten^.BrettHoehe) then
      begin
        Spalte := inBrettSpalte - 1;
        while (not NochNichtBelegt)
               and (Spalte <= (inBrettSpalte + 1)) do
        begin
          if (Spalte >= 1) and (Spalte <= inDaten^.BrettBreite) then
            if (Zeile <> inBrettZeile)
                or (Spalte <> inBrettSpalte) then
              NochNichtBelegt := (inDaten^.Stellung[Zeile, Spalte]
                                   <> LEER);
          Spalte := Spalte + 1
        end   { while }
      end;
      Zeile := Zeile + 1
    end;   { while }
    IstUmgebungBelegt := NochNichtBelegt

  end;  { IstUmgebungBelegt }





  function BestimmeErstesLeerFeld (
                 inDaten : tSpieldaten;
                 inBrettZeile : tBrettKoord;
                 inBrettSpalte : tBrettKoord;
                 inRichtung : tBrettRichtung;
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord) : boolean;

  { Bestimmung des ersten Leerfeldes in einer Stein-Reihe
    inDaten: Zeiger auf die Spieldaten
    inBrettZeile: Zeile des 1. Steins der betrachteten Reihe
    inBrettSpalte: Spalte des 1. Steins der betrachteten Reihe
    inRichtung: Richtung der Reihe
    outBrettZeile: Zeile des ersten Leerfeldes in der Reihe
    outBrettSpalte: Spalte des ersten Leerfeldes in der Reihe
    Rueckgabe: true: Leerfeld gefunden
               false: Reihe voll, kein Leerfeld gefunden,
                      outBrettZeile & outBrettSpalte undef. }

    var
    Zeile : integer;
    Spalte : integer;
    Stein : integer;
    Fertig : boolean;
    Gueltig : boolean;

  begin

    Zeile := inBrettZeile;
    Spalte := inBrettSpalte;
    Stein := 0;
    Fertig := false;

    while (not Fertig) and (Stein <= 4) do
    begin
      if HoleSpielfeldStatus (inDaten, Zeile, Spalte, Gueltig)
          = LEER then
        if Gueltig then
        begin
          Fertig := true;
          outBrettZeile := Zeile;
          outBrettSpalte := Spalte;
        end;

      case inRichtung of
        RICHTUNGNORDOST :
          begin
            Zeile := Zeile - 1;
            Spalte := Spalte + 1
          end;
        RICHTUNGOST :
          Spalte := Spalte + 1;
        RICHTUNGSUEDOST :
          begin
            Zeile := Zeile + 1;
            Spalte := Spalte + 1
          end;
        RICHTUNGSUED :
          Zeile := Zeile + 1;
      end;  { case }

      Stein := Stein + 1;
    end;  { while }

    BestimmeErstesLeerFeld := Fertig

  end;  { BestimmeErstesLeerFeld }





  function Positionsbewertung ( inDaten : tSpieldaten;
                                inZeile : tBrettKoord;
                                inSpalte : tBrettKoord;
                                inSpieler : tSpieler;
                                inGegner : tSpieler ) : integer;

  { Positionsbewertung an Position (inZeile,inSpalte)
    aus Sicht des Spielers inSpieler im Vergleich zum
    Gegner inGegner.
    inDaten: Zeiger auf die Spieldaten
    inZeile: betrachtete Brett-Zeile
    inSpalte: betrachtete Brett-Zeile
    inSpieler: Spielercode des Spielers
    inGegner: Spielercode des Gegners
    Rueckgabe: Spielfeldbewertung (hohe Werte = besser) }

  begin

    Positionsbewertung := inDaten^.Bewertung[inZeile,inSpalte,inSpieler] *
                          Bewertungsfaktor div 10 +
                          inDaten^.Bewertung[inZeile,inSpalte,inGegner] +
                          BestimmeZufallsZahl(1,Zufallsfaktor)

  end;  { Positionsbewertung }





  procedure UeberpruefeLeerfelderInDreierreihe (
                 inDaten : tSpieldaten;
                 inBrettZeile : tBrettKoord;
                 inBrettSpalte : tBrettKoord;
                 inRichtung : tBrettRichtung;
                 inSpieler : tSpieler;
                 inGegner : tSpieler;
             var ioBestWert : integer;
             var ioBrettZeile : tBrettKoord;
             var ioBrettSpalte : tBrettKoord);

  { Ueberpruefung der Leerfelder einer Stein-Reihe,
    die in drei Feldern vom Spieler inSpieler belegt ist
    und sonst leer ist. Es wird das Maximum der Positions-
    Bewertung gesucht. Die aktuell beste Bewertung steht in
    ioBestWert und die dazugehoerige Position in ioBrettZeile
    bzw. ioBrettSpalte.
    inDaten: Zeiger auf die Spieldaten
    inBrettZeile: Zeile des 1. Steins der betrachteten Reihe
    inBrettSpalte: Spalte des 1. Steins der betrachteten Reihe
    inRichtung: Richtung der Reihe
    inSpieler: Spielercode des Spielers
    inGegner: Spielercode des Gegners
    ioBestWert : aktuelle Bewertung der folgenden Position,
                 muss zu Beginn mit -MaxInt init. werden.
                 Ist dieser Wert zum Schluss der Suche immer
                 noch -MaxInt, so steht in den folgenden
                 zwei Parametern keine gueltige Position!
    ioBrettZeile: Zeile des besten Feldes
    ioBrettSpalte: Spalte des besten Feldes }

    var
    Zeile : integer;
    Spalte : integer;
    Stein : integer;
    Gueltig : boolean;
    Wert : integer;

  begin

    Zeile := inBrettZeile;
    Spalte := inBrettSpalte;
    Stein := 0;

    while Stein <= 4 do
    begin
      if HoleSpielfeldStatus (inDaten, Zeile, Spalte, Gueltig)
          = LEER then
        if Gueltig then
        begin
          Wert := Positionsbewertung(inDaten,Zeile,Spalte,
                                     inSpieler,inGegner);
          if Wert > ioBestWert then
          begin
            ioBestWert := Wert;
            ioBrettZeile := Zeile;
            ioBrettSpalte := Spalte
          end
        end;

      case inRichtung of
        RICHTUNGNORDOST :
          begin
            Zeile := Zeile - 1;
            Spalte := Spalte + 1
          end;
        RICHTUNGOST :
          Spalte := Spalte + 1;
        RICHTUNGSUEDOST :
          begin
            Zeile := Zeile + 1;
            Spalte := Spalte + 1
          end;
        RICHTUNGSUED :
          Zeile := Zeile + 1;
      end;  { case }

      Stein := Stein + 1;
    end;  { while }

  end;  { UeberpruefeLeerfelderInDreierreihe }





  function SucheGewinnzug (
                 inDaten : tSpieldaten;
                 inSpieler : tSpieler;
                 inGegner : tSpieler;
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord) : boolean;

  { Suche nach einem Gewinnzug fuer Spieler inSpieler
    (inSpieler hat 4 Steine, inGegner hat 0 Steine in einer Reihe)
    inDaten: Zeiger auf die Spieldaten
    inSpieler: Spieler, fuer den Gewinnzug gesucht wird
    inGegner: Gegner von inSpieler
    outBrettZeile: Zeile des Feldes zum Gewinnzug
    outBrettSpalte: Spalte des Feldes zum Gewinnzug
    Rueckgabe: true: Gewinnzug gefunden
               false: kein Gewinnzug gefunden,
                      outBrettZeile & outBrettSpalte undef. }

    var
    Zeile : integer;
    Spalte : integer;
    Richtung : integer;
    Fertig : boolean;

  begin

    Fertig := false;
    Zeile := 1;

    while (not Fertig) and (Zeile <= inDaten^.BrettHoehe) do
    begin
      Spalte := 1;
      while (not Fertig) and (Spalte <= inDaten^.BrettBreite) do
      begin
        Richtung := RICHTUNGNORDOST;
        while (not Fertig) and (Richtung <= RICHTUNGSUED) do
        begin
          if HoleReihenAnzahl (inDaten, Zeile, Spalte, Richtung,
                               inSpieler) = 4 then
            if HoleReihenAnzahl (inDaten, Zeile, Spalte, Richtung,
                                 inGegner) = 0 then
              Fertig := BestimmeErstesLeerFeld (inDaten, Zeile,
                                                 Spalte, Richtung,
                                                 outBrettZeile,
                                                 outBrettSpalte);
          Richtung := Richtung + 1
        end;
        Spalte := Spalte + 1
      end;  { while }
      Zeile := Zeile + 1
    end;  { while }

    SucheGewinnzug := Fertig;

  end;  { SucheGewinnzug }






  function NutzeOderStoppeDreier (
                 inDaten : tSpieldaten;
                 inSpieler : tSpieler;
                 inGegner : tSpieler;
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord) : boolean;

  { Suche nach einem potentiellen Gewinnzug fuer Spieler inSpieler
    (inSpieler hat 3 Steine, inGegner hat 0 Steine in einer Reihe).
    Alle der artigen potentiellen Setzpositionen werden durchsucht,
    die beste Position wird zurueckgegeben, falls gefunden.
    inDaten: Zeiger auf die Spieldaten
    inSpieler: Spieler, fuer den Gewinnzug gesucht wird
    inGegner: Gegner von inSpieler
    outBrettZeile: Zeile des Feldes zum potentiellen Gewinnzug
    outBrettSpalte: Spalte des Feldes zum potentiellen Gewinnzug
    Rueckgabe: true: potentieller Gewinnzug gefunden
               false: kein potentieller Gewinnzug gefunden,
                      outBrettZeile & outBrettSpalte undef. }

    var
    Zeile : integer;
    Spalte : integer;
    Richtung : integer;
    BestWert : integer;

  begin

    Zeile := 1;
    Bestwert := -MaxInt;
    while Zeile <= inDaten^.BrettHoehe do
    begin
      Spalte := 1;
      while Spalte <= inDaten^.BrettBreite do
      begin
        Richtung := RICHTUNGNORDOST;
        while Richtung <= RICHTUNGSUED do
        begin
          if HoleReihenAnzahl (inDaten, Zeile, Spalte, Richtung,
                               inSpieler) = 3 then
            if HoleReihenAnzahl (inDaten, Zeile, Spalte, Richtung,
                                 inGegner) = 0 then
              UeberpruefeLeerfelderInDreierreihe
                (inDaten, Zeile, Spalte, Richtung,
                 inSpieler, inGegner, BestWert,
                 outBrettZeile, outBrettSpalte);
          Richtung := Richtung + 1
        end;  { while }
        Spalte := Spalte + 1
      end;  { while }
      Zeile := Zeile + 1
    end;  { while }

    NutzeOderStoppeDreier := BestWert > (-MaxInt);

  end;  { NutzeOderStoppeDreier }





  function SucheZufallszugInNachbarschaft (
                 inDaten : tSpieldaten;
             var outBrettZeile : tBrettKoord;
             var outBrettSpalte : tBrettKoord) : boolean;

  { Suche nach einem Zufallszug in der Nachbarschaft anderer
    Steine
    inDaten: Zeiger auf die Spieldaten
    outBrettZeile: Zeile des Zufallszuges
    outBrettSpalte: Spalte des Zufallszuges
    Rueckgabe: true: Zufallszug gefunden
               false: kein Zufallszug gefunden,
                      outBrettZeile & outBrettSpalte undef. }

    var
    Zeile : tBrettKoord;
    Spalte : tBrettKoord;
    Gueltig : boolean;

  begin

    LeereZugListe;
    for Zeile := 1 to inDaten^.BrettHoehe do
      for Spalte := 1 to inDaten^.BrettBreite do
        if HoleSpielfeldStatus (inDaten, Zeile, Spalte, Gueltig)
            = LEER then
          if Gueltig then
            if IstUmgebungBelegt (inDaten, Zeile, Spalte) then
              SpeichereZug (Zeile, Spalte);
    SucheZufallszugInNachbarschaft
       := HoleZufallsZug (outBrettZeile, outBrettSpalte)

  end;  { SucheZufallszugInNachbarschaft }





  procedure ErzeugeCSZug (
                  inDaten : tSpieldaten;
                  inCSpieler : tSpieler;
                  inGegner : tSpieler;
                  inSpielstaerke : tCSStaerke;
              var outBrettZeile : tBrettKoord;
              var outBrettSpalte : tBrettKoord);

  { Bestimmung eines Zuges des Computerspielers
    inDaten: Zeiger auf die Spieldaten
    inCSpieler: Spielercode des Computerspielers
    inGegner: Spielercode des (menschl.) Gegners
    inSpielstaerke: Spielstaerke des Computerspielers
    outBrettZeile: Zeile des Computerzuges
    outBrettSpalte: Spalte des Computerzuges }

    var
    Fertig : boolean;
    Gueltig : boolean;
    Zeile : tBrettKoord;
    Spalte : tBrettKoord;
    BestWert : integer;
    Wert : integer;

  begin

    if inSpielstaerke <= 1 then
    begin

      { Suche nach eigenem Gewinnzug und fuehre ihn aus }
      Fertig := SucheGewinnzug (inDaten, inCSpieler, inGegner,
                                outBrettZeile, outBrettSpalte);

      if not Fertig then
      begin
        { Stoppe Gegner-Gewinnzug }
        Fertig := SucheGewinnzug (inDaten, inGegner, inCSpieler,
                                  outBrettZeile, outBrettSpalte);

        if not Fertig then
        begin

          if inSpielstaerke > 0 then
          { Spielstaerke = 1 behandelt auch Dreierreihen }
          begin
            { Suche nach eigener offener Dreierreihe -> Vierer }
            Fertig := NutzeOderStoppeDreier (inDaten, inCSpieler,
                                             inGegner, outBrettZeile,
                                             outBrettSpalte);
            if not Fertig then
            begin
              { Stoppe offene Gegner-Dreierreihe }
              Fertig := NutzeOderStoppeDreier (inDaten, inGegner,
                                               inCSpieler,
                                               outBrettZeile,
                                               outBrettSpalte)
            end
          end;   { if inSpielstaerke > 0 }

          if not Fertig then
          begin
            { Immer noch keinen Zug gefunden }
            { Zufallszug in der Nachbarschaft eig./fremder Steine }
            Fertig := SucheZufallszugInNachbarschaft
                         (inDaten, outBrettZeile, outBrettSpalte);
            if not Fertig then
            begin
              { immer noch nichts, da das Brett leer ist:
                zufaelligen Zug erzeugen }
              outBrettZeile := BestimmeZufallsZahl(1, inDaten^.BrettHoehe);
              outBrettSpalte := BestimmeZufallsZahl(1, inDaten^.BrettBreite)
            end

          end  { if }

        end  { if }

      end  { if }

    end  { if inSpielstaerke <= 1 }

    else

    begin  { if inSpielstaerke = 2 }

      { Position, wenn 1. Zug }
      outBrettZeile := BestimmeZufallsZahl(1+(inDaten^.BrettHoehe div 4),
                                           inDaten^.BrettHoehe-
                                           (inDaten^.BrettHoehe div 4));
      outBrettSpalte := BestimmeZufallsZahl(1+(inDaten^.BrettBreite div 4),
                                            inDaten^.BrettBreite-
                                            (inDaten^.BrettBreite div 4));
      Bestwert := -MaxInt;
      if inDaten^.NochNichtBelegt < inDaten^.BrettHoehe *
                                    inDaten^.BrettBreite then

        { Feld mit bester Bewertung suchen, wenn nicht 1. Zug }

        for Zeile := 1 to inDaten^.BrettHoehe do
          for Spalte := 1 to inDaten^.BrettBreite do
            if HoleSpielfeldStatus (inDaten, Zeile, Spalte, Gueltig)
               = LEER then
            begin
              Wert := Positionsbewertung(inDaten,Zeile,Spalte,
                                         inCSpieler,inGegner);
              if Wert > BestWert then
              begin
                outBrettZeile := Zeile;
                outBrettSpalte := Spalte;
                BestWert := Wert
              end
            end

    end  { if inSpielstaerke = 2 }

  end;  { ErzeugeCSZug }





  procedure Initialierung;

  { Initialisierung der Unit CompPlay }

    var
    i : integer;

  begin

    Randomize;
    VerarbeiteAufrufParameter;
    Spielstufe := MAXCSSTAERKE;
    Liste := nil;
    Anzahl := 0;
    ErsterZug := nil;
    LetzterZug := nil;
    AktuellerZug := nil;
    ReihenwertAdd[0] := 0;
    ReihenwertAdd[1] := 3;
    ReihenwertAdd[2] := 12;
    ReihenwertAdd[3] := 60;
    ReihenwertAdd[4] := 300;
    ReihenwertAdd[5] := 0;
    ReihenwertAkk[0] := 0;
    for i:=1 to 5 do
      ReihenwertAkk[i] := ReihenwertAkk[i-1] + ReihenwertAdd[i];
    Bewertungsfaktor := 13;
    Zufallsfaktor := 5;
    new ( Spieldaten );
    ZuruecksetzenSpieldaten ( Spieldaten, INITBRETTGROESSE,
                              INITBRETTGROESSE );

  end;  { Initialierung }





  { ----- Interface-Funktionen/-Prozeduren ----- }





  procedure gibStatus ( var Status: tStatus );

  { Der Status des aktuellen Spiels kann abgefragt werden.
    Am Anfang (ohne neuesSpiel) UNDEFINIERT.
    Nach neuesSpiel EINS_AM_ZUG, spaeter nach setzeStein
    oder ComputerZug entsprechend EINS_AM_ZUG bzw. ZWEI_AM_ZUG.
    Wenn die Partie durch den letzten Zug beendet wurde, dann
    EINS_GEWINNT, ZWEI_GEWINNT oder UNENTSCHIEDEN. }

  begin

    Status := Spieldaten^.Spielstatus

  end;  { gibStatus }





  procedure neuesSpiel ( var ok: boolean );

  { Ein neues Spiel wird mit den aktuellen Einstellungen begonnen.
    ok = false, falls das aus irgendeinem Grund unmoeglich sein sollte. }

  begin

    ZuruecksetzenSpieldaten ( Spieldaten, Spieldaten^.BrettHoehe,
                              Spieldaten^.BrettBreite );
    Spieldaten^.Spielstatus := EINS_AM_ZUG;
    ok := true;

  end;  { neuesSpiel }





  procedure setzeStein (     x: integer;
                             y: integer;
                         var ok: boolean );

  { Es wird ein Stein auf das Brett gesetzt ( Koordinaten x, y ).
    setzeStein kann beliebig oft HINTEREINANDER aufgerufen werden,
    z. B. um eine Stellung auf dem Brett darzustellen.
    Sollte dieser Zug nicht moeglich sein, ist ok = false. }

    var
    Spieler : tSpieler;
    Gegner : tSpieler;

  begin

    ok := false;

    if (x >= 1) and
       (x <= Spieldaten^.BrettBreite) and
       (y >= 1) and
       (y <= Spieldaten^.BrettHoehe) and
       ((Spieldaten^.Spielstatus = EINS_AM_ZUG) or
        (Spieldaten^.Spielstatus = ZWEI_AM_ZUG)) then
    begin
      BestimmeSpielerGegnerVorZug ( Spieler, Gegner );
      if SetzeSpielfeld( Spieldaten, y, x, Spieler )
      then
      begin
        ok := true;
        NeuerZugInSpielverlauf ( y, x, Spieldaten^.Spielstatus, -1)
      end
    end

  end;  { setzeStein }





  procedure computerZug ( var x: integer;
                          var y: integer;
                          var ok: boolean );

  { Der Computer macht einen Zug fuer EINS oder ZWEI, wer grad am Zug ist.
    computerZug kann beliebig oft HINTEREINANDER aufgerufen werden, der
    Computer kann also JEDERZEIT einen Zug fuer die entsprechende Seite
    machen. Sollte kein Zug moeglich sein, ist ok = false. }

    var
    Spieler : tSpieler;
    Gegner : tSpieler;
    Brettzeile : tBrettKoord;
    Brettspalte : tBrettKoord;

  begin

    ok := false;
    if (Spieldaten^.Spielstatus = EINS_AM_ZUG) or
       (Spieldaten^.Spielstatus = ZWEI_AM_ZUG) then
    begin
      BestimmeSpielerGegnerVorZug ( Spieler, Gegner );
      ErzeugeCSZug ( Spieldaten, Spieler, Gegner, Spielstufe,
                     Brettzeile, Brettspalte );
      x := Brettspalte;
      y := Brettzeile;
      if SetzeSpielfeld( Spieldaten, y, x, Spieler )
      then
      begin
        ok := true;
        NeuerZugInSpielverlauf ( y, x, Spieldaten^.Spielstatus,
                                 Spielstufe)
      end
    end

  end;  { computerZug }





  procedure zugZurueck ( var x: integer;
                         var y: integer;
                         var ok: boolean );

  { Die Ruecknahme eines Zuges. ok = false wenn nicht moeglich.
    zugZurueck kann beliebig oft hintereinander aufgerufen werden.
    zugZurueck nimmt NUR EINEN Zug zurueck. }

  begin

    if AktuellerZug = nil then
      ok := false
    else
    begin
      x := AktuellerZug^.BrettSpalte;
      y := AktuellerZug^.BrettZeile;
      AktuellerZug := AktuellerZug^.VorherigerZug;
      if ZuruecksetzenSpielfeld ( Spieldaten, y, x ) then
        ok := true
    end

  end;  { zugZurueck }





  procedure zugVor ( var x: integer;
                     var y: integer;
                     var ok: boolean );

  { Ein Zug, der mit zugZurueck zurueckgenommen wurde, wird wieder gesetzt.
    zugVor macht KEINE NEUEN ZUEGE. ok = false, falls kein Zug mehr
    vorhanden ist. zugVor kann beliebig oft aufgerufen werden.
    zugVor setzt NUR EINEN Zug. }

    var
    Spieler : tSpieler;
    Gegner : tSpieler;

  begin

    if (AktuellerZug = nil) and (ErsterZug <> nil) then
    begin
      ok := true;
      AktuellerZug := ErsterZug
    end
    else
    begin
      if AktuellerZug = nil then
        ok := false
      else
      begin
        if AktuellerZug^.NaechsterZug = nil then
          ok := false
        else
        begin
          ok := true;
          AktuellerZug := AktuellerZug^.NaechsterZug
        end
      end
    end;  { if }

    if ok then
    begin
      ok := false;
      x := AktuellerZug^.BrettSpalte;
      y := AktuellerZug^.BrettZeile;
      if (Spieldaten^.Spielstatus = EINS_AM_ZUG) or
         (Spieldaten^.Spielstatus = ZWEI_AM_ZUG) then
      begin
        BestimmeSpielerGegnerVorZug ( Spieler, Gegner );
        ok := SetzeSpielfeld ( Spieldaten, y, x, Spieler );
      end
    end  { if ok }

  end;  { zugVor }





  procedure setzeSpielstufe (     Stufe: integer;
                              var ok: boolean );

  { Die aktuelle Spielstufe des Computers wird gesetzt,
    ok = false bei illegaler Spielstufe.
    Bei Eingabe einer illegalen Spielstufe wird
    die aktuelle Spielstufe beibehalten. }

  begin

    if ((Stufe >= 0) and (Stufe <= 2)) then
    begin
      Spielstufe := Stufe;
      ok := true
    end
    else
      ok := false

  end;  { setzeSpielstufe }





  procedure gibSpielstufe ( var Stufe: integer );

  { Die aktuelle Spielstufe wird abgefragt.
    Vor dem ersten Aufruf von setzeSpielstufe ist Stufe=2. }

  begin

    Stufe := Spielstufe

  end;  { gibSpielstufe }





  procedure setzeFeldgroesse (     x: integer;
                                   y: integer;
                               var ok: boolean );

  { Die Groesse des Spielfeldes wird gesetzt. Das Spielfeld ist rechteckig
    und besteht aus x mal y Kaestchen, beide zwischen 5 und 30.
    Bei Erfolg ist der Status = UNDEFINIERT, danach ist neuesSpiel
    notwendig, ok = false bei illegaler Feldgroesse.
    Die aktuelle Feldgroesse wird bei einer illegalen Eingabe beibehalten,
    ebenso der Status. }

  begin

    if (x >= 5) and (x <= 30) and (y >= 5) and (y <= 30) then
    begin
      ZuruecksetzenSpieldaten ( Spieldaten, y, x );
      ok := true
    end
    else
      ok := false

  end;  { setzeFeldgroesse }





  procedure gibFeldgroesse ( var x: integer;
                             var y: integer );

  { Die Groesse des Spielfeldes wird abgefragt.
    Vor dem ersten Aufruf von setzeFeldgroesse gilt x = y = 18. }

  begin

    x := Spieldaten^.BrettBreite;
    y := Spieldaten^.BrettHoehe

  end;  { gibFeldgroesse }





  procedure gibGewinnreihe ( var x1: integer;
                             var y1: integer;
                             var x2: integer;
                             var y2: integer;
                             var ok: boolean );

  { Der Anfangsstein x1,y1 und der Endstein x2,y2 einer Gewinnreihe wird
    uebergeben. ok = false falls noch kein Gewinner existiert. }

  begin

    ok := false;
    if (Spieldaten^.Spielstatus = EINS_GEWINNT) or
       (Spieldaten^.Spielstatus = ZWEI_GEWINNT) then
    begin
      case Spieldaten^.GewinnerRichtung of
        RICHTUNGNORDOST :
          begin
            x1 := Spieldaten^.GewinnerBrettSpalte;
            y1 := Spieldaten^.GewinnerBrettZeile;
            x2 := Spieldaten^.GewinnerBrettSpalte + 4;
            y2 := Spieldaten^.GewinnerBrettZeile - 4;
          end;
        RICHTUNGOST :
          begin
            x1 := Spieldaten^.GewinnerBrettSpalte;
            y1 := Spieldaten^.GewinnerBrettZeile;
            x2 := Spieldaten^.GewinnerBrettSpalte + 4;
            y2 := Spieldaten^.GewinnerBrettZeile
          end;
        RICHTUNGSUEDOST :
          begin
            x1 := Spieldaten^.GewinnerBrettSpalte;
            y1 := Spieldaten^.GewinnerBrettZeile;
            x2 := Spieldaten^.GewinnerBrettSpalte + 4;
            y2 := Spieldaten^.GewinnerBrettZeile + 4
          end;
        RICHTUNGSUED :
          begin
            x1 := Spieldaten^.GewinnerBrettSpalte;
            y1 := Spieldaten^.GewinnerBrettZeile;
            x2 := Spieldaten^.GewinnerBrettSpalte;
            y2 := Spieldaten^.GewinnerBrettZeile + 4
          end;
      end;  { case }
      ok := true
    end  { if }

  end;  { gibGewinnreihe }


begin   { Initialisierung der Unit CompPlay }


  Initialierung


end.  { CompPlay }
