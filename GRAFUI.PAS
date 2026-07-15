unit GrafUI;

{ Die Unit GrafUI kapselt alle Funktionen zur graphischen
  Darstellung des Gomoku-Spiels }

{ Datei in Zei.-Satz IBM850 -> Ñ=84 î=94 Å=81 é=8E ô=99 ö=9A ·=E1,
  Zeilenende DOS/Windows -> 0D+0A }


interface


  procedure StarteGrafikUI;
  { Start und Ablauf der Grafik-Bedienoberflaeche des GOMOKU-Spiels }


implementation


  uses
  Graph,
  Hilfen,
  GrafHilf,
  CompPlay;


  { Konstanten }

  const

  { Farbkonstanten }
  SPIELER1FARBE = WEISS;
  SPIELER2FARBE = SCHWARZ;
  MARKIERFARBE = ROT;

  { Spielertypen }
  SPIELER1 = 1;
  SPIELER2 = 2;

  { verfuegbare Staerken des Computerspielers }
  MAXCSSTAERKE = 2;
  MINCSSTAERKE = 0;

  { Spielbrettgroesse }
  MINBRETTGROESSE = 5;
  MAXBRETTGROESSE = 30;

  { Spielerarten }
  BENUTZERSPIELER = 1;
  COMPUTERSPIELER = 2;




  { Typen }

  type

  tSpieler = SPIELER1..SPIELER2;
             { Spieler }
  tSpielerArt = BENUTZERSPIELER..COMPUTERSPIELER;
                { Spielerart }
  tCSStaerke = MINCSSTAERKE..MAXCSSTAERKE;
               { Staerken des Computerspielers }
  tBildschirmObjektTyp = ( FENSTER, KNOPF,
              TEXT, TEXTBOX, ANKREUZFELD, SPIELFELD,
              BOXTEXT );
              { Typen von Bildschirmobjekten }
  tBildschirmObjekt = ^tBildschirmObjektRecord;
                      { Bildschirmobjekt = Zeiger auf einen
                        Record mit Bildschirmobjekt-Daten, s.u. }
  tBildschirmObjektEreignisProzedur =
              procedure ( Obj : tBildschirmObjekt;
                          X : tBildschXKoord;
                          Y : tBildschYKoord );
              { Ereignisprozedur, die bei Klick aufgerufen wird }

  { Daten zu einem Bildschirmobjekt: }
  tBildschirmObjektRecord = record
                              Naechster : tBildschirmObjekt;
                                { Naechster in der Liste }
                              Vorheriger : tBildschirmObjekt;
                                { Vorgaenger in der Liste }
                              Name : string;
                                { Name des Objekts }
                              ObjektTyp : tBildschirmObjektTyp;
                                { Typ des Objekts }
                              Proz : tBildschirmObjektEreignisProzedur;
                                { Ereignisprozedur }
                              Aktiv : boolean;
                                { verarbeitet Klicks, wenn true }
                              Sichtbar : boolean;
                                { sichtbar, wenn true }
                              X : tBildschXKoord;
                              Y : tBildschYKoord;
                                { Position }
                              Breite : tBildschObjBreite;
                              Hoehe : tBildschObjHoehe;
                                { Dimension }
                              TextWert : string;
                                { Text bzw. Beschriftung }
                              BoolWert : boolean;
                                { logischer Wert bei Ankreuzfeldern }
                              Farbe : tFarbe
                                { Farbe bei Texten }
                            end;




  { Spiel-Variablen }

  var
  AnwendungBeenden : boolean;
                { true, wenn Anwendung beendet werden soll }
  EingabePhase : boolean;
                { true, solange Spiel nicht gestartet }
  ZugNr : integer;
                { Zug-Nummer }
  Spielstatus : tStatus;
                { Spielstatus aus Computerspieler-Unit }
  CSOk : Boolean;
                { letzter Rueckkehrstatus aus CS-Unit-Aufruf }
  Brettbreite : integer;
  Bretthoehe : integer;
                { aktuelle Brettdimensionen }
  BrettX : tBildschXKoord;
  BrettY : tBildschYKoord;
                { linke obere Position der Brettdarstellung }
  Feldgroesse : tBildschObjHoehe;
                { Groesse eines Feldes (quadr.) in Pixeln }
  Brettzeile : integer;
  Brettspalte : integer;
                { Position eines Zuges, z.B. des CS }
  Spielerart : array[tSpieler] of tSpielerArt;
                { Spielerart der beiden Spieler }
  CompSpielStaerke : array[tSpieler] of tCSStaerke;
                { Spielstaerke[..], falls
                  Spielerart[..] = COMPUTERSPIELER }
  GewinnzeileAnfang : integer;
  GewinnspalteAnfang : integer;
  GewinnzeileEnde : integer;
  GewinnspalteEnde : integer;
                { Gewinnreihe (Anfang..Ende), falls Gewinnstatus }
  BildschirmObjekteAnfang : tBildschirmObjekt;
  BildschirmObjekteEnde : tBildschirmObjekt;
                { Zeiger auf die lin.Liste der Bildschirm-Objekte}
  CompSetztAutomatisch : boolean;
                { true: Computerzuege werden automatisch
                  durchgefuehrt }



  { Prozeduren }



  procedure MaleLeeresSpielfeld (
                  inX : tBildschXKoord;
                  inY : tBildschYKoord;
                  inBreiteHoehe : tBildschObjHoehe );

  { Das Spielfeld auf der Bedienoberflaeche positionieren und malen
    inX: X-Bildschirmkoord., links oben
    inY: Y-Bildschirmkoord., links oben
    inBreiteHoehe: max. moegl. Spielbretthoehe
                   (=Breite, da quadratisch) }

    var
    Brettgroesse : integer;
    Gesamthoehe : tBildschObjHoehe;
    Gesamtbreite : tBildschObjBreite;
    Zeile : integer;
    Spalte : integer;

  begin

    { maximale Brettdim. bestimmen }
    Brettgroesse := Brettbreite;
    if Bretthoehe > Brettbreite then
      Brettgroesse := Bretthoehe;

    { Positionierung im vorgegebenen Bildschirmbereich }
    Feldgroesse := (inBreiteHoehe - 10) div Brettgroesse;
    Gesamthoehe := Feldgroesse*Bretthoehe + 11;
    Gesamtbreite := Feldgroesse*Brettbreite + 11;
    BrettX := inX + 5 + (inBreiteHoehe div 2)
                  - (Gesamtbreite div 2);
    BrettY := inY + 5 + (inBreiteHoehe div 2)
                  - (Gesamthoehe div 2);

    { Malen des Spielbretts }
    MaleGraueBox (BrettX - 5, BrettY - 5, Gesamtbreite,
                  Gesamthoehe, true);
    Setcolor (SCHWARZ);
    SetLineStyle (0, 0, 1);
    for Zeile := 0 to Bretthoehe - 1 do
      for Spalte := 0 to Brettbreite - 1 do
        Rectangle (BrettX + Spalte*Feldgroesse,
                   BrettY + Zeile*Feldgroesse,
                   BrettX + (Spalte + 1)*Feldgroesse,
                   BrettY + (Zeile + 1)*Feldgroesse);

  end;  { MaleLeeresSpielfeld }





  procedure MaleLoescheSpielsteinInFeld (
              inBrettZeile : integer;
              inBrettSpalte : integer;
              inSpieler : tSpieler;
              inMarkieren : boolean;
              inMalen : boolean );

  { Einen Spielstein in das Spielbrett malen, ggf. markieren,
    oder loeschen
    inBrettZeile: Zeilenposition des Steins auf dem Brett
    inBrettSpalte: Spaltenposition des Steins auf dem Brett
    inSpieler: Spieler, der den Stein setzt
    inMarkieren: mit einer Markierung (roter Rand) versehen
    inMalen: true: malen, false: loeschen }

    var
    X : tBildschXKoord;
    Y : tBildschYKoord;
    Radius : integer;
    Farbe : tFarbe;

  begin

    Radius := Feldgroesse div 2;
    X := BrettX + (inBrettSpalte - 1)*Feldgroesse + Radius;
    Y := BrettY + (inBrettZeile - 1)*Feldgroesse + Radius;

    if inMalen then
    begin

      { Malen }

      Radius := Radius - 2;
      if inSpieler = SPIELER1 then
        Farbe := SPIELER1FARBE
      else
        Farbe := SPIELER2FARBE;
      Setcolor (Farbe);
      Circle (X, Y, Radius);
      Setfillstyle (1, Farbe);
      FloodFill (X, Y, Farbe);
      if inMarkieren then
      begin

        { zusaetzlich markieren }

        Setcolor (MARKIERFARBE);
        SetLineStyle (0, 0, 3);
        Circle (X, Y, Radius);
        SetLineStyle (0, 0, 1)

      end
    end

    else
    begin

      { Loeschen }

      Setfillstyle (1, GRAU3);
      Bar (BrettX + (inBrettSpalte - 1)*Feldgroesse,
           BrettY + (inBrettZeile - 1)*Feldgroesse,
           BrettX + inBrettSpalte*Feldgroesse,
           BrettY + inBrettZeile*Feldgroesse);
      Setcolor (SCHWARZ);
      SetLineStyle (0, 0, 1);
      Rectangle (BrettX + (inBrettSpalte - 1)*Feldgroesse,
                 BrettY + (inBrettZeile - 1)*Feldgroesse,
                 BrettX + inBrettSpalte*Feldgroesse,
                 BrettY + inBrettZeile*Feldgroesse)
    end

  end;  { MaleLoescheSpielsteinInFeld }





  procedure VersteckeBildschirmObjekt (
            inObj : tBildschirmObjekt );

  { Bildschirmobjekt verstecken
    inObj: Zeiger auf zu bearbeitendes Bildschirmobjekt }

  begin

    if inObj^.Sichtbar then
    begin
      inObj^.Sichtbar := false;
      case inObj^.ObjektTyp of
        FENSTER :
          ClearDevice;
        KNOPF, TEXTBOX, SPIELFELD, BOXTEXT :
          LoescheBox ( inObj^.X, inObj^.Y, inObj^.Breite, inObj^.Hoehe );
        TEXT :
          AusgebenFarbigenTextAnPos (
            inObj^.X, inObj^.Y, GRAU3, inObj^.TextWert );
        ANKREUZFELD :
          MaleAnkreuzOption ( inObj^.X, inObj^.Y, inObj^.BoolWert, false );
      end  { case }
    end

  end;  { VersteckeBildschirmObjekt }





  procedure MaleBildschirmObjekt (
            inObj : tBildschirmObjekt );

  { Bildschirmobjekt neu malen
    inObj: Zeiger auf zu bearbeitendes Bildschirmobjekt }

  begin

    inObj^.Sichtbar := true;
    case inObj^.ObjektTyp of
      FENSTER :
        MaleBasisBildschirm (
          inObj^.X, inObj^.Y, inObj^.Breite, inObj^.Hoehe,
          inObj^.TextWert );
      KNOPF :
        MaleKnopf (
          inObj^.X, inObj^.Y, inObj^.Breite, inObj^.Hoehe,
          inObj^.TextWert );
      TEXT :
        AusgebenFarbigenTextAnPos (
          inObj^.X, inObj^.Y, inObj^.Farbe, inObj^.TextWert );
      TEXTBOX :
        AusgebenFarbigenTextInBox (
          inObj^.X, inObj^.Y, inObj^.Breite, inObj^.Hoehe, inObj^.Farbe,
          inObj^.TextWert );
      ANKREUZFELD :
        MaleAnkreuzOption ( inObj^.X, inObj^.Y, inObj^.BoolWert, true );
      SPIELFELD :
        MaleLeeresSpielfeld ( inObj^.X, inObj^.Y, inObj^.Breite );
      BOXTEXT :
        AusgebenFarbigenTextInFarbBox (
          inObj^.X, inObj^.Y, inObj^.Farbe, SCHWARZ, inObj^.TextWert );
    end  { case }

  end;  { MaleBildschirmObjekt }





  procedure MaleOderVersteckeBildschirmObjekt (
            inObj : tBildschirmObjekt;
            inAnzeigen : boolean );

  { Bildschirmobjekt entsprechend Schalter neu malen oder verstecken
    inObj: Zeiger auf zu bearbeitendes Bildschirmobjekt
    inAnzeigen: true: neuzeichnen, false: loeschen }

  begin

    if inAnzeigen then
      MaleBildschirmObjekt( inObj )
    else
      VersteckeBildschirmObjekt( inObj )

  end;  { MaleOderVersteckeBildschirmObjekt }





  function HoleObjRef (
            inName : string ) : tBildschirmObjekt;

  { Ermittlung des Zeigers auf ein Bildschirmobjekt aus dem Namen
    inName. nil wird zurueckgegeben, wenn nicht gefunden
    ( was jedoch bei korrekter Programmierung nicht
    passieren sollte )
    inName: Name des zu holenden Bildschirmobjekt-Zeigers
    Ergebnis: Zeiger auf Bildschirmobjekt mit Namen inName
              nil wenn nicht gefunden }

    var
    Gefunden : Boolean;
    Zeiger : tBildschirmObjekt;

  begin

    Gefunden := false;
    Zeiger := BildschirmObjekteAnfang;
    HoleObjRef := nil;
    while (not Gefunden) and (Zeiger <> nil) do
    begin
      if Zeiger^.Name = inName then
      begin
        Gefunden := true;
        HoleObjRef := Zeiger
      end;
      Zeiger := Zeiger^.Naechster;
    end;

  end;  { HoleObjRef }





  procedure DarstellungBildschirmObjekte;

  { Bildschirm komplett neu zeichnen (alle sichtbaren Objekte) }

    var
    Obj : tBildschirmObjekt;

  begin

    Obj := BildschirmObjekteAnfang;
    while (Obj <> nil) do
    begin
      if Obj^.Sichtbar then
        MaleBildschirmObjekt(Obj);
      Obj := Obj^.Naechster;
    end  { while }

  end;  { DarstellungBildschirmObjekte }





  procedure PruefeCSOkStatus( inText : string );

  { Ueberpruefung des Rueckkehrstatus aus den
    Computerspieler-Routinen, PopupFenster mit Meldung anzeigen
    (sollte im Normalfall nicht passieren ;-)
    falls False, dann ggf. Programm beenden
    inText: Anzuzeigender Text in der Fehlermeldung }

  begin

    if not CSOk then
      AnwendungBeenden := JaNeinAbfragePopup('Fataler Fehler!',
         'OK=false in ' + inText + '. Wollen Sie das Programm abbrechen?',
         220,190,200,100)

  end;  { PruefeCSOkStatus }




  function SpielerAmZug : tSpieler;

  { Bestimmung des Spielers, der am Zug ist. Vorbedingung:
    Das Spiel ist nicht zu Ende (Gewinn,Unentschieden).
    Ergebnis: SPIELER1 oder SPIELER2, entspr. Spielstatus }

  begin

    if Spielstatus = EINS_AM_ZUG then
      SpielerAmZug := SPIELER1
    else
      SpielerAmZug := SPIELER2

  end;  { SpielerAmZug }





  function GewinnSpieler : tSpieler;

  { Bestimmung des gewinnenden Spielers. Vorbedingung:
    Es gibt einen Gewinner.
    Ergebnis: SPIELER1 oder SPIELER2, entspr. Spielstatus }

  begin

    if Spielstatus = EINS_GEWINNT then
      GewinnSpieler := SPIELER1
    else
      GewinnSpieler := SPIELER2

  end;  { GewinnSpieler }





  function SpielerNichtAmZug : tSpieler;

  { Bestimmung des Spielers, der nicht am Zug ist. Vorbedingung:
    Das Spiel ist nicht zu Ende (Gewinn,Unentschieden).
    Ergebnis: SPIELER1 oder SPIELER2, entspr. Spielstatus }

  begin

    if Spielstatus = EINS_AM_ZUG then
      SpielerNichtAmZug := SPIELER2
    else
      SpielerNichtAmZug := SPIELER1

  end;  { SpielerNichtAmZug }





  function SpielLaeuft : boolean;

  { Bestimmung, ob das Spiel noch laeuft
    Ergebnis: true wenn ja, sonst false }

  begin

    SpielLaeuft := (Spielstatus = EINS_AM_ZUG) or
                   (Spielstatus = ZWEI_AM_ZUG)

  end;  { SpielLaeuft }





  procedure BrettgroessenAenderung;

  { Aktionen nach Brettgroessen-Aenderung durchfuehren
    Pruefungen, Spielbrett neu darstellen, Knoepfe und Groesse
    korrekt anzeigen }

    var
    Obj : tBildschirmObjekt;

  begin

    setzeFeldgroesse(BrettBreite,BrettHoehe,CSOk);
    PruefeCSOkStatus('setzeFeldgroesse');
    gibFeldgroesse(Brettbreite,Bretthoehe);
    Obj := HoleObjRef('Brett');
    VersteckeBildschirmObjekt(Obj);
    MaleBildschirmObjekt(Obj);
    Obj := HoleObjRef('Brettgroesse');
    VersteckeBildschirmObjekt(Obj);
    Obj^.TextWert := IntegerNachStringMitNullen(BrettHoehe,2) +
       'x' +
        IntegerNachStringMitNullen(BrettBreite,2);
    MaleBildschirmObjekt(Obj);
    Obj := HoleObjRef('BreiteKleiner');
    MaleOderVersteckeBildschirmObjekt(Obj,
      (Brettbreite > MINBRETTGROESSE));
    Obj := HoleObjRef('BreiteGroesser');
    MaleOderVersteckeBildschirmObjekt(Obj,
      (Brettbreite < MAXBRETTGROESSE));
    Obj := HoleObjRef('HoeheKleiner');
    MaleOderVersteckeBildschirmObjekt(Obj,
      (Bretthoehe > MINBRETTGROESSE));
    Obj := HoleObjRef('HoeheGroesser');
    MaleOderVersteckeBildschirmObjekt(Obj,
      (Bretthoehe < MAXBRETTGROESSE));

  end;  { BrettgroessenAenderung }





  procedure AktualisiereBildschirmObjekteNachZug
                        (inGewinnmarkierung : boolean);

  { Alle Bildschirmobjekte nach einem Zug korrekt darstellen:
    Texte, Knoepfe, Gewinndarstellung, usw.
    inGewinnmarkierung: true: Gewinnmarkierung darstellen
                        false: .. nicht darstellen bei Gewinn }

    var
    Obj : tBildschirmObjekt;
    Stein : integer;

  begin

    { Zugnummer }

    Obj := HoleObjRef('ZugNr');
    Obj^.TextWert := 'Z#' +
      IntegerNachStringMitNullen(ZugNr,3);
    MaleBildschirmObjekt(Obj);

    { Statustext }

    Obj := HoleObjRef('SpielHinweis');
    case Spielstatus of
                         {12345123451234512345}
      EINS_AM_ZUG :
        Obj^.TextWert := 'WEI· AM ZUG         ';
      ZWEI_AM_ZUG :
        Obj^.TextWert := '      SCHWARZ AM ZUG';
      EINS_GEWINNT :
        Obj^.TextWert := 'WEI· GEWINNT <<<<<<<';
      ZWEI_GEWINNT :
        Obj^.TextWert := '>>>> SCHWARZ GEWINNT';
      UNENTSCHIEDEN :
        Obj^.TextWert := '>>> UNENTSCHIEDEN <<';
      UNDEFINIERT :
        Obj^.TextWert := '         ??         ';
    end;  { case }
    MaleBildschirmObjekt(Obj);

    { Auto-Ziehen im Control aktualisieren }

    Obj := HoleObjRef('CompAutoZug');
    Obj^.BoolWert := CompSetztAutomatisch;

    { Knoepfe aus/einblenden etc }

    VersteckeBildschirmObjekt(HoleObjRef('CompZug'));
    VersteckeBildschirmObjekt(HoleObjRef('CompAutoZug'));
    VersteckeBildschirmObjekt(HoleObjRef('TextCompAutoZug'));
    VersteckeBildschirmObjekt(HoleObjRef('Seitenwechsel'));
    VersteckeBildschirmObjekt(HoleObjRef('Tipp'));

    if SpielLaeuft then
      if Spielerart[SpielerAmZug] = COMPUTERSPIELER then
      begin
        MaleBildschirmObjekt(HoleObjRef('CompZug'));
        MaleBildschirmObjekt(HoleObjRef('CompAutoZug'));
        MaleBildschirmObjekt(HoleObjRef('TextCompAutoZug'))
      end
      else
        MaleBildschirmObjekt(HoleObjRef('Tipp'));

    Obj := HoleObjRef('Seitenwechsel');
    if SpielLaeuft then
      if (Spielerart[SpielerAmZug] = BENUTZERSPIELER) and
         (Spielerart[SpielerNichtAmZug] = COMPUTERSPIELER) then
        MaleBildschirmObjekt(Obj);

    VersteckeBildschirmObjekt(HoleObjRef('SpielAbbruch'));
    VersteckeBildschirmObjekt(HoleObjRef('SpielNeu'));
    if SpielLaeuft then
      MaleBildschirmObjekt(HoleObjRef('SpielAbbruch'))
    else
      MaleBildschirmObjekt(HoleObjRef('SpielNeu'));

    { Gewinnmarkierung }

    case Spielstatus of
      EINS_GEWINNT, ZWEI_GEWINNT :
      begin
        gibGewinnreihe(GewinnspalteAnfang,GewinnzeileAnfang,
                       GewinnspalteEnde,GewinnzeileEnde,CSOk);
        PruefeCSOkStatus('gibGewinnreihe');
        Brettzeile := GewinnzeileAnfang;
        Brettspalte := GewinnspalteAnfang;
        for Stein := 1 to 5 do
        begin
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
            Gewinnspieler,false,false);
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
            Gewinnspieler,inGewinnmarkierung,true);
          if GewinnzeileAnfang < GewinnzeileEnde then
            Brettzeile := Brettzeile + 1;
          if GewinnzeileAnfang > GewinnzeileEnde then
            Brettzeile := Brettzeile - 1;
          if GewinnspalteAnfang < GewinnspalteEnde then
            Brettspalte := Brettspalte + 1;
          if GewinnspalteAnfang > GewinnspalteEnde then
            Brettspalte := Brettspalte - 1
        end
      end;
    end;  { case }

    { Blaettern-Knoepfe }

    zugZurueck(BrettSpalte,BrettZeile,CSOk);
    MaleOderVersteckeBildschirmObjekt(HoleObjRef('ZugAnfang'),CSOk);
    MaleOderVersteckeBildschirmObjekt(HoleObjRef('ZugZurueck'),CSOk);
    if CSOk then
      zugVor(BrettSpalte,BrettZeile,CSOk);

    zugVor(BrettSpalte,BrettZeile,CSOk);
    MaleOderVersteckeBildschirmObjekt(HoleObjRef('ZugEnde'),CSOk);
    MaleOderVersteckeBildschirmObjekt(HoleObjRef('ZugVor'),CSOk);
    if CSOk then
      zugZurueck(BrettSpalte,BrettZeile,CSOk);

  end;  { AktualisiereBildschirmObjekteNachZug }





  procedure SpielerAuswahl ( inSpieler : tSpieler;
                             inObj : tBildschirmObjekt );

  { Aktionen nach Spielerauswahl durchfuehren
    (Radiobutton-Funktion, Auswahl in Variablen speichern)
    inSpieler: Spielercode
    inObj: angeklicktes Bildschirmobjekt }

    var
    Obj : tBildschirmObjekt;
    Code : string;

  begin

    if inSpieler = SPIELER1 then
      Code := '1'
    else
      Code := '2';
    Obj := HoleObjRef('Sp' + Code + 'Ben');
    if Obj = inObj then
      Spielerart[inSpieler] := BENUTZERSPIELER;
    Obj := HoleObjRef('Sp' + Code + 'CS0');
    if Obj = inObj then
    begin
      Spielerart[inSpieler] := COMPUTERSPIELER;
      CompSpielStaerke[inSpieler] := 0;
    end;
    Obj := HoleObjRef('Sp' + Code + 'CS1');
    if Obj = inObj then
    begin
      Spielerart[inSpieler] := COMPUTERSPIELER;
      CompSpielStaerke[inSpieler] := 1;
    end;
    Obj := HoleObjRef('Sp' + Code + 'CS2');
    if Obj = inObj then
    begin
      Spielerart[inSpieler] := COMPUTERSPIELER;
      CompSpielStaerke[inSpieler] := 2;
    end;
    Obj := HoleObjRef('Sp' + Code + 'Ben');
    Obj^.BoolWert := (Spielerart[inSpieler]=BENUTZERSPIELER);
    MaleBildschirmObjekt ( Obj );
    Obj := HoleObjRef('Sp' + Code + 'CS0');
    Obj^.BoolWert := (CompSpielStaerke[inSpieler]=0) and
        (Spielerart[inSpieler]=COMPUTERSPIELER);
    MaleBildschirmObjekt ( Obj );
    Obj := HoleObjRef('Sp' + Code + 'CS1');
    Obj^.BoolWert := (CompSpielStaerke[inSpieler]=1) and
        (Spielerart[inSpieler]=COMPUTERSPIELER);
    MaleBildschirmObjekt ( Obj );
    Obj := HoleObjRef('Sp' + Code + 'CS2');
    Obj^.BoolWert := (CompSpielStaerke[inSpieler]=2) and
        (Spielerart[inSpieler]=COMPUTERSPIELER);
    MaleBildschirmObjekt ( Obj );

    if (not EingabePhase) and SpielLaeuft then
      AktualisiereBildschirmObjekteNachZug (true)

  end;  { SpielerAuswahl }





  {$F+}

  { ---  Ereignis-Prozeduren ---

    HINWEIS:

    Alle Ereignisprozeduren haben folgende Parameter:
    inObj: angeklicktes Bildschirmobjekt
    inX, inY: Klickkoordinaten rel. zur linken oberen Ecke }





  procedure EreignisTueNichts ( inObj : tBildschirmObjekt;
                                inX : tBildschXKoord;
                                inY : tBildschYKoord );

  { EREIGNIS:
    tut nichts (Platzhalter fuer passive Elemente) }

  begin

  end;  { EreignisTueNichts }





  procedure EreignisCompZug ( inObj : tBildschirmObjekt;
                              inX : tBildschXKoord;
                              inY : tBildschYKoord );

  { EREIGNIS:
    Computerzug durchfuehren }

    var
    Fertig : boolean;
    Image : Pointer;
    Size : word;
    PopupAngezeigt : boolean;
    XKlick : tBildschXKoord;
    YKlick : tBildschYKoord;

  begin

    PopupAngezeigt := false;
    if SpielLaeuft then
      if Spielerart[SpielerAmZug] = COMPUTERSPIELER then
      begin
        if (Spielerart[SpielerNichtAmZug] = COMPUTERSPIELER) and
           CompSetztAutomatisch then
        begin
          MeldungsPopupAnzeigen ( 'Stoppen?',
           'Computerspieler- Zugfolge ..','.. stoppen!',
           460,295,170,85,Size,Image);
          PopupAngezeigt := true
        end;
        Fertig := false;
        while not Fertig do
        begin
          setzeSpielstufe(CompSpielStaerke[SpielerAmZug],CSOk);
          PruefeCSOkStatus('setzeSpielstufe');
          computerZug(BrettSpalte,BrettZeile,CSOk);
          PruefeCSOkStatus('computerZug');
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
            SpielerAmZug,false,true);
          ZugNr := ZugNr + 1;
          gibStatus (Spielstatus);
          AktualisiereBildschirmObjekteNachZug(true);
          Fertig := true;
          if SpielLaeuft then
            if (Spielerart[SpielerAmZug] = COMPUTERSPIELER) and
               CompSetztAutomatisch then
            begin
              ZeigeMauszeiger;
              Warten(100);
              VersteckeMauszeiger;
              if IstLinkeMaustasteLosgelassen ( XKlick, YKlick ) then
                Fertig := CheckMeldungsPopupKlick ('.. stoppen!',
                            460,295,170,85, XKlick,YKlick)
              else
                Fertig := false
            end
        end;
        if PopupAngezeigt then
          BildRestaurieren ( 460,295,Image,Size );
      end
      else
        MeldungsPopup('Nicht erlaubt!',
          'CS ist nicht am Zug!',170,160,150,80)
    else
      MeldungsPopup('Nicht erlaubt!',
      'Das Spiel lÑuft noch nicht oder ist beendet!',170,160,150,100)

  end;  { EreignisCompZug }





  procedure EreignisCompAutoZug ( inObj : tBildschirmObjekt;
                                  inX : tBildschXKoord;
                                  inY : tBildschYKoord );

  { EREIGNIS:
    Schalter aendern zur automatischen Durchfuehrung von
    Computerspielzuegen }

  begin

    CompSetztAutomatisch := inObj^.BoolWert

  end;  { EreignisCompAutoZug }





  procedure EreignisTipp ( inObj : tBildschirmObjekt;
                           inX : tBildschXKoord;
                           inY : tBildschYKoord );

  { EREIGNIS:
    Tipp anfordern }

    var
    TippSpalte : integer;
    TippZeile : integer;

  begin

    if SpielLaeuft then
      if Spielerart[SpielerAmZug] = BENUTZERSPIELER then
      begin
        setzeSpielstufe(2,CSOk);
        PruefeCSOkStatus('setzeSpielstufe');

        { Tipp erzeugen und speichern }
        computerZug(BrettSpalte,BrettZeile,CSOk);
        PruefeCSOkStatus('computerZug');
        TippSpalte := BrettSpalte;
        TippZeile := BrettZeile;

        { Tipp entfernen }
        zugZurueck(BrettSpalte,BrettZeile,CSOk);
        PruefeCSOkStatus('zugZurueck');

        { Zug vor Tipp zuruecknehmen }
        zugZurueck(BrettSpalte,BrettZeile,CSOk);

        if CSOk then  { Zug vor Tipp vorhanden, Neu setzen loescht Tipp }
        begin
          setzeStein(BrettSpalte,BrettZeile,CSOk);
          PruefeCSOkStatus('setzeStein nach Tipp');
        end
        else { kein Zug vor Tipp vorhanden, Neues Spiel loescht Tipp }
        begin
          neuesSpiel(CSOk);
          PruefeCSOkStatus('neuesSpiel nach Tipp');
        end;

        { Zugliste wieder korrekt, kein vorwaertsbl. moegl. }
        BrettSpalte := TippSpalte;
        BrettZeile := TippZeile;
        MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
          SpielerAmZug,true,true);
        if JaNeinAbfragePopup('Tipp annehmen?',
          'Wollen Sie den Tipp des Computers setzen?',460,295,170,90) then
        begin

          { Tipp akzeptiert, Tipp korrekt zeichnen und setzen }
          setzeStein(BrettSpalte,BrettZeile,CSOk);
          PruefeCSOkStatus('setzeStein');
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
            SpielerAmZug,true,false);
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
          SpielerAmZug,false,true);
          ZugNr := ZugNr + 1;
          gibStatus (Spielstatus);
          AktualisiereBildschirmObjekteNachZug(true);
          if SpielLaeuft then
            if (Spielerart[SpielerAmZug] = COMPUTERSPIELER) and
               CompSetztAutomatisch then
              EreignisCompZug(inObj,inX,inY)
        end
        else
        begin

          { Tipp abgelehnt, Tipp loeschen, Knoepfe akt. }
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
            SpielerAmZug,true,false);
          AktualisiereBildschirmObjekteNachZug(false);

        end
      end
      else
        MeldungsPopup('Nicht erlaubt!',
          'Benutzer ist nicht am Zug!',170,160,150,80)
    else
      MeldungsPopup('Nicht erlaubt!',
      'Das Spiel lÑuft noch nicht oder ist beendet!',170,160,150,100)

  end;  { EreignisTipp }





  procedure EreignisSeitenwechsel ( inObj : tBildschirmObjekt;
                                    inX : tBildschXKoord;
                                    inY : tBildschYKoord );

  { EREIGNIS:
    Seitenwechsel }

    var
    Temp1 : tSpielerArt;
    Temp2 : tCSStaerke;
    Code : string;
    Spieler : tSpieler;
    Obj : tBildschirmObjekt;

  begin

    Temp1 := Spielerart[SPIELER1];
    Spielerart[SPIELER1] := Spielerart[SPIELER2];
    Spielerart[SPIELER2] := Temp1;

    Temp2 := CompSpielStaerke[SPIELER1];
    CompSpielStaerke[SPIELER1] := CompSpielStaerke[SPIELER2];
    CompSpielStaerke[SPIELER2] := Temp2;

    for Spieler := SPIELER1 to SPIELER2 do
    begin
      if Spieler = SPIELER1 then
        Code := '1'
      else
        Code := '2';
      Obj := HoleObjRef('Sp' + Code + 'Ben');
      Obj^.BoolWert := (Spielerart[Spieler]=BENUTZERSPIELER);
      MaleBildschirmObjekt ( Obj );
      Obj := HoleObjRef('Sp' + Code + 'CS0');
      Obj^.BoolWert := (CompSpielStaerke[Spieler]=0) and
          (Spielerart[Spieler]=COMPUTERSPIELER);
      MaleBildschirmObjekt ( Obj );
      Obj := HoleObjRef('Sp' + Code + 'CS1');
      Obj^.BoolWert := (CompSpielStaerke[Spieler]=1) and
          (Spielerart[Spieler]=COMPUTERSPIELER);
      MaleBildschirmObjekt ( Obj );
      Obj := HoleObjRef('Sp' + Code + 'CS2');
      Obj^.BoolWert := (CompSpielStaerke[Spieler]=2) and
          (Spielerart[Spieler]=COMPUTERSPIELER);
      MaleBildschirmObjekt ( Obj );
    end;

    if SpielLaeuft then
      AktualisiereBildschirmObjekteNachZug(true)

  end;  { EreignisSeitenwechsel }





  procedure EreignisSpielNeu ( inObj : tBildschirmObjekt;
                               inX : tBildschXKoord;
                               inY : tBildschYKoord );

  { EREIGNIS:
    Neues Spiel beginnen }

  begin

    VersteckeBildschirmObjekt(HoleObjRef('TextBlaettern'));
    VersteckeBildschirmObjekt(HoleObjRef('ZugAnfang'));
    VersteckeBildschirmObjekt(HoleObjRef('ZugZurueck'));
    VersteckeBildschirmObjekt(HoleObjRef('ZugNr'));
    VersteckeBildschirmObjekt(HoleObjRef('ZugVor'));
    VersteckeBildschirmObjekt(HoleObjRef('ZugEnde'));
    VersteckeBildschirmObjekt(HoleObjRef('SpielHinweis'));
    VersteckeBildschirmObjekt(HoleObjRef('CompZug'));
    VersteckeBildschirmObjekt(HoleObjRef('Tipp'));
    VersteckeBildschirmObjekt(HoleObjRef('CompAutoZug'));
    VersteckeBildschirmObjekt(HoleObjRef('TextCompAutoZug'));
    VersteckeBildschirmObjekt(HoleObjRef('Seitenwechsel'));
    VersteckeBildschirmObjekt(HoleObjRef('TextErklaerung2'));
    VersteckeBildschirmObjekt(HoleObjRef('SpielAbbruch'));
    VersteckeBildschirmObjekt(HoleObjRef('SpielNeu'));

    EingabePhase := true;

    MaleBildschirmObjekt(HoleObjRef('TextBrettgroesse'));
    MaleBildschirmObjekt(HoleObjRef('BreiteKleiner'));
    MaleBildschirmObjekt(HoleObjRef('BreiteGroesser'));
    MaleBildschirmObjekt(HoleObjRef('Brettgroesse'));
    MaleBildschirmObjekt(HoleObjRef('HoeheKleiner'));
    MaleBildschirmObjekt(HoleObjRef('HoeheGroesser'));

    BrettgroessenAenderung;

    MaleBildschirmObjekt(HoleObjRef('SpielStart'));
    MaleBildschirmObjekt(HoleObjRef('TextErklaerung'));
    MaleBildschirmObjekt(HoleObjRef('TextImpressum'));

  end;  { EreignisSpielNeu }





  procedure EreignisBeenden ( inObj : tBildschirmObjekt;
                              inX : tBildschXKoord;
                              inY : tBildschYKoord );

  { EREIGNIS:
    Verlassen/Beenden des Programms }

  begin

    AnwendungBeenden := JaNeinAbfragePopup('Bitte bestÑtigen ...',
       'Wollen Sie das Programm verlassen?',430,20,200,85)

  end;  { EreignisBeenden }





  procedure EreignisSpielStart ( inObj : tBildschirmObjekt;
                                 inX : tBildschXKoord;
                                 inY : tBildschYKoord );

  { EREIGNIS:
    Spiel starten }

    var
    Obj : tBildschirmObjekt;

  begin

    VersteckeBildschirmObjekt(HoleObjRef('TextBrettgroesse'));
    VersteckeBildschirmObjekt(HoleObjRef('BreiteKleiner'));
    VersteckeBildschirmObjekt(HoleObjRef('BreiteGroesser'));
    VersteckeBildschirmObjekt(HoleObjRef('Brettgroesse'));
    VersteckeBildschirmObjekt(HoleObjRef('HoeheKleiner'));
    VersteckeBildschirmObjekt(HoleObjRef('HoeheGroesser'));
    VersteckeBildschirmObjekt(HoleObjRef('SpielStart'));
    VersteckeBildschirmObjekt(HoleObjRef('TextErklaerung'));
    VersteckeBildschirmObjekt(HoleObjRef('TextImpressum'));

    MaleBildschirmObjekt(HoleObjRef('TextBlaettern'));
    MaleBildschirmObjekt(HoleObjRef('TextErklaerung2'));
    ZugNr := 0;
    EingabePhase := false;
    neuesSpiel(CSOk);
    PruefeCSOkStatus('neuesSpiel');
    gibStatus (Spielstatus);
    AktualisiereBildschirmObjekteNachZug(true)

  end;  { EreignisSpielStart }





  procedure EreignisSpielbrett ( inObj : tBildschirmObjekt;
                                 inX : tBildschXKoord;
                                 inY : tBildschYKoord );

  { EREIGNIS:
    Klick ins Spielbrett: Benutzerzug }

  begin

    if SpielLaeuft then
      if Spielerart[SpielerAmZug] = BENUTZERSPIELER then
      begin
        BrettZeile := (inY div Feldgroesse) + 1;
        BrettSpalte := (inX div Feldgroesse) + 1;
        setzeStein(BrettSpalte,BrettZeile,CSOk);
        if CSOk then
        begin
          MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
          SpielerAmZug,false,true);
          ZugNr := ZugNr + 1;
          gibStatus (Spielstatus);
          AktualisiereBildschirmObjekteNachZug(true);
          if SpielLaeuft then
            if (Spielerart[SpielerAmZug] = COMPUTERSPIELER) and
               CompSetztAutomatisch then
              EreignisCompZug(inObj,inX,inY)
        end
        else
          MeldungsPopup('Nicht erlaubt!',
           'Hier dÅrfen Sie nicht setzen!',170,160,150,80)
      end
      else
        MeldungsPopup('Nicht erlaubt!',
         'Sie sind nicht am Zug!',170,160,150,80)
    else
      MeldungsPopup('Nicht erlaubt!',
     'Das Spiel lÑuft noch nicht oder ist beendet!',170,160,150,100)

  end;  { EreignisSpielbrett }





  procedure EreignisBreiteKleiner ( inObj : tBildschirmObjekt;
                                    inX : tBildschXKoord;
                                    inY : tBildschYKoord );

  { EREIGNIS:
    Spielbrettbreite verringern }

  begin

    Brettbreite := BrettBreite - 1;
    BrettgroessenAenderung

  end;  { EreignisBreiteKleiner }





  procedure EreignisBreiteGroesser ( inObj : tBildschirmObjekt;
                                     inX : tBildschXKoord;
                                     inY : tBildschYKoord );

  { EREIGNIS:
    Spielbrettbreite vergroessern }

  begin

    Brettbreite := BrettBreite + 1;
    BrettgroessenAenderung

  end;  { EreignisBreiteGroesser }





  procedure EreignisHoeheKleiner ( inObj : tBildschirmObjekt;
                                   inX : tBildschXKoord;
                                   inY : tBildschYKoord );

  { EREIGNIS:
    Spielbretthoehe verringern }

  begin

    BrettHoehe := BrettHoehe - 1;
    BrettgroessenAenderung

  end;  { EreignisHoeheKleiner }





  procedure EreignisHoeheGroesser ( inObj : tBildschirmObjekt;
                                    inX : tBildschXKoord;
                                    inY : tBildschYKoord );

  { EREIGNIS:
    Spielbretthoehe vergroessern }

  begin

    BrettHoehe := BrettHoehe + 1;
    BrettgroessenAenderung

  end;  { EreignisHoeheGroesser }





  procedure EreignisAuswahlSpieler1 ( inObj : tBildschirmObjekt;
                                      inX : tBildschXKoord;
                                      inY : tBildschYKoord );

  { EREIGNIS:
    Modus des 1. Spielers auswaehlen: Benutzer oder Computer der
    Spielstaerke 0, 1 oder 2 }

  begin

    SpielerAuswahl(SPIELER1,inObj)

  end;  { EreignisAuswahlSpieler1 }





  procedure EreignisAuswahlSpieler2 ( inObj : tBildschirmObjekt;
                                      inX : tBildschXKoord;
                                      inY : tBildschYKoord );

  { EREIGNIS:
    Modus des 2. Spielers auswaehlen: Benutzer oder Computer der
    Spielstaerke 0, 1 oder 2 }

  begin

    SpielerAuswahl(SPIELER2,inObj)

  end;  { EreignisAuswahlSpieler2 }





  procedure EreignisZugAnfang ( inObj : tBildschirmObjekt;
                                inX : tBildschXKoord;
                                inY : tBildschYKoord );

  { EREIGNIS:
    An den Anfang der Zugliste blaettern }

  begin

    AktualisiereBildschirmObjekteNachZug(false);
    zugZurueck(BrettSpalte,BrettZeile,CSOk);
    while CSOk do
    begin
      MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
        SpielerAmZug,false,false);
      ZugNr := ZugNr - 1;
      gibStatus (Spielstatus);
      AktualisiereBildschirmObjekteNachZug(true);
      zugZurueck(BrettSpalte,BrettZeile,CSOk)
    end

  end;  { EreignisZugAnfang }





  procedure EreignisZugZurueck ( inObj : tBildschirmObjekt;
                                 inX : tBildschXKoord;
                                 inY : tBildschYKoord );

  { EREIGNIS:
    In der Zugliste zurueckblaettern }

  begin

    AktualisiereBildschirmObjekteNachZug(false);
    zugZurueck(BrettSpalte,BrettZeile,CSOk);
    PruefeCSOkStatus('zugZurueck');
    MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
      SpielerAmZug,false,false);
    ZugNr := ZugNr - 1;
    gibStatus (Spielstatus);
    AktualisiereBildschirmObjekteNachZug(true);

  end;  { EreignisZugZurueck }





  procedure EreignisZugVor ( inObj : tBildschirmObjekt;
                             inX : tBildschXKoord;
                             inY : tBildschYKoord );

  { EREIGNIS:
    In der Zugliste vorwaertsblaettern }

  begin

    zugVor(BrettSpalte,BrettZeile,CSOk);
    PruefeCSOkStatus('zugVor');
    MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
      SpielerAmZug,false,true);
    ZugNr := ZugNr + 1;
    gibStatus (Spielstatus);
    AktualisiereBildschirmObjekteNachZug(true);

  end;  { EreignisZugVor }





  procedure EreignisZugEnde ( inObj : tBildschirmObjekt;
                              inX : tBildschXKoord;
                              inY : tBildschYKoord );

  { EREIGNIS:
    An das Ende der Zugliste blaettern }

  begin

    zugVor(BrettSpalte,BrettZeile,CSOk);
    while CSOk do
    begin
      MaleLoescheSpielsteinInFeld(BrettZeile,BrettSpalte,
        SpielerAmZug,false,true);
      ZugNr := ZugNr + 1;
      gibStatus (Spielstatus);
      AktualisiereBildschirmObjekteNachZug(true);
      zugVor(BrettSpalte,BrettZeile,CSOk)
    end

  end;  { EreignisZugEnde }





  procedure EreignisSpielAbbruch ( inObj : tBildschirmObjekt;
                                   inX : tBildschXKoord;
                                   inY : tBildschYKoord );

  { EREIGNIS:
    Spiel abbrechen }

    var
    Abbruch : boolean;

  begin

    if JaNeinAbfragePopup('Bitte bestÑtigen ...',
      'Wollen Sie das Spiel wirklich abbrechen?',430,350,200,85) then
      EreignisSpielNeu(inObj,inX,inY)

  end;  { EreignisSpielAbbruch }





  { ---  Ende der Ereignis-Prozeduren --- }
  {$F-}





  procedure ErzeugeBildschirmObjekt (
            inName : string;
            inObjektTyp : tBildschirmObjektTyp;
            inProz : tBildschirmObjektEreignisProzedur;
            inAktiv : boolean;
            inSichtbar : boolean;
            inX : tBildschXKoord;
            inY : tBildschYKoord;
            inBreite : tBildschObjBreite;
            inHoehe : tBildschObjHoehe;
            inTextWert : string;
            inBoolWert : boolean;
            inFarbe : tFarbe );

  { Erzeugung und Initialisierung eines Bildschirmobjekts;
    Parameter siehe Beschreibung der Datenstruktur fuer
    Bildschirmobjekte }

    var
    Neu : tBildschirmObjekt;

  begin

    new ( Neu );

    Neu^.Naechster := nil;
    Neu^.Name := inName;
    Neu^.ObjektTyp := inObjektTyp;
    Neu^.Proz := inProz;
    Neu^.Aktiv := inAktiv;
    Neu^.Sichtbar := inSichtbar;
    Neu^.X := inX;
    Neu^.Y := inY;
    Neu^.Breite := inBreite;
    Neu^.Hoehe := inHoehe;
    Neu^.TextWert := inTextWert;
    Neu^.BoolWert := inBoolWert;
    Neu^.Farbe := inFarbe;

    if BildschirmObjekteAnfang = nil then
    begin
      BildschirmObjekteAnfang := Neu;
      BildschirmObjekteEnde := Neu;
      Neu^.Vorheriger := nil
    end
    else
    begin
      BildschirmObjekteEnde^.Naechster := Neu;
      Neu^.Vorheriger := BildschirmObjekteEnde;
      BildschirmObjekteEnde := Neu
    end

  end;  { ErzeugeBildschirmObjekt }





  procedure RegistriereBildschirmObjekte;

  { Bildschirmobjekte erzeugen und in die Liste der
    Bildschirmobjekte eintragen }

  begin

    BildschirmObjekteAnfang := nil;
    BildschirmObjekteEnde := nil;

    ErzeugeBildschirmObjekt
       ('Hauptfenster',FENSTER,EreignisBeenden,
        true,true,MINBSX,MINBSY,MAXBSX,MAXBSY,
        'GOMOKU',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Brett',SPIELFELD,EreignisSpielbrett,
        true,true,7,25,445,445,
        '',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextBrettgroesse',TEXT,EreignisTueNichts,
        false,true,462,30,1,1,
        'Brettgrî·e (ZxS)?',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('HoeheKleiner',KNOPF,EreignisHoeheKleiner,
        true,(Bretthoehe > MINBRETTGROESSE),460,45,30,20,
        '<',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('HoeheGroesser',KNOPF,EreignisHoeheGroesser,
        true,(Bretthoehe < MAXBRETTGROESSE),491,45,30,20,
        '>',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Brettgroesse',BOXTEXT,EreignisTueNichts,
        false,true,521,47,48,16,
        IntegerNachStringMitNullen(BrettHoehe,2) +
        'x' +
        IntegerNachStringMitNullen(BrettBreite,2),
        false,GELB);

    ErzeugeBildschirmObjekt
       ('BreiteKleiner',KNOPF,EreignisBreiteKleiner,
        true,(Brettbreite > MINBRETTGROESSE),569,45,30,20,
        '<',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('BreiteGroesser',KNOPF,EreignisBreiteGroesser,
        true,(Brettbreite < MAXBRETTGROESSE),600,45,30,20,
        '>',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextWerSpielt',TEXT,EreignisTueNichts,
        false,true,462,85,1,1,
        'Wer spielt gegen wen?',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextSpielername',TEXT,EreignisTueNichts,
        false,true,462,104,1,1,
        'Spieler 1 : Spieler 2',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextSpielerfarbe',TEXT,EreignisTueNichts,
        false,true,462,114,1,1,
        'wei·(beg.)    schwarz',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Sp1Ben',ANKREUZFELD,EreignisAuswahlSpieler1,
        true,true,460,127,16,16,
        '',(Spielerart[SPIELER1]=BENUTZERSPIELER),SCHWARZ);
    ErzeugeBildschirmObjekt
       ('TextBen',TEXT,EreignisTueNichts,
        false,true,482,131,1,1,
        '... Benutzer ...',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('Sp2Ben',ANKREUZFELD,EreignisAuswahlSpieler2,
        true,true,614,127,16,16,
        '',(Spielerart[SPIELER2]=BENUTZERSPIELER),SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Sp1CS0',ANKREUZFELD,EreignisAuswahlSpieler1,
        true,true,460,147,16,16,
        '',(CompSpielStaerke[SPIELER1]=0) and
        (Spielerart[SPIELER1]=COMPUTERSPIELER),SCHWARZ);
    ErzeugeBildschirmObjekt
       ('TextCS0',TEXT,EreignisTueNichts,
        false,true,482,151,1,1,
        'Computer Stufe 0',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('Sp2CS0',ANKREUZFELD,EreignisAuswahlSpieler2,
        true,true,614,147,16,16,
        '',(CompSpielStaerke[SPIELER2]=0) and
        (Spielerart[SPIELER2]=COMPUTERSPIELER),SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Sp1CS1',ANKREUZFELD,EreignisAuswahlSpieler1,
        true,true,460,167,16,16,
        '',(CompSpielStaerke[SPIELER1]=1) and
        (Spielerart[SPIELER1]=COMPUTERSPIELER),SCHWARZ);
    ErzeugeBildschirmObjekt
       ('TextCS1',TEXT,EreignisTueNichts,
        false,true,482,171,1,1,
        'Computer Stufe 1',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('Sp2CS1',ANKREUZFELD,EreignisAuswahlSpieler2,
        true,true,614,167,16,16,
        '',(CompSpielStaerke[SPIELER2]=1) and
        (Spielerart[SPIELER2]=COMPUTERSPIELER),SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Sp1CS2',ANKREUZFELD,EreignisAuswahlSpieler1,
        true,true,460,187,16,16,
        '',(CompSpielStaerke[SPIELER1]=2) and
        (Spielerart[SPIELER1]=COMPUTERSPIELER),SCHWARZ);
    ErzeugeBildschirmObjekt
       ('TextCS2',TEXT,EreignisTueNichts,
        false,true,482,191,1,1,
        'Computer Stufe 2',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('Sp2CS2',ANKREUZFELD,EreignisAuswahlSpieler2,
        true,true,614,187,16,16,
        '',(CompSpielStaerke[SPIELER2]=2) and
        (Spielerart[SPIELER2]=COMPUTERSPIELER),SCHWARZ);

    ErzeugeBildschirmObjekt
       ('SpielStart',KNOPF,EreignisSpielStart,
        true,true,460,220,170,20,
        'Spiel starten!',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextErklaerung',TEXTBOX,EreignisTueNichts,
        true,true,461,297,170,150,
        'Gomoku ist ein altes asiatisches Brettspiel fÅr zwei Personen. ' +
        'Die Spieler setzen abwechselnd einen Stein in irgendein freies ' +
        'KÑstchen. Wer zuerst fÅnf Steine seiner Farbe in einer Reihe ' +
        'legt, egal ob senkrecht, waagerecht oder diagonal, der hat ' +
        'gewonnen.',false,SCHWARZ);

    { ab hier die Objekte, die im Spiel aktiv werden }

    ErzeugeBildschirmObjekt
       ('TextBlaettern',TEXT,EreignisTueNichts,
        false,false,462,30,1,1,
        'RÅckw. BlÑttern Vorw.',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('ZugAnfang',KNOPF,EreignisZugAnfang,
        true,false,460,45,30,20,
        '≥<',false,SCHWARZ);
    ErzeugeBildschirmObjekt
       ('ZugZurueck',KNOPF,EreignisZugZurueck,
        true,false,491,45,30,20,
        '<',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('ZugNr',BOXTEXT,EreignisTueNichts,
        false,false,521,47,48,16,
        'Z#' +
        IntegerNachStringMitNullen(ZugNr,3),
        false,GELB);

    ErzeugeBildschirmObjekt
       ('ZugVor',KNOPF,EreignisZugVor,
        true,false,569,45,30,20,
        '>',(Bretthoehe > MINBRETTGROESSE),SCHWARZ);
    ErzeugeBildschirmObjekt
       ('ZugEnde',KNOPF,EreignisZugEnde,
        true,false,600,45,30,20,
        '>≥',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('SpielHinweis',BOXTEXT,EreignisTueNichts,
        false,false,460,210,168,16,
        'WEISS AM ZUG        ',false,GELB);
        {12345123451234512345}

    ErzeugeBildschirmObjekt
       ('CompZug',KNOPF,EreignisCompZug,
        true,false,460,235,170,20,
        'Comp.-Zug setzen',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Tipp',KNOPF,EreignisTipp,
        true,false,460,235,170,20,
        'Tipp anfordern',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('CompAutoZug',ANKREUZFELD,EreignisCompAutoZug,
        true,false,460,260,16,16,
        '',CompSetztAutomatisch,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextCompAutoZug',TEXT,EreignisTueNichts,
        false,false,484,264,150,8,
        'Automat. setzen',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('Seitenwechsel',KNOPF,EreignisSeitenwechsel,
        true,false,460,260,170,20,
        'Seitenwechsel',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('TextErklaerung2',TEXTBOX,EreignisTueNichts,
        true,false,461,297,170,150,
        'Gomoku ist ein altes asiatisches Brettspiel fÅr zwei Personen. ' +
        'Die Spieler setzen abwechselnd einen Stein in irgendein freies ' +
        'KÑstchen. Wer zuerst fÅnf Steine seiner Farbe in einer Reihe ' +
        'legt, egal ob senkrecht, waagerecht oder diagonal, der hat ' +
        'gewonnen.',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('SpielAbbruch',KNOPF,EreignisSpielAbbruch,
        true,false,460,448,170,20,
        'Abbruch & Neustart',false,SCHWARZ);

    ErzeugeBildschirmObjekt
       ('SpielNeu',KNOPF,EreignisSpielNeu,
        true,false,460,448,170,20,
        'Neues Spiel',false,SCHWARZ);

  end;  { RegistriereBildschirmObjekte }





  procedure VerarbeiteMausklick ( inX : tBildschXKoord;
                                  inY : tBildschYKoord);

  { Mausklick verarbeiten und die entsprechende
    Ereignis-Routine aufrufen
    inX, inY: Position des Mausklicks }

    var
    Obj : tBildschirmObjekt;
    Fertig : Boolean;

  begin

    Fertig := false;

    Obj := BildschirmObjekteEnde;
    while (Obj <> nil) and (not Fertig) do
    begin
      if Obj^.Sichtbar and Obj^.Aktiv then
        case Obj^.ObjektTyp of
          FENSTER :
            begin
              Fertig := IstMausKlickInGebiet (
              Obj^.X + Obj^.Breite - 18,
              Obj^.Y + 4, 14, 14, inX, inY );
              if Fertig then Obj^.Proz(Obj,0,0);
            end;
          KNOPF :
            begin
              Fertig := IstMausKlickInGebiet (
              Obj^.X, Obj^.Y, Obj^.Breite, Obj^.Hoehe, inX, inY );
              if Fertig then Obj^.Proz(Obj,inX-Obj^.X,inY-Obj^.Y);
            end;
          SPIELFELD :
            begin
              Fertig := IstMausKlickInGebiet (
              BrettX, BrettY, Feldgroesse*Brettbreite,
              Feldgroesse*Bretthoehe, inX, inY );
              if Fertig then Obj^.Proz(Obj,inX-BrettX,inY-BrettY);
            end;
          ANKREUZFELD :
            begin
              Fertig := IstMausKlickInGebiet (
              Obj^.X, Obj^.Y, Obj^.Breite, Obj^.Hoehe, inX, inY );
              if Fertig then
              begin
                Obj^.BoolWert := not Obj^.BoolWert;
                MaleBildschirmObjekt(Obj);
                Obj^.Proz(Obj,inX-Obj^.X,inY-Obj^.Y)
              end;
            end;
        end;  { case }
      Obj := Obj^.Vorheriger
    end  { while }

  end;  { VerarbeiteMausklick }





  procedure DurchfuehrenSpiel;

  { Den Spielbrett-Bildschirm darstellen und Interaktionen auf ihm
    verarbeiten. }

    var
    X : tBildschXKoord;
    Y : tBildschYKoord;

  begin

    DarstellungBildschirmObjekte;

    AnwendungBeenden := false;

    while not AnwendungBeenden do
    begin

      { Schleife zur Verarbeitung von Benutzer-Klicks }

      { Warten auf Benutzer-Klick }
      WarteAufMaus (X, Y);

      { Benutzer-Klick verarbeiten, betr. Ereignis-
        Routine aufrufen }
      VerarbeiteMausklick (X, Y);

    end;  { while }

  end;  { DurchfuehrenSpiel }





  procedure StarteGrafikUI;

  { Start und Ablauf der Grafik-Bedienoberflaeche des GOMOKU-Spiels }

  begin

    if not InitialisiereGrafikbildschirmUndMaus then
      DurchfuehrenSpiel;
    AbschlussarbeitenGrafikbildschirmUndMaus ('')

  end;  { StarteGrafikUI }





begin   { Initialisierung der Unit }


  Eingabephase := true;
  gibFeldgroesse(Brettbreite,Bretthoehe);
  gibStatus(Spielstatus);
  CompSpielStaerke[SPIELER1] := MAXCSSTAERKE;
  CompSpielStaerke[SPIELER2] := MAXCSSTAERKE;
  Spielerart[SPIELER1] := BENUTZERSPIELER;
  Spielerart[SPIELER2] := COMPUTERSPIELER;
  CompSetztAutomatisch := false;
  RegistriereBildschirmObjekte;


end.  { GrafUI }
