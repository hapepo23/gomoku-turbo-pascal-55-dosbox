program Gomoku (input, output);

{ Hauptprogramm:

  Ein Pascal-Programm, mit dem man Gomoku - ein
  altes chin./jap. Brettspiel "Fuenf in einer Reihe" - spielen
  kann.

  Der VGA-Treiber EGAVGA.BGI muss im Aufrufverzeichnis oder im
  Verzeichnis C:\TP\GRAPHICS vorhanden sein.

  Der optionale Aufrufparameter /D schreibt ein Protokoll
  zu Debugging-Zwecken in eine Datei DEBUG.TXT. Falls diese
  Datei bereits existiert, wird sie zu Beginn geloescht und
  neu angelegt.

  Der optionale Aufrufparameter /U veraendert das Unentschieden-
  Kriterium von "Brett voll" (kein /U) auf "keine Moeglichkeit
  mehr zum Sieg" (/U angegeben)  }

{ Datei in Zei.-Satz IBM850 -> „=84 ”=94 =81 Ž=8E ™=99 š=9A á=E1,
  Zeilenende DOS/Windows -> 0D+0A }


  uses
  GrafUI;


begin   { Hauptprogramm }


  StarteGrafikUI


end.  { Gomoku }
