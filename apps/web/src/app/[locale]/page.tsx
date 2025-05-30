import { useTranslations } from 'next-intl'

export default function Home() {
  const t = useTranslations()

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm">
        <h1 className="text-4xl font-bold mb-4">{t('home.title')}</h1>
        <p className="text-xl">{t('home.description')}</p>
      </div>
    </main>
  )
} 