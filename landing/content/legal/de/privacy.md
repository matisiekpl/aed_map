---
title: Datenschutzerklärung
updatedAt: '2026-10-15'
---

# Datenschutzerklärung

Diese Datenschutzerklärung gilt für die mobile App AED-Karte für iOS und Android sowie für die Website aedmapa.pl.

## Verantwortlicher

Verantwortlicher für die Datenverarbeitung ist Mateusz Woźniak. Kontakt in Angelegenheiten personenbezogener Daten: [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Von der App verarbeitete Daten

### Standort

Nach Erteilung der Berechtigung für den Standortzugriff verwendet die App den Standort, um die nächstgelegenen Defibrillatoren und die Entfernung zu ihnen anzuzeigen. Die ungefähren Koordinaten werden außerdem in Analyseereignissen von Mixpanel gespeichert (Beschreibung unten).

Bei der Berechnung eines Fußwegs werden die Koordinaten des Startpunkts und des ausgewählten AED an den Routing-Server Valhalla (sa.tt.com.pl) gesendet. Der Server gibt die Route zurück und erhält keine weiteren Daten über den Nutzer.

### Karte

Kartenausschnitte werden von den Servern der OpenStreetMap Foundation (tile.openstreetmap.org) geladen. Bei jedem Abruf erhält der Server die IP-Adresse des Geräts, gemäß der [Datenschutzerklärung der OSMF](https://osmfoundation.org/wiki/Privacy_Policy).

### OpenStreetMap-Konto

Das Hinzufügen und Bearbeiten von Defibrillatoren erfordert die Anmeldung mit einem OpenStreetMap-Konto (OAuth 2.0). Die App speichert das Zugriffstoken ausschließlich auf dem Gerät und ruft aus OpenStreetMap die Kennung, den Benutzernamen und den Avatar ab.

Jede in OpenStreetMap gespeicherte Änderung ist öffentlich und mit dem Benutzernamen gekennzeichnet. Die Änderungshistorie in OpenStreetMap unterliegt den Regeln der OpenStreetMap Foundation und kann von der App nicht gelöscht werden.

### Fotos

Ein Foto eines Defibrillators wird vor dem Senden auf dem Gerät von einem Modell geprüft, das unangemessene Inhalte erkennt. Das Foto wird an den Server des Projekts OpenAEDMap (back.openaedmap.org) übertragen, unter der Lizenz CC0 veröffentlicht und ist für alle Nutzer von OpenAEDMap sichtbar. Beim Melden eines Fotos wird dessen Kennung an OpenAEDMap übermittelt.

### Analyse und Diagnose

Die App nutzt folgende Dienste:

- **Mixpanel** (Mixpanel, Inc., Server in der EU): Ereignisse zur Nutzung der App, etwa die Auswahl eines Defibrillators, der Start der Navigation, ein Telefonanruf oder das Speichern einer Bearbeitung, zusammen mit dem Gerätemodell, der System- und App-Version sowie den Standortkoordinaten. Nach der Anmeldung mit einem OpenStreetMap-Konto werden die Ereignisse mit der Kennung, dem Namen und dem Avatar des OpenStreetMap-Nutzers verknüpft.
- **Sentry** (Functional Software, Inc.): Fehlerberichte und Leistungsdaten mit dem Gerätemodell und der Systemversion. Nach der Anmeldung enthält ein Bericht die Kennung und den Namen des OpenStreetMap-Nutzers. Feedback, das über den Einstellungsbildschirm gesendet wird, gelangt zusammen mit einem Screenshot und dem vom Nutzer eingegebenen Text an Sentry.
- **Firebase Analytics und Firebase Remote Config** (Google Ireland Ltd.): Nutzungsstatistiken der App, die mit einer Installationskennung verknüpft sind, sowie der Abruf der App-Konfiguration.
- **Plausible** (vom Verantwortlichen gehostete Instanz): aggregierte Statistiken zu Seitenaufrufen ohne Cookies und ohne Nutzerkennungen.

## Von der Website verarbeitete Daten

Die Website aedmapa.pl nutzt Plausible, das vom Verantwortlichen gehostet wird. Plausible setzt keine Cookies und speichert keine IP-Adressen. Die Website setzt das Cookie `i18n_redirected` mit der gewählten Sprache.

## Zweck und Rechtsgrundlage

- Bereitstellung der Funktionen der App (Standort, Route, Bearbeitung, Fotos): Erbringung des vom Nutzer angeforderten Dienstes (Art. 6 Abs. 1 lit. b DSGVO) sowie die im Betriebssystem erteilte Einwilligung in den Zugriff auf Standort und Fotos.
- Analyse und Fehlerdiagnose: berechtigtes Interesse des Verantwortlichen an der Wartung und Weiterentwicklung der App (Art. 6 Abs. 1 lit. f DSGVO).

## Übermittlung von Daten außerhalb des EWR

Sentry, Google und Mixpanel können Daten in den Vereinigten Staaten auf Grundlage von Standardvertragsklauseln oder des EU-U.S. Data Privacy Framework verarbeiten.

## Speicherdauer

- Daten in Mixpanel: bis zu 5 Jahre.
- Sentry-Berichte: 90 Tage.
- Daten in Firebase Analytics: 14 Monate.
- Auf dem Gerät gespeicherte Daten (Defibrillator-Datenbank, OpenStreetMap-Token, Einstellungen): bis zur Abmeldung oder Deinstallation der App.

## Rechte der Nutzer

Nutzer haben das Recht auf Auskunft über ihre Daten, auf Berichtigung, Löschung, Einschränkung der Verarbeitung und Datenübertragbarkeit sowie das Recht auf Widerspruch gegen eine Verarbeitung, die auf berechtigtem Interesse beruht. Anträge werden unter [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl) entgegengenommen. Außerdem besteht das Recht auf Beschwerde beim Präsidenten des polnischen Amtes für den Schutz personenbezogener Daten (UODO) oder bei der Aufsichtsbehörde im Wohnsitzland.

## Kinder

Die App richtet sich nicht an Kinder unter 13 Jahren und erhebt wissentlich keine Daten von ihnen.

## Änderungen

Eine neue Fassung der Datenschutzerklärung wird auf dieser Seite mit dem Datum der letzten Aktualisierung veröffentlicht.
