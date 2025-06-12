'use client'

import { ClerkProvider } from '@clerk/nextjs'
import { dark } from '@clerk/themes'
import { useTheme } from 'next-themes'
import { esES, enUS } from '@clerk/localizations'

type Props = {
  children: React.ReactNode
  locale: string
}

export function ClerkThemeProvider({ children, locale }: Props) {
  const { theme } = useTheme()
  const language = locale === 'es' ? esES : enUS

  return (
    <ClerkProvider 
      localization={language} 
      appearance={{
        baseTheme: theme === 'dark' ? dark : undefined
      }}
    >
      {children}
    </ClerkProvider>
  )
} 