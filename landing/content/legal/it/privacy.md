---
title: Informativa sulla privacy
updatedAt: '2026-10-15'
---

# Informativa sulla privacy

La presente informativa riguarda l'app mobile Mappa dei DAE per iOS e Android e il sito aedmapa.pl.

## Titolare del trattamento

Il titolare del trattamento dei dati è Mateusz Woźniak. Contatto per le questioni relative ai dati personali: [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Dati trattati dall'app

### Posizione

Dopo il consenso all'accesso alla posizione, l'app la utilizza per mostrare i defibrillatori più vicini e la distanza da essi. Le coordinate approssimative vengono inoltre registrate negli eventi di analisi di Mixpanel (descritti più avanti).

Durante il calcolo del percorso a piedi, le coordinate del punto di partenza e del DAE selezionato vengono inviate al server di calcolo dei percorsi Valhalla (sa.tt.com.pl). Il server restituisce il percorso e non riceve altri dati sull'utente.

### Mappa

Le parti di mappa vengono scaricate dai server della OpenStreetMap Foundation (tile.openstreetmap.org). A ogni download il server riceve l'indirizzo IP del dispositivo, secondo l'[informativa sulla privacy della OSMF](https://osmfoundation.org/wiki/Privacy_Policy).

### Account OpenStreetMap

L'aggiunta e la modifica dei defibrillatori richiedono l'accesso con un account OpenStreetMap (OAuth 2.0). L'app conserva il token di accesso esclusivamente sul dispositivo e ottiene da OpenStreetMap l'identificativo, il nome utente e l'avatar.

Ogni modifica salvata in OpenStreetMap è pubblica e firmata con il nome utente. La cronologia delle modifiche in OpenStreetMap è soggetta alle regole della OpenStreetMap Foundation e non può essere cancellata dall'app.

### Foto

Prima dell'invio, la foto del defibrillatore viene verificata sul dispositivo da un modello che rileva contenuti inappropriati. La foto viene caricata sul server del progetto OpenAEDMap (back.openaedmap.org), pubblicata con licenza CC0 e resa visibile a tutti gli utenti di OpenAEDMap. La segnalazione di una foto trasmette a OpenAEDMap il suo identificativo.

### Analisi e diagnostica

L'app utilizza i seguenti servizi:

- **Mixpanel** (Mixpanel, Inc., server nell'UE): eventi di utilizzo dell'app, come la selezione di un defibrillatore, l'avvio della navigazione, una chiamata telefonica o il salvataggio di una modifica, insieme al modello del dispositivo, alla versione del sistema e dell'app e alle coordinate della posizione. Dopo l'accesso con un account OpenStreetMap, gli eventi sono associati all'identificativo, al nome e all'avatar dell'utente OpenStreetMap.
- **Sentry** (Functional Software, Inc.): segnalazioni di errori e dati sulle prestazioni, con il modello del dispositivo e la versione del sistema. Dopo l'accesso, la segnalazione contiene l'identificativo e il nome utente OpenStreetMap. Il feedback inviato dalla schermata delle impostazioni viene trasmesso a Sentry insieme a uno screenshot e al testo inserito dall'utente.
- **Firebase Analytics e Firebase Remote Config** (Google Ireland Ltd.): statistiche di utilizzo dell'app associate all'identificativo dell'installazione e download della configurazione dell'app.
- **Plausible** (istanza ospitata dal titolare): statistiche aggregate delle visualizzazioni, senza cookie e senza identificativi dell'utente.

## Dati trattati dal sito

Il sito aedmapa.pl utilizza Plausible ospitato dal titolare. Plausible non salva cookie e non conserva indirizzi IP. Il sito salva il cookie `i18n_redirected` con la lingua selezionata.

## Finalità e base giuridica

- Funzionamento delle funzioni dell'app (posizione, percorso, modifica, foto): esecuzione del servizio richiesto dall'utente (art. 6, par. 1, lett. b), del GDPR) e consenso all'accesso alla posizione e alle foto concesso nel sistema.
- Analisi e diagnostica degli errori: legittimo interesse del titolare consistente nel mantenimento e nello sviluppo dell'app (art. 6, par. 1, lett. f), del GDPR).

## Trasferimento dei dati al di fuori del SEE

Sentry, Google e Mixpanel possono trattare dati negli Stati Uniti sulla base delle clausole contrattuali standard o dell'EU-U.S. Data Privacy Framework.

## Periodo di conservazione

- Dati in Mixpanel: fino a 5 anni.
- Segnalazioni Sentry: 90 giorni.
- Dati di Firebase Analytics: 14 mesi.
- Dati salvati sul dispositivo (database dei defibrillatori, token OpenStreetMap, impostazioni): fino alla disconnessione o alla disinstallazione dell'app.

## Diritti dell'utente

L'utente ha il diritto di accesso ai dati, di rettifica, di cancellazione, di limitazione del trattamento, di portabilità e di opposizione al trattamento basato sul legittimo interesse. Le richieste vengono accolte all'indirizzo [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl). L'utente ha inoltre il diritto di proporre reclamo al Presidente dell'Ufficio polacco per la protezione dei dati personali (UODO) o all'autorità di controllo del paese di residenza (in Italia, il Garante per la protezione dei dati personali).

## Minori

L'app non è destinata ai minori di 13 anni e non raccoglie consapevolmente i loro dati.

## Modifiche

La nuova versione dell'informativa viene pubblicata su questa pagina con la data dell'ultimo aggiornamento.
