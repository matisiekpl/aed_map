import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  compatibilityDate: '2026-10-01',
  devtools: {enabled: true},
  modules: [
    '@nuxtjs/i18n',
    '@nuxtjs/seo',
    '@nuxt/content',
    '@nuxt/fonts',
    '@nuxt/image',
    '@nuxtjs/plausible',
    'shadcn-nuxt',
  ],
  shadcn: {
    prefix: '',
    componentDir: '@/components/ui',
  },
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [tailwindcss()],
  },
  site: {
    url: 'https://aedmapa.pl',
    name: 'Mapa AED',
  },
  i18n: {
    baseUrl: 'https://aedmapa.pl',
    defaultLocale: 'pl',
    strategy: 'prefix_except_default',
    locales: [
      {code: 'pl', language: 'pl-PL', name: 'Polski', file: 'pl.json'},
      {code: 'en', language: 'en-US', name: 'English', file: 'en.json'},
      {code: 'de', language: 'de-DE', name: 'Deutsch', file: 'de.json'},
      {code: 'es', language: 'es-ES', name: 'Español', file: 'es.json'},
      {code: 'fr', language: 'fr-FR', name: 'Français', file: 'fr.json'},
      {code: 'it', language: 'it-IT', name: 'Italiano', file: 'it.json'},
    ],
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'i18n_redirected',
      redirectOn: 'root',
    },
  },
  schemaOrg: {
    identity: {
      type: 'Person',
      name: 'Mateusz Woźniak',
      email: 'mateusz@aedmapa.pl',
      sameAs: [
        'https://github.com/matisiekpl',
        'https://x.com/matisiekpl',
      ],
    },
  },
  ogImage: {
    zeroRuntime: true,
  },
  fonts: {
    families: [
      {name: 'Manrope', provider: 'google', weights: [400, 500, 600, 700, 800]},
    ],
  },
  plausible: {
    apiHost: 'https://analytics.mateuszwozniak.com',
    domain: 'aedmapa.pl',
    autoOutboundTracking: true,
  },
  routeRules: {
    '/en.html': {redirect: '/en'},
    '/prywatnosc.html': {redirect: '/privacy'},
    '/blog.html': {redirect: '/'},
    '/blog': {redirect: '/'},
  },
  nitro: {
    prerender: {
      crawlLinks: true,
      routes: [
        '/sitemap.xml',
        '/robots.txt',
        ...['', '/en', '/de', '/es', '/fr', '/it'].flatMap(prefix => [prefix || '/', `${prefix}/privacy`, `${prefix}/terms`]),
      ],
    },
  },
})
