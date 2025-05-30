const withNextIntl = require('next-intl/plugin')('./src/i18n/index.ts')

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
}

module.exports = withNextIntl(nextConfig) 