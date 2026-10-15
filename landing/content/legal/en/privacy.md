---
title: Privacy Policy
updatedAt: '2026-10-15'
---

# Privacy Policy

This policy applies to the AED Map mobile app for iOS and Android and to the aedmapa.pl website.

## Controller

The data controller is Mateusz Woźniak. Contact for personal data matters: [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Data processed by the app

### Location

Once access to location is granted, the app uses it to show the nearest defibrillators and the distance to them. Approximate coordinates are also recorded in Mixpanel analytics events (described below).

When a walking route is calculated, the coordinates of the starting point and of the selected AED are sent to the Valhalla routing server (sa.tt.com.pl). The server returns the route and receives no other data about the user.

### Map

Map tiles are downloaded from OpenStreetMap Foundation servers (tile.openstreetmap.org). With each download, the server receives the device's IP address, in accordance with the [OSMF privacy policy](https://osmfoundation.org/wiki/Privacy_Policy).

### OpenStreetMap account

Adding and editing defibrillators requires signing in with an OpenStreetMap account (OAuth 2.0). The app stores the access token only on the device and retrieves the user ID, username and avatar from OpenStreetMap.

Every change saved to OpenStreetMap is public and signed with the username. The edit history in OpenStreetMap is governed by the rules of the OpenStreetMap Foundation and cannot be deleted by the app.

### Photos

Before upload, a photo of a defibrillator is checked on the device by a model that detects inappropriate content. The photo is sent to the OpenAEDMap project server (back.openaedmap.org), published under the CC0 license and visible to all OpenAEDMap users. Reporting a photo sends its identifier to OpenAEDMap.

### Analytics and diagnostics

The app uses the following services:

- **Mixpanel** (Mixpanel, Inc., servers in the EU): app usage events, such as selecting a defibrillator, starting navigation, placing a phone call or saving an edit, together with the device model, operating system and app version, and location coordinates. After signing in with an OpenStreetMap account, events are linked to the OpenStreetMap user ID, username and avatar.
- **Sentry** (Functional Software, Inc.): error reports and performance data, with the device model and operating system version. After signing in, a report includes the OpenStreetMap user ID and username. Feedback sent from the settings screen goes to Sentry together with a screenshot and the text entered by the user.
- **Firebase Analytics and Firebase Remote Config** (Google Ireland Ltd.): app usage statistics linked to an installation identifier, and retrieval of the app configuration.
- **Plausible** (instance hosted by the controller): aggregated page view statistics without cookies and without user identifiers.

## Data processed by the website

The aedmapa.pl website uses Plausible hosted by the controller. Plausible does not set cookies and does not store IP addresses. The website sets an `i18n_redirected` cookie with the selected language.

## Purpose and legal basis

- Operation of the app's features (location, route, editing, photos): performance of the service requested by the user (art. 6(1)(b) GDPR) and consent to access location and photos granted in the operating system.
- Analytics and error diagnostics: the controller's legitimate interest in maintaining and developing the app (art. 6(1)(f) GDPR).

## Transfers outside the EEA

Sentry, Google and Mixpanel may process data in the United States on the basis of standard contractual clauses or the EU-U.S. Data Privacy Framework.

## Retention period

- Data in Mixpanel: up to 5 years.
- Sentry reports: 90 days.
- Firebase Analytics data: 14 months.
- Data stored on the device (defibrillator database, OpenStreetMap token, settings): until sign-out or uninstallation of the app.

## User rights

The user has the right to access their data, to rectify it, to have it erased, to restrict its processing, to data portability and to object to processing based on legitimate interest. Requests are accepted at [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl). The user also has the right to lodge a complaint with the President of the Personal Data Protection Office (UODO) in Poland or the supervisory authority in the country of residence.

## Children

The app is not directed at children under 13 and does not knowingly collect their data.

## Changes

A new version of this policy is published on this page with the date of the last update.
