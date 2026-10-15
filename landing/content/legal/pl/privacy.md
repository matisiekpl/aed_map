---
title: Polityka prywatności
updatedAt: '2026-10-15'
---

# Polityka prywatności

Ta polityka dotyczy aplikacji mobilnej Mapa AED na iOS i Androida oraz strony aedmapa.pl.

## Administrator

Administratorem danych jest Mateusz Woźniak. Kontakt w sprawach danych osobowych: [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Dane przetwarzane przez aplikację

### Lokalizacja

Po udzieleniu zgody na dostęp do lokalizacji aplikacja używa jej do pokazania najbliższych defibrylatorów i odległości do nich. Przybliżone współrzędne są też zapisywane w zdarzeniach analitycznych Mixpanel (opis niżej).

Przy wyznaczaniu trasy pieszej współrzędne punktu startowego i wybranego AED są wysyłane do serwera wyznaczania tras Valhalla (sa.tt.com.pl). Serwer zwraca trasę i nie otrzymuje innych danych o użytkowniku.

### Mapa

Fragmenty mapy pobierane są z serwerów OpenStreetMap Foundation (tile.openstreetmap.org). Przy każdym pobraniu serwer otrzymuje adres IP urządzenia, zgodnie z [polityką prywatności OSMF](https://osmfoundation.org/wiki/Privacy_Policy).

### Konto OpenStreetMap

Dodawanie i edycja defibrylatorów wymaga zalogowania kontem OpenStreetMap (OAuth 2.0). Aplikacja przechowuje token dostępu wyłącznie na urządzeniu i pobiera z OpenStreetMap identyfikator, nazwę użytkownika i awatar.

Każda zmiana zapisana w OpenStreetMap jest publiczna i podpisana nazwą użytkownika. Historia zmian w OpenStreetMap podlega zasadom OpenStreetMap Foundation i nie może zostać usunięta przez aplikację.

### Zdjęcia

Zdjęcie defibrylatora przed wysłaniem jest sprawdzane na urządzeniu przez model wykrywający treści nieodpowiednie. Zdjęcie trafia na serwer projektu OpenAEDMap (back.openaedmap.org), jest publikowane na licencji CC0 i widoczne dla wszystkich użytkowników OpenAEDMap. Zgłoszenie zdjęcia przesyła do OpenAEDMap jego identyfikator.

### Analityka i diagnostyka

Aplikacja korzysta z następujących usług:

- **Mixpanel** (Mixpanel, Inc., serwery w UE): zdarzenia użycia aplikacji, takie jak wybór defibrylatora, rozpoczęcie nawigacji, połączenie telefoniczne czy zapis edycji, wraz z modelem urządzenia, wersją systemu i aplikacji oraz współrzędnymi lokalizacji. Po zalogowaniu kontem OpenStreetMap zdarzenia są powiązane z identyfikatorem, nazwą i awatarem użytkownika OpenStreetMap.
- **Sentry** (Functional Software, Inc.): raporty błędów i dane o wydajności, z modelem urządzenia i wersją systemu. Po zalogowaniu raport zawiera identyfikator i nazwę użytkownika OpenStreetMap. Opinia wysłana z ekranu ustawień trafia do Sentry razem ze zrzutem ekranu i treścią wpisaną przez użytkownika.
- **Firebase Analytics i Firebase Remote Config** (Google Ireland Ltd.): statystyki użycia aplikacji powiązane z identyfikatorem instalacji oraz pobieranie konfiguracji aplikacji.
- **Plausible** (instancja hostowana przez administratora): zagregowane statystyki odsłon bez plików cookie i bez identyfikatorów użytkownika.

## Dane przetwarzane przez stronę

Strona aedmapa.pl korzysta z Plausible hostowanego przez administratora. Plausible nie zapisuje plików cookie i nie przechowuje adresów IP. Strona zapisuje plik cookie `i18n_redirected` z wybranym językiem.

## Cel i podstawa prawna

- Działanie funkcji aplikacji (lokalizacja, trasa, edycja, zdjęcia): wykonanie usługi, o którą prosi użytkownik (art. 6 ust. 1 lit. b RODO) oraz zgoda na dostęp do lokalizacji i zdjęć udzielana w systemie.
- Analityka i diagnostyka błędów: prawnie uzasadniony interes administratora polegający na utrzymaniu i rozwoju aplikacji (art. 6 ust. 1 lit. f RODO).

## Przekazywanie danych poza EOG

Sentry, Google i Mixpanel mogą przetwarzać dane w Stanach Zjednoczonych na podstawie standardowych klauzul umownych lub EU-U.S. Data Privacy Framework.

## Okres przechowywania

- Dane w Mixpanel: do 5 lat.
- Raporty Sentry: 90 dni.
- Dane Firebase Analytics: 14 miesięcy.
- Dane zapisane na urządzeniu (baza defibrylatorów, token OpenStreetMap, ustawienia): do wylogowania lub odinstalowania aplikacji.

## Prawa użytkownika

Użytkownikowi przysługuje prawo dostępu do danych, ich sprostowania, usunięcia, ograniczenia przetwarzania, przenoszenia oraz sprzeciwu wobec przetwarzania opartego na prawnie uzasadnionym interesie. Wnioski przyjmowane są pod adresem [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl). Przysługuje też prawo wniesienia skargi do Prezesa Urzędu Ochrony Danych Osobowych.

## Dzieci

Aplikacja nie jest skierowana do dzieci poniżej 13 roku życia i nie zbiera świadomie ich danych.

## Zmiany

Nowa wersja polityki jest publikowana na tej stronie z datą ostatniej aktualizacji.
