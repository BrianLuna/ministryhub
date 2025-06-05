import { ClerkProvider } from '@clerk/nextjs'
import { getTranslations } from 'next-intl/server'
import { NextIntlClientProvider, hasLocale } from 'next-intl';
import { notFound } from 'next/navigation';
import { routing } from '@/i18n/routing'
import { esES, enUS } from '@clerk/localizations'
import { ThemeProvider } from "@/components/theme-provider"
import { ThemeModeToggle } from '@/components/theme-mode-togle'


import {
  SignInButton,
  SignUpButton,
  SignedIn,
  SignedOut,
  UserButton,
} from '@clerk/nextjs'
import type { Metadata } from 'next'
import { Geist, Geist_Mono } from 'next/font/google'
import '@/styles/globals.css'
import { Button } from '@/components/ui/button';

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
})

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
})

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const t = await getTranslations({ locale, namespace: 'home' })
  return {
    title: t('appName'),
    description: t('description'),
  }
}

type Props = {
  children: React.ReactNode
  params: Promise<{ locale: string }>
}

export default async function RootLayout({ children, params }: Props) {

  const {locale} = await params;
  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }
  
  const language = locale === 'es' ? esES : enUS;
  const t = await getTranslations('common');
  
  return (
    <ClerkProvider localization={language}>
      <html lang={locale} suppressHydrationWarning>
        <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
          <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange
          >
            <header className="flex justify-end items-center p-4 gap-4 h-16">
              <ThemeModeToggle />
              <SignedOut>
                <SignInButton children={
                  <Button>
                    <p>{t('signIn')}</p>
                  </Button>
                }/>
                <SignUpButton children={
                  <Button>
                    <p>{t('signUp')}</p>
                  </Button>
                }/>
              </SignedOut>
              <SignedIn>
                <UserButton />
              </SignedIn>
            </header>
            <NextIntlClientProvider>{children}</NextIntlClientProvider>
          </ThemeProvider>
        </body>
      </html>
    </ClerkProvider>
  )
}