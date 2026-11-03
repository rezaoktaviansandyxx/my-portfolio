
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Generate website statis ke folder /out
  output: "export",

  // URL halaman menggunakan trailing slash
  trailingSlash: true,

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