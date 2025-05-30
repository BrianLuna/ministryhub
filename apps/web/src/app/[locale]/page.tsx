import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations();
  
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1>{t('app.name')}</h1>
      <p>{t('app.description')}</p>
    </main>
  );
} 