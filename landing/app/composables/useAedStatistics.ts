import {Config} from '~/config'
import type {AedCountry} from '~/types/aedCountry'

export function useAedStatistics() {
  const {data: countries} = useAsyncData('aed-statistics', () => $fetch<AedCountry[]>(Config.aedCountriesUrl), {
    default: () => [],
    transform: countries => countries.map(({country_code, feature_count}) => ({country_code, feature_count})),
  })

  const featureCount = (countryCode: string) => countries.value.find(country => country.country_code === countryCode)?.feature_count ?? 0
  const worldCount = computed(() => featureCount('WORLD'))
  const countryCount = computed(() => countries.value.filter(country => country.country_code !== 'WORLD' && country.feature_count > 0).length)

  return {worldCount, countryCount, featureCount}
}
