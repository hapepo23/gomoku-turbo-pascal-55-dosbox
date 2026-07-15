unit GrafHilf;

{ Die Unit GrafHilf stellt allgemeine Hilfprogramme
  zum Handling einer VGA-Graphikbildschirmoberflaeche 640x480
  zur Verfuegung: Maussteuerung, Ausgaberoutinen, usw. }

{ Datei in Zei.-Satz IBM850 -> „=84 ”=94 =81 Ž=8E ™=99 š=9A á=E1,
  Zeilenende DOS/Windows -> 0D+0A }


interface


  { oeffentliche Konstanten }

  { Farben }

  const
  SCHWARZ = 0;
  GRAU8 = 1;
  GRAU7 = 2;
  GRAU6 = 3;
  GRAU5 = 4;
  GRAU4 = 5;
  GRAU3 = 6;
  GRAU2 = 7;
  GRAU1 = 8;
  ROT = 9;
  GELB = 10;
  GRUEN = 11;
  CYAN = 12;
  BLAU = 13;
  MAGENTA = 14;
  WEISS = 15;


  { Bildschirmkonstanten: max./min Koordinaten/Groessen }

  const
  MINBSX = 0;
  MAXBSX = 639;
  MAXBSBREITE = 640;
  MINBSY = 0;
  MAXBSY = 479;
  MAXBSHOEHE = 480;


  { Mauszeigerformen }

  const
  ARROWCURSOR = 1;
  HANDCURSOR = 2;


  { oeffentliche Typen }

  type
  tFarbe = SCHWARZ..WEISS;
           { Farbcode }
  tBildschXKoord = MINBSX..MAXBSX;
           { X-Koordinaten von links nach rechts }
  tBildschYKoord = MINBSY..MAXBSY;
           { Y-Koordinaten von oben nach unten }
  tBildschObjHoehe = 1..MAXBSHOEHE;
           { Hoehe eines Objekts auf dem Grafikbildschirm in Pixel }
  tBildschObjBreite = 1..MAXBSBREITE;
           { Breite eines Objekts auf dem Grafikbildschirm in Pixel }
  tCursorTyp = ARROWCURSOR..HANDCURSOR;
           { Mauszeigertypen }


  { oeffentliche Prozeduren }

  function InitialisiereMaus (
             var outAnzahlMausKnoepfe : integer) : Boolean;
  { Pruefung, ob eine Maus installiert ist, wenn ja:
    Bestimmung der Knopfanzahl und Initialisierung. }

  procedure ZeigeMauszeiger;
  { Einschalten des Mauszeigers }

  procedure VersteckeMauszeiger;
  { Ausschalten des Mauszeigers }

  procedure SetzeMausCursor (
              inTyp : tCursorTyp);
  { Die Form des Mauszeiger aendern/einstellen }

  procedure BewegeMauszeigerNach (
              inX : tBildschXKoord;
              inY : tBildschYKoord);
  { Den Mauszeiger zu einer Bildschirmposition (inX,inY) bewegen }

  function IstLinkeMaustasteLosgelassen (
             var outX : tBildschXKoord;
             var outY : tBildschYKoord) : Boolean;
  { Die Mausinformationen abfragen: aktuelle Mausposition und
    den Status der linken Maustaste (Loslassen) }

  procedure SetzeMauszeigerInBildmitte;
  { Den Mauszeiger in die Bildschirmmitte setzen }

  procedure WarteAufMaus (
              var outX : tBildschXKoord;
              var outY : tBildschYKoord);
  { Auf das Ende eines (linken) Tastendruck mit der Maus
    warten (Loslassen) und, wenn erfolgt, die Koordinaten zurueckgeben.
    Ausserdem wird der Tastaturpuffer geleert. }

  function IstMausKlickInGebiet (
             inX : tBildschXKoord;
             inY : tBildschYKoord;
             inBreite : tBildschObjBreite;
             inHoehe : tBildschObjHoehe;
             inKlickX : tBildschXKoord;
             inKlickY : tBildschYKoord) : Boolean;
  { Ueberpruefung, ob ein Mausklick an den Koordinaten (inKlickX,
    inKlickY) innerhalb eines rechteckigen Bildschirmbereichs
    (dem Pruefgebiet) erfolgte. }

  function InitialisiereGrafikbildschirmUndMaus : Boolean;
  { Initialisierung des Bildschirms (640x480 VGA-Grafikmodus) und
    der Maus. Dabei wird auch eine neue Palette initialisiert. }

  procedure AbschlussarbeitenGrafikbildschirmUndMaus (
              inText : string);
  { Arbeiten bei Programmende, alten Modus setzen, Bildschirm
    loeschen, usw. }

  procedure AusgebenFarbigenTextAnPos (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inFarbe : tFarbe;
              inText : string);
  { Ausgabe von Text inText in der Farbe inFarbe an der Position
    (inX,inY). }

  procedure LoescheBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);
  { Erzeugt ein graufarbiges Rechteck und loescht damit
    ein Objekt }

  procedure MaleGraueBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inErhoeht : Boolean);
  { Erzeugt ein graufarbiges Rechteck mit einem 3D Effekt
    (erhoeht oder vertieft aussehend) als Basis fuer graphische
    Elemente wie Fenster, Knoepfe, usw. }

  procedure MaleKnopf (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inText : string);
  { Zeichnet einen Knopf mit Beschriftung }

  procedure Ankreuzen (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);
  { Zeichnet ein Kreuz }

  procedure MaleAbbruchKnopf (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);
  { Zeichnet einen AbbruchKnopf }

  procedure MaleBasisBildschirm (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inText : string);
  { Loescht den Bildschirm und erzeugt ein "Fenster"-artiges
    Rechteck, mit Titelleiste, Ende-Knopf. }

  procedure AusgebenFarbigenTextInBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inFarbe : tFarbe;
              inText : string);
  { Ausgabe von Text inText in der Farbe inFarbe in einem rechteckigen
    Bildschirmbereich mit automatischem Umbruch. Der Bereich wird vorher
    geloescht. }

  procedure MaleAnkreuzOption (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inWert : Boolean;
              inAnzeige : Boolean);
  { Ein Optionsfeld malen/loeschen und ggf. mit Kreuz markieren }

  procedure BildRestaurieren ( inX : tBildschXKoord;
                               inY : tBildschYKoord;
                               inImage : Pointer;
                               inSize : word );
  { Teilbildschirm wieder anzeigen und Speicher freigeben }

  function JaNeinAbfragePopup (
              inTitel : string;
              inMeldung : string;
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe ) : boolean;
  { Ein Meldungsfenster ("Popup") anzeigen und
    JA/NEIN-Antwort entgegennehmen und zurueckgeben }

  procedure MeldungsPopupAnzeigen (
                  inTitel : string;
                  inMeldung : string;
                  inKnopftext : string;
                  inX : tBildschXKoord;
                  inY : tBildschYKoord;
                  inBreite : tBildschObjBreite;
                  inHoehe : tBildschObjHoehe;
              var outSize : word;
              var outImage : Pointer );
  { Ein Meldungsfenster ("Popup") nur anzeigen }

  function CheckMeldungsPopupKlick (
               inKnopftext : string;
               inX : tBildschXKoord;
               inY : tBildschYKoord;
               inBreite : tBildschObjBreite;
               inHoehe : tBildschObjHoehe;
               inXKlick : tBildschXKoord;
               inYKlick : tBildschYKoord) : Boolean;
  { Klickkoordinaten in Bezug auf ein Meldungsfenster ("Popup")
    pruefen }

  procedure MeldungsPopup (
              inTitel : string;
              inMeldung : string;
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe );
  { Ein Meldungsfenster ("Popup") anzeigen und
    OK-Antwort entgegennehmen }

  procedure AusgebenFarbigenTextInFarbBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inFarbe : tFarbe;
              inBoxFarbe : tFarbe;
              inText : string);
  { Ausgabe von Text inText (einzeilig) in der Farbe inFarbe in einer
    Box an der Position (inX,inY) mit Hintergrundfarbe inBoxFarbe. }




