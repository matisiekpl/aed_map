<template>
  <section id="download" class="scroll-mt-16 bg-muted/50">
    <div class="mx-auto flex max-w-4xl flex-col items-center gap-5 px-4 py-8 text-center sm:gap-6 sm:py-16 md:py-24">
      <img src="/images/icon.png" alt="" width="80" height="80" class="size-20 rounded-[22%] shadow">
      <h2 class="text-3xl font-extrabold tracking-tight md:text-4xl">{{ $t('download.title') }}</h2>
      <p>{{ $t('download.description') }}</p>
      <StoreBadges class="justify-center"/>
    </div>
  </section>
</template>
