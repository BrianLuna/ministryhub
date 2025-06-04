import { clerkMiddleware } from '@clerk/nextjs/server'
import {routing} from './i18n/routing';
import createMiddleware from 'next-intl/middleware'
 
const intlMiddleware = createMiddleware(routing);

export default clerkMiddleware(async (_, request) => {
  return intlMiddleware(request)
})

export const config = {
  matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};