import { useTranslations } from 'next-intl';

export function Example() {
  const t = useTranslations();
  
  return (
    <div>
      <h1>{t('common.loading')}</h1>
      <button>{t('common.save')}</button>
      <p>{t('errors.required')}</p>
    </div>
  );
} 