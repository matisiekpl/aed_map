import {Config} from '~/config'
import type {AedCountry} from '~/types/aedCountry'

export function useAedStatistics() {
  const {data: countries} = useAsyncData('aed-statistics', () => $fetch<AedCountry[]>(Config.aedCountriesUrl), {
    default: () => [],
    transform: countries => countries.map(({country_code, feature_count}) => ({country_code, feature_count})),
  })

  const worldCount = computed(() => countries.value.find(country => country.country_code === 'WORLD')?.feature_count ?? 0)
  const polandCount = computed(() => countries.value.find(country => country.country_code === 'PL')?.feature_count ?? 0)
  const countryCount = computed(() => countries.value.filter(country => country.country_code !== 'WORLD' && country.feature_count > 0).length)

  return {worldCount, polandCount, countryCount}
}