implementation


  uses
  Dos,
  Crt,
  Graph,
  Hilfen;


  { private Konstanten }

  { Grafiktreiber-Konstanten }

  const
  GRAFIKTREIBER = vga;
                { Treibertyp = VGA }
  GRAFIKMODUS = vgahi;
                { Modus = Hohe VGA-Aufloesung }
  GRAFIKPFAD1 = 'C:\TP\GRAPHICS';
                { 1. Suchpfad fuer BGI-Datei }
  GRAFIKPFAD2 = '';
                { 2. Suchpfad fuer BGI-Datei = aktuelles Verzeichnis }

  { Mauszeiger-Datentyp & -Konstanten }

  type
  tCursorData = array [1..32] of word;
  const
  ARROWCURSORDATA : tCursorData = ($7fff, $3fff, $1fff, $0fff, $07ff,
                                   $03ff, $01ff, $00ff, $007f, $03ff,
                                   $03ff, $29ff, $71ff, $f0ff, $faff,
                                   $f8ff, $8000, $C000, $A000, $9000,
                                   $8800, $8400, $8200, $8100, $8f80,
                                   $9400, $b400, $d200, $8a00, $0900,
                                   $0500, $0700);
                    { Daten fuer den Pfeil-Mauszeiger }

  HANDCURSORDATA : tCursorData = ($e1ff, $e1ff, $e1ff, $e1ff, $e1ff,
                                  $e000, $e000, $e000, $0000, $0000,
                                  $0000, $0000, $0000, $0000, $0000,
                                  $0000, $1e00, $1200, $1200, $1200,
                                  $1200, $13ff, $1249, $1249, $f249,
                                  $9001, $9001, $9001, $8001, $8001,
                                  $8001, $ffff);
                    { Daten fuer den Hand-Mauszeiger }

  { Typ & Farben/Raenderfarben der grauen Box (Knopf, Vertiefung) }

  type
  tSchattenFarben = array [1..3, Boolean] of tFarbe;

  const
  GRAUEBOXFARBE : tFarbe = GRAU3;
                  { Grundfarbe der grauen Box }
  GRAUEBOXRANDFARBE1 : tSchattenFarben
                          = ((GRAU6, WEISS), (GRAU5, GRAU1),
                             (GRAU4, GRAU2));
                  { Raenderfarben der grauen Box, oben/links,
                    jeweils vertieft/erhoeht }
  GRAUEBOXRANDFARBE2 : tSchattenFarben
                          = ((WEISS, GRAU6), (GRAU1, GRAU5),
                             (GRAU2, GRAU4));
                  { Raenderfarben der grauen Box, unten/rechts,
                    jeweils vertieft/erhoeht }





  function InitialisiereMaus (
             var outAnzahlMausKnoepfe : integer) : Boolean;

  { Pruefung, ob eine Maus installiert ist, wenn ja:
    Bestimmung der Knopfanzahl und Initialisierung.
    Wichtig: Endet diese Routine mit false, duerfen keine Maus-
    Routinen im weiteren Programmverlauf aufgerufen werden.
    outAnzahlMausKnoepfe: Anzahl Mausknoepfe
    Rueckgabe: true: OK, Maus vorhanden, false: keine Maus }

    var
    r : Registers;

  begin

    r.ax := $0000;
    intr ($33, r);
    if r.ax = $FFFF then
    begin
      InitialisiereMaus := true;
      outAnzahlMausKnoepfe := r.bl;
    end
    else
    begin
      InitialisiereMaus := false;
      outAnzahlMausKnoepfe := 0;
    end;  { if }

  end;  { InitialisiereMaus }





  procedure ZeigeMauszeiger;

  { Einschalten des Mauszeigers }

    var
    r : Registers;

  begin

    r.ax := $0001;
    intr ($33, r);

  end;  { ZeigeMauszeiger }





  procedure VersteckeMauszeiger;

  { Ausschalten des Mauszeigers }

    var
    r : Registers;

  begin

    r.ax := $0002;
    intr ($33, r);

  end;  { VersteckeMauszeiger }





  procedure SetzeMausCursor (
              inTyp : tCursorTyp);

  { Die Form des Mauszeiger aendern/einstellen
    inTyp: ARROWCURSOR=Pfeilzeiger, HANDCURSOR=Hand-Zeiger }

    var
    r : Registers;

  begin

    r.AX := $0009;

    if inTyp = ARROWCURSOR then
    begin
      r.BX := $0000;
      r.CX := $0000;
      r.ES := Seg (ARROWCURSORDATA);
      r.DX := Ofs (ARROWCURSORDATA);
    end
    else  { HANDCURSOR }
    begin
      r.BX := $0004;
      r.CX := $0000;
      r.ES := Seg (HANDCURSORDATA);
      r.DX := Ofs (HANDCURSORDATA);
    end;  { if }

    intr ($33, r)

  end;  { SetzeMausCursor }





  procedure BewegeMauszeigerNach (
              inX : tBildschXKoord;
              inY : tBildschYKoord);

  { Den Mauszeiger zu einer Bildschirmposition (inX,inY) bewegen
    inX: X-Bildschirmkoord., zu der der Mauszeiger bewegt werden soll
    inY: Y-Bildschirmkoord., zu der der Mauszeiger bewegt werden soll }

    var
    r : Registers;

  begin

    r.ax := $0004;
    r.cx := inX;
    r.dx := inY;
    intr ($33, r)

  end;  { BewegeMauszeigerNach }





  function IstLinkeMaustasteLosgelassen (
             var outX : tBildschXKoord;
             var outY : tBildschYKoord) : Boolean;

  { Die Mausinformationen abfragen: aktuelle Mausposition und
    den Status der linken Maustaste (Loslassen)
    outX: Aktueller Ort des Mauszeiger: X-Bildschirmkoordinate
    outY: Aktueller Ort des Mauszeiger: Y-Bildschirmkoordinate
    Rueckgabe: true: linke Maustaste gerade losgelassen; false: nein }

    var
    r : Registers;

  begin

    r.ax := $0006;
    r.bx := $0000;
    intr ($33, r);
    outX := r.cx;
    outY := r.dx;
    IstLinkeMaustasteLosgelassen := (r.bx > 0);

  end;  { IstLinkeMaustasteLosgelassen }





  procedure SetzeMauszeigerInBildmitte;

  { Den Mauszeiger in die Bildschirmmitte setzen }

  begin

    BewegeMauszeigerNach (MAXBSX div 2, MAXBSY div 2)

  end;  { SetzeMauszeigerInBildmitte }





  procedure WarteAufMaus (
              var outX : tBildschXKoord;
              var outY : tBildschYKoord);

  { Auf das Ende eines (linken) Tastendruck mit der Maus
    warten (Loslassen) und, wenn erfolgt, die Koordinaten zurueckgeben.
    Ausserdem wird der Tastaturpuffer geleert.
    outX: Aktueller Ort des Mauszeiger: X-Bildschirmkoordinate
    outY: Aktueller Ort des Mauszeiger: Y-Bildschirmkoordinate }

    var
    KlickEndet : Boolean;

  begin

    ZeigeMauszeiger;
    KlickEndet := false;
    while not KlickEndet do
      KlickEndet := IstLinkeMaustasteLosgelassen (outX, outY);
    VersteckeMauszeiger;
    LoescheTasten;

  end;  { WarteAufMaus }





  function IstMausKlickInGebiet (
             inX : tBildschXKoord;
             inY : tBildschYKoord;
             inBreite : tBildschObjBreite;
             inHoehe : tBildschObjHoehe;
             inKlickX : tBildschXKoord;
             inKlickY : tBildschYKoord) : Boolean;

  { Ueberpruefung, ob ein Mausklick an den Koordinaten (inKlickX,
    inKlickY) innerhalb eines rechteckigen Bildschirmbereichs
    (dem Pruefgebiet) erfolgte.
    inX: X-Koordinate der linken oberen Ecke des Pruefgebiets
    inY: Y-Koordinate der linken oberen Ecke des Pruefgebiets
    inBreite: Breite des Pruefgebiets
    inHoehe: Hoehe des Pruefgebiets
    inKlickX: X-Koordinate des Mausklicks
    inKlickY: Y-Koordinate des Mausklicks
    Rueckgabe: true: Mausklick im Pruefgebiet; false: nein }

    var
    Ergebnis : Boolean;

  begin

    Ergebnis := false;
    if inKlickY >= inY then
      if inKlickY < (inY + inHoehe) then
        if inKlickX >= inX then
          if inKlickX < (inX + inBreite) then
            Ergebnis := true;
    IstMausKlickInGebiet := Ergebnis;

  end;  { IstMausKlickInGebiet }





  function InitialisiereGrafikbildschirmUndMaus : Boolean;

  { Initialisierung des Bildschirms (640x480 VGA-Grafikmodus) und
    der Maus. Dabei wird auch eine neue Palette initialisiert.
    Rueckgabe: true:  Programm beenden, da keine Maus vorhanden
                      oder keine BGI-Datei gefunden
               false: Init. OK, Programm kann beginnen }

    var
    Beenden : Boolean;
    Treiber : integer;
    Modus : integer;
    Fehler : integer;
    Farbe : integer;
    Intensitaet : integer;
    AnzahlMausKnoepfe : integer;
    IstMausInstalliert : Boolean;

  begin

    Treiber := GRAFIKTREIBER;
    Modus := GRAFIKMODUS;
    InitGraph (Treiber, Modus, GRAFIKPFAD1);
    Fehler := GraphResult;
    if Fehler <> grok then
    begin
      Treiber := GRAFIKTREIBER;
      Modus := GRAFIKMODUS;
      InitGraph (Treiber, Modus, GRAFIKPFAD2);
      Fehler := GraphResult
    end;  { if }

    if Fehler <> grok then
    begin
      writeln ('Grafiktreiberfehler: ', GraphErrorMsg (Fehler));
      writeln ('Hinweis: Die Treiber muessen in ' + GRAFIKPFAD1);
      writeln ('         oder im aktuellen Verzeichnis vorliegen.');
      writeln ('Programm wird abgebrochen.');
      WarteAufTaste;
      Beenden := true
    end
    else  { kein Treiber-Fehler }
    begin

      { Palette entsprechend den oben def. Farb-Konstanten setzen:
        SCHWARZ, GRAU8, GRAU7, GRAU6, GRAU5, GRAU4, GRAU3, GRAU2,
        GRAU1, ROT, GELB, GRUEN, CYAN, BLAU, MAGENTA, WEISS }
      SetRGBPalette (16, 0, 0, 0);
      for Farbe := 1 to 8 do
        begin
          Intensitaet := (Farbe*256) div 36;
          SetRGBPalette (Farbe + 16, Intensitaet, Intensitaet,
                         Intensitaet);
        end;
      SetRGBPalette (25, 63, 0, 0);
      SetRGBPalette (26, 63, 63, 0);
      SetRGBPalette (27, 0, 40, 0);
      SetRGBPalette (28, 0, 63, 63);
      SetRGBPalette (29, 0, 0, 63);
      SetRGBPalette (30, 63, 0, 63);
      SetRGBPalette (31, 63, 63, 63);
      for Farbe := 0 to 15 do
        begin
          SetPalette (Farbe, Farbe + 16);
        end;

      IstMausInstalliert := InitialisiereMaus (AnzahlMausKnoepfe);

      if not IstMausInstalliert then
      begin
        writeln ('Keine Maus gefunden. Programm wird abgebrochen.');
        WarteAufTaste;
        Beenden := true
      end
      else
      begin
        SetzeMausCursor (HANDCURSOR);
        Beenden := false
      end  { if }

    end;  { if }

    InitialisiereGrafikbildschirmUndMaus := Beenden

  end;  { InitialisiereGrafikbildschirmUndMaus }





  procedure AbschlussarbeitenGrafikbildschirmUndMaus (
              inText : string);

  { Arbeiten bei Programmende, alten Modus setzen, Bildschirm
    loeschen, usw.
    inText: Text, der danach ausgegeben werden soll }

  begin

    VersteckeMauszeiger;
    CloseGraph;
    LoescheTasten;
    writeln (inText)

  end;  { AbschlussarbeitenGrafikbildschirmUndMaus }





  procedure AusgebenFarbigenTextAnPos (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inFarbe : tFarbe;
              inText : string);

  { Ausgabe von Text inText in der Farbe inFarbe an der Position
    (inX,inY).
    inX: X-Koordinate, an der der Text ausgegeben werden soll
    inY: Y-Koordinate, an der der Text ausgegeben werden soll
    inFarbe: Textfarbe
    inText: auszugebender Text }

  begin

    Setcolor (inFarbe);
    OutTextXY (inX, inY, inText);
    Setcolor (SCHWARZ);

  end;  { AusgebenFarbigenTextAnPos }





  procedure LoescheBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);

  { Erzeugt ein graufarbiges Rechteck und loescht damit
    ein Objekt
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des Rechtecks
    inHoehe: Hoehe des Rechtecks }

  begin

    setfillstyle (1, GRAU3);
    bar (inX, inY, inX + inBreite, inY + inHoehe);

  end;  { LoescheBox }





  procedure MaleGraueBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inErhoeht : Boolean);

  { Erzeugt ein graufarbiges Rechteck mit einem 3D Effekt
    (erhoeht oder vertieft aussehend) als Basis fuer graphische
    Elemente wie Fenster, Knoepfe, usw.
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des Rechtecks
    inHoehe: Hoehe des Rechtecks
    inErhoeht: true: erhoeht aussehend,
               false: vertieft aussehend }

    var
    Randindex : 1..3;
    X2 : tBildschXKoord;
    Y2 : tBildschYKoord;

  begin

    X2 := inX + inBreite;
    Y2 := inY + inHoehe;
    setfillstyle (1, GRAU3);
    bar (inX + 3, inY + 3, X2 - 3, Y2 - 3);
    for Randindex := 1 to 3 do
      begin
        Setcolor (GRAUEBOXRANDFARBE1[Randindex, inErhoeht]);
        line (inX + Randindex, inY + Randindex, X2 - Randindex,
              inY + Randindex);
        line (inX + Randindex, inY + Randindex, inX + Randindex,
              Y2 - Randindex);
      end;
    for Randindex := 1 to 3 do
      begin
        Setcolor (GRAUEBOXRANDFARBE2[Randindex, inErhoeht]);
        line (X2 - Randindex, inY + Randindex, X2 - Randindex,
              Y2 - Randindex);
        line (inX + Randindex, Y2 - Randindex, X2 - Randindex,
              Y2 - Randindex);
      end

  end;  { MaleGraueBox }





  procedure MaleKnopf (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inText : string);

  { Zeichnet einen Knopf mit Beschriftung
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des Knopfes
    inHoehe: Hoehe des Knopfes
    inText: Beschriftung }

  begin

    MaleGraueBox (inX, inY, inBreite, inHoehe, true);
    AusgebenFarbigenTextAnPos (inX + (inBreite div 2)
                                - (TextWidth (inText) div 2),
                               inY + (inHoehe div 2)
                                - (TextHeight (inText) div 2),
                               SCHWARZ, inText);

  end;  { MaleKnopf }





  procedure Ankreuzen (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);

  { Zeichnet ein Kreuz
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des Kreuzes
    inHoehe: Hoehe des Kreuzes }

  begin

    Setcolor (SCHWARZ);
    SetLineStyle (0, 0, 3);
    line (inX, inY, inX + inBreite, inY + inHoehe);
    line (inX, inY + inHoehe, inX + inBreite, inY);
    SetLineStyle (0, 0, 1)

  end;  { Ankreuzen }





  procedure MaleAbbruchKnopf (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe);

  { Zeichnet einen AbbruchKnopf
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des Knopfes
    inHoehe: Hoehe des Knopfes }

  begin

    MaleGraueBox (inX, inY, inBreite, inHoehe, true);
    Ankreuzen (inX + 4, inY + 4, inBreite - 8, inHoehe - 8)

  end;  { MaleAbbruchKnopf }





  procedure MaleBasisBildschirm (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inText : string);

  { Loescht den Bildschirm und erzeugt ein "Fenster"-artiges
    Rechteck, mit Titelleiste, Ende-Knopf.
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreite: Breite des "Fensters"
    inHoehe: Hoehe des "Fensters"
    inText: Titeltext }

  begin

    ClearDevice;
    MaleGraueBox (inX, inY, inBreite, inHoehe, true);
    Setfillstyle (1, BLAU);
    Bar (inX + 4, inY + 4, inX + inBreite - 4, inY + 18);
    AusgebenFarbigenTextAnPos (inX + 7, inY + 8, WEISS, inText);
    MaleAbbruchKnopf (inX + inBreite - 18, inY + 4, 14, 14);

  end;  { MaleBasisBildschirm }





  procedure AusgebenFarbigenTextInBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe;
              inFarbe : tFarbe;
              inText : string);

  { Ausgabe von Text inText in der Farbe inFarbe in einem rechteckigen
    Bildschirmbereich mit automatischem Umbruch. Der Bereich wird vorher
    geloescht.
    inX: X-Bildschirmkoord. der linken oberen Ecke des Ausgabebereichs
    inY: Y-Bildschirmkoord. der linken oberen Ecke des Ausgabebereichs
    inBreite: Breite des Ausgabebereichs
    inHoehe: Hoehe des Ausgabebereichs
    inFarbe: Textfarbe
    inText: auszugebender Text, max. 255 Zeichen }

    var
    LeerPos : integer;
    Rest : string;
    Y : integer;
    i : integer;
    b : integer;

  begin

    b := inBreite div 8;
    setfillstyle (1, GRAUEBOXFARBE);
    bar (inX, inY, inX + inBreite, inY + inHoehe);
    Y := inY;
    Rest := inText;

    while (Rest <> '') and (Y - inY < inHoehe) do
    begin

      if length (Rest) <= b then
      begin
        AusgebenFarbigenTextAnPos (inX, Y, inFarbe, Rest);
        Rest := '';
      end
      else
      begin

        if Rest[b + 1] = ' ' then
        begin
          AusgebenFarbigenTextAnPos (inX, Y, inFarbe,
                                     Copy (Rest, 1, b));
          Delete (Rest, 1, b + 1);
          Y := Y + 10;
        end
        else
        begin
          i := b;
          LeerPos := 0;
          while (LeerPos = 0) and (i > 0) do
          begin
            if Rest[i] = ' ' then
              LeerPos := i;
            i := i - 1;
          end;

          if LeerPos = 0 then
          begin
            AusgebenFarbigenTextAnPos (inX, Y, inFarbe,
                                       Copy (Rest, 1, b - 2) + '..');
            Delete (Rest, 1, b - 2);
            Rest := '..' + Rest;
            Y := Y + 10;
          end
          else
          begin
            AusgebenFarbigenTextAnPos (inX, Y, inFarbe,
                                       Copy (Rest, 1, LeerPos - 1));
            Delete (Rest, 1, LeerPos);
            Y := Y + 10;
          end;  { if }

        end;  { if }

      end;  { if }

    end;  { while }

    Setcolor (SCHWARZ);

  end;  { AusgebenFarbigenTextInBox }





  procedure MaleAnkreuzOption (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inWert : Boolean;
              inAnzeige : Boolean);

  { Ein Optionsfeld malen/loeschen und ggf. mit Kreuz markieren
    inX: linke obere X-Bildschirmkoord.
    inY: linke obere Y-Bildschirmkoord.
    inWert: True: ankreuzen, False: nicht ankreuzen
    inAnzeige: True: anzeigen, False: loeschen }

  begin

    if inAnzeige then
    begin
      MaleGraueBox (inX, inY, 16, 16, false);
      if inWert then
        Ankreuzen (inX + 4, inY + 4, 8, 8)
    end
    else
      LoescheBox(inX, inY, 16, 16)

  end;  { MaleAnkreuzOption }





  procedure BildRestaurieren ( inX : tBildschXKoord;
                               inY : tBildschYKoord;
                               inImage : Pointer;
                               inSize : word );

  { Teilbildschirm wieder anzeigen und Speicher freigeben
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inImage: Bildspeicher
    inSize: Groesse des Bildspeichers }

  begin

    PutImage( inX, inY, inImage^, 0 );
    FreeMem ( inImage, inSize );

  end;  { BildRestaurieren }





  function JaNeinAbfragePopup (
              inTitel : string;
              inMeldung : string;
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe ) : boolean;

  { Ein Meldungsfenster ("Popup") anzeigen und
    JA/NEIN-Antwort entgegennehmen und zurueckgeben
    inTitel: Titeltext
    inMeldung: Meldungstext
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inBreite: Breite
    inHoehe: Hoehe (muessen jew. gross genug sein!)
    Ergebnis: Ja geklickt=true, Nein=false }

    var
    XKlick : tBildschXKoord;
    YKlick : tBildschYKoord;
    Image : Pointer;
    Size : word;
    KlickJa : boolean;
    KlickNein : boolean;

  begin

    { Bildschirmgebiet retten }
    Size := ImageSize ( inX, inY, inX+inBreite, inY+inHoehe );
    GetMem ( Image, Size );
    GetImage ( inX, inY, inX+inBreite, inY+inHoehe, Image^ );

    { Fenster malen }
    MaleGraueBox (inX, inY, inBreite, inHoehe, true);
    Setfillstyle (1, BLAU);
    Bar (inX + 4, inY + 4, inX + inBreite - 4, inY + 18);
    AusgebenFarbigenTextAnPos (inX + 7, inY + 8, WEISS, inTitel);
    MaleKnopf(inX+(inBreite div 2)-40,inY+inHoehe-28,32,20,'Ja');
    MaleKnopf(inX+(inBreite div 2)+8,inY+inHoehe-28,48,20,'Nein');
    AusgebenFarbigenTextInBox (inX + 8, inY + 26, inBreite-16,
      inHoehe-54, SCHWARZ, inMeldung);
    BewegeMauszeigerNach(inX+(inBreite div 2)-24,inY+inHoehe-18);
    KlickJa := false;
    KlickNein := false;

    { Auf Klick warten und ihn verarbeiten }
    while not (KlickJa or KlickNein) do
    begin
      WarteAufMaus (XKlick,YKlick);
      KlickJa := IstMausKlickInGebiet (inX+(inBreite div 2)-40,
        inY+inHoehe-28,32,20,XKlick,YKlick);
      KlickNein := IstMausKlickInGebiet (inX+(inBreite div 2)+8,
        inY+inHoehe-28,48,20,XKlick,YKlick);
    end;  { while }

    { Funktionsergebnis }
    JaNeinAbfragePopup := KlickJa;

    { Gebiet wieder anzeigen und Speicher freigeben}
    BildRestaurieren ( inX, inY, Image, Size );

  end;  { JaNeinAbfragePopup }




  procedure MeldungsPopupAnzeigen (
                  inTitel : string;
                  inMeldung : string;
                  inKnopftext : string;
                  inX : tBildschXKoord;
                  inY : tBildschYKoord;
                  inBreite : tBildschObjBreite;
                  inHoehe : tBildschObjHoehe;
              var outSize : word;
              var outImage : Pointer );

  { Ein Meldungsfenster ("Popup") nur anzeigen
    inTitel: Titeltext
    inMeldung: Meldungstext
    inKnopftext: Knopftext
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inBreite: Breite
    inHoehe: Hoehe (muessen jew. gross genug sein!)
    outSize: Groesse des Speichers fuer outImage
    outImage: Bildspeicher }

  begin

    { Bildschirmgebiet retten }
    outSize := ImageSize ( inX, inY, inX+inBreite, inY+inHoehe );
    GetMem ( outImage, outSize );
    GetImage ( inX, inY, inX+inBreite, inY+inHoehe, outImage^ );

    { Fenster malen }
    MaleGraueBox (inX, inY, inBreite, inHoehe, true);
    Setfillstyle (1, BLAU);
    Bar (inX + 4, inY + 4, inX + inBreite - 4, inY + 18);
    AusgebenFarbigenTextAnPos (inX + 7, inY + 8, WEISS, inTitel);
    MaleKnopf(inX+(inBreite div 2)-(((length(inKnopftext)+2)*8) div 2),
    inY+inHoehe-28,(length(inKnopftext)+2)*8,20,inKnopftext);
    AusgebenFarbigenTextInBox (inX + 8, inY + 26, inBreite-16,
      inHoehe-54, SCHWARZ, inMeldung);
    BewegeMauszeigerNach(inX+(inBreite div 2),inY+inHoehe-18);

  end;  { MeldungsPopupAnzeigen }





  function CheckMeldungsPopupKlick (
               inKnopftext : string;
               inX : tBildschXKoord;
               inY : tBildschYKoord;
               inBreite : tBildschObjBreite;
               inHoehe : tBildschObjHoehe;
               inXKlick : tBildschXKoord;
               inYKlick : tBildschYKoord) : Boolean;

  { Klickkoordinaten in Bezug auf ein Meldungsfenster ("Popup")
    pruefen
    inKnopftext: Knopftext
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inBreite: Breite
    inHoehe: Hoehe (muessen jew. gross genug sein!)
    inKlickX: X-Koordinate des Mausklicks
    inKlickY: Y-Koordinate des Mausklicks
    Rueckgabe: true: Mausklick im auf Popup; false: nein }

  begin

    CheckMeldungsPopupKlick :=
      IstMausKlickInGebiet (
        inX+(inBreite div 2)-(((length(inKnopftext)+2)*8) div 2),
        inY+inHoehe-28,
        (length(inKnopftext)+2)*8,
        20,inXKlick,inYKlick);

  end;  { CheckMeldungsPopupKlick }





  procedure MeldungsPopup (
              inTitel : string;
              inMeldung : string;
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inBreite : tBildschObjBreite;
              inHoehe : tBildschObjHoehe );

  { Ein Meldungsfenster ("Popup") anzeigen und
    OK-Klick entgegennehmen
    inTitel: Titeltext
    inMeldung: Meldungstext
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inBreite: Breite
    inHoehe: Hoehe (muessen jew. gross genug sein!) }

    var
    XKlick : tBildschXKoord;
    YKlick : tBildschYKoord;
    Image : Pointer;
    Size : word;
    KlickOK : boolean;

  begin

    { Popup anzeigen }
    MeldungsPopupAnzeigen ( inTitel, inMeldung, 'OK', inX, inY,
                            inBreite, inHoehe, Size, Image );

    { Auf Klick warten }
    KlickOK := false;
    while not KlickOK do
    begin
      WarteAufMaus (XKlick,YKlick);
      KlickOK := CheckMeldungsPopupKlick ('OK', inX, inY,
                   inBreite, inHoehe, XKlick,YKlick);
    end;  { while }

    { Gebiet wieder anzeigen und Speicher freigeben}
    BildRestaurieren ( inX, inY, Image, Size );

  end;  { MeldungsPopup }





  procedure AusgebenFarbigenTextInFarbBox (
              inX : tBildschXKoord;
              inY : tBildschYKoord;
              inFarbe : tFarbe;
              inBoxFarbe : tFarbe;
              inText : string);

  { Ausgabe von Text inText (einzeilig) in der Farbe inFarbe in einer
    Box an der Position (inX,inY) mit Hintergrundfarbe inBoxFarbe.
    Die Box hat die feste Hoehe 16 und die Breite (AnzahlZeichen+1)*8.
    inX: X-Position der linken oberen Ecke
    inY: Y-Position der linken oberen Ecke
    inFarbe: Textfarbe
    inBoxFarbe: Hintergrundfarbe
    inText: auszugebender Text }

    var
    Breite : tBildschObjBreite;
    Hoehe : tBildschObjHoehe;

  begin

    Breite := (length (inText) + 1) * 8;
    Hoehe := 16;
    MaleGraueBox ( inX, inY, Breite, Hoehe, false );
    Setfillstyle (1, inBoxFarbe);
    Bar (inX + 2, inY + 2, inX + Breite - 2, inY + Hoehe - 2);
    Setcolor (inFarbe);
    OutTextXY (inX + 4, inY + 4, inText);
    Setcolor (SCHWARZ);

  end;  { AusgebenFarbigenTextInFarbBox }





begin   { Initialisierung der Unit }


  { entfaellt }


end.  { GrafHilf }
