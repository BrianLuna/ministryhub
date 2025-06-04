import { NextConfig } from 'next';
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  reactStrictMode: true,
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'x-middleware-cache',
            value: 'no-cache, no-store, must-revalidate'
          }
        ]
      }
    ];
  }
};

export default withNextIntl(nextConfig); 