import {defineCollection, defineContentConfig, z} from '@nuxt/content'

export default defineContentConfig({
  collections: {
    legal: defineCollection({
      type: 'page',
      source: 'legal/**/*.md',
      schema: z.object({
        updatedAt: z.string(),
      }),
    }),
  },
})
