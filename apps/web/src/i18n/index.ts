import { getRequestConfig } from 'next-intl/server'
import { locales } from '@/i18n/config'

export default getRequestConfig(async ({ locale }) => {
  if (!locale || !locales.includes(locale as any)) {
    locale = 'es'
  }
  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default
  }
}) 