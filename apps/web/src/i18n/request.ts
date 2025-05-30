import { getRequestConfig } from 'next-intl/server';
import type { GetRequestConfigParams } from 'next-intl/server';

export default getRequestConfig(async ({ locale }: GetRequestConfigParams) => {

  const resolvedLocale = locale || 'es';
  
  return {
    locale: resolvedLocale,
    messages: (await import(`../messages/${resolvedLocale}.json`)).default
  };
}); 