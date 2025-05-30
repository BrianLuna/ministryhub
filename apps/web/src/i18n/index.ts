import { getRequestConfig } from 'next-intl/server';
import type { GetRequestConfigParams } from 'next-intl/server';

export async function getMessages(locale: string) {
  try {
    return (await import(`../messages/${locale}.json`)).default;
  } catch (error) {
    return (await import(`../messages/es.json`)).default;
  }
}

export default getRequestConfig(async ({ locale }: GetRequestConfigParams) => {
  const resolvedLocale = locale || 'es';
  return {
    locale: resolvedLocale,
    messages: await getMessages(resolvedLocale)
  };
}); 