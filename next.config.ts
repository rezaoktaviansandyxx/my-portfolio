import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // URL halaman menggunakan trailing slash
  trailingSlash: true,

  // Redirects
  async redirects() {
    return [
      {
        source: "/projects",
        destination: "/project/list",
        permanent: true,
      },
      {
        source: "/project",
        destination: "/project/list",
        permanent: true,
      },
    ];
  },

  // Tidak membutuhkan image optimization server
  images: {
    unoptimized: true,
  },

  // Konfigurasi Turbopack untuk Tailwind CSS
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
