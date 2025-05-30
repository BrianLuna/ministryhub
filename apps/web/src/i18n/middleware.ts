import createMiddleware from 'next-intl/middleware';

export default createMiddleware({
  locales: ['en', 'es'],
  defaultLocale: 'es',
  localePrefix: 'as-needed'
});

export const config = {
  matcher: ['/', '/(es|en)/:path*']
}; 