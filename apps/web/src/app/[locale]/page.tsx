import { getTranslations } from 'next-intl/server'

export default async function Home({ params }: { params: Promise<{ locale: string }> }) {

  const t = await getTranslations('home');
  

  return (
    <main className="flex flex-col items-center p-8">
      <div className="max-w-5xl w-full items-center justify-between font-mono text-sm">
        <h1 className="text-4xl font-bold mb-4">{t('title')}</h1>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
        <p className="text-xl">{t('description')}</p>
      </div>
    </main>
  )
} 