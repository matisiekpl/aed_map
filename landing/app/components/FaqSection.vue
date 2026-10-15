<script setup lang="ts">
const {t} = useI18n()

const questions = ['emergency', 'source', 'add', 'abroad', 'offline', 'update']

useSchemaOrg([
  defineWebPage({'@type': 'FAQPage'}),
  ...questions.map(question => defineQuestion({
    name: t(`faq.items.${question}.question`),
    acceptedAnswer: t(`faq.items.${question}.answer`),
  })),
])
</script>

<template>
  <section id="faq" class="mx-auto max-w-3xl scroll-mt-16 px-4 py-8 sm:py-16 md:py-24">
    <h2 class="mb-4 text-3xl sm:mb-8 font-extrabold tracking-tight md:text-4xl">{{ $t('faq.title') }}</h2>
    <Accordion type="single" collapsible>
      <AccordionItem v-for="question in questions" :key="question" :value="question">
        <AccordionTrigger class="cursor-pointer text-left text-base font-semibold">{{ $t(`faq.items.${question}.question`) }}</AccordionTrigger>
        <AccordionContent class="text-base">{{ $t(`faq.items.${question}.answer`) }}</AccordionContent>
      </AccordionItem>
    </Accordion>
  </section>
</template>
