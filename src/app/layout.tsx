import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/providers/ThemeProvider";
import { LanguageProvider } from "@/components/providers/LanguageProvider";
import { CommandMenuProvider } from "@/components/providers/CommandMenuProvider";
import { CommandMenu } from "@/components/ui/CommandMenu";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const baseUrl = (
  process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app"
).replace(/\/$/, "");

const GITHUB_URL = "https://github.com/rezaoktaviansandyxx"; // samakan dengan link di halaman
const LINKEDIN_URL = "https://www.linkedin.com/in/indraokisandy/";

export const metadata: Metadata = {
  metadataBase: new URL(baseUrl),
  title: {
    default: "Indra Oki Sandy | Flutter Developer & Web Developer",
    template: "%s | Indra Oki Sandy",
  },
  description:
    "Portofolio Indra Oki Sandy, Flutter Developer & Web Developer di Surabaya. Spesialisasi aplikasi mobile, POS, integrasi REST API, dan sistem ERPNext.",
  keywords: [
    "Flutter Developer",
    "Web Developer",
    "React.js",
    "Next.js",
    "Dart",
    "ERPNext",
    "Indra Oki Sandy",
  ],
  authors: [{ name: "Indra Oki Sandy", url: baseUrl }],
  creator: "Indra Oki Sandy",
  alternates: {
    canonical: "/",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  verification: {
    // Ganti dengan kode dari Google Search Console (metode HTML tag)
    google: "DxNS0W0nuHk8LPnOVVvNdhjyA3c0G9u-0uW0rnJkRbg",
  },
  openGraph: {
    title: "Indra Oki Sandy | Flutter Developer & Web Developer",
    description:
      "Portofolio Flutter Developer & Web Developer dengan pengalaman 1 tahun profesional dan integrasi sistem ERP.",
    url: baseUrl,
    siteName: "Indra Oki Sandy Portfolio",
    type: "website",
    locale: "id_ID",
  },
  twitter: {
    card: "summary_large_image",
    title: "Indra Oki Sandy | Flutter Developer & Web Developer",
    description:
      "Portofolio Flutter Developer & Web Developer dengan pengalaman 1 tahun profesional dan integrasi sistem ERP.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Person",
        "@id": `${baseUrl}/#person`,
        name: "Indra Oki Sandy",
        jobTitle: "Flutter Developer & Web Developer",
        url: baseUrl,
        image: `${baseUrl}/images/profile.jpg`,
        email: "mailto:indraokisandy1@gmail.com",
        address: {
          "@type": "PostalAddress",
          addressLocality: "Surabaya",
          addressRegion: "Jawa Timur",
          addressCountry: "ID",
        },
        alumniOf: {
          "@type": "CollegeOrUniversity",
          name: "STMIK PPKIA Pradnya Paramita Malang",
        },
        sameAs: [GITHUB_URL, LINKEDIN_URL],
        knowsAbout: [
          "Flutter",
          "Dart",
          "React.js",
          "Next.js",
          "REST API",
          "ERPNext",
          "Mobile Development",
          "Web Development",
        ],
      },
      {
        "@type": "WebSite",
        "@id": `${baseUrl}/#website`,
        url: baseUrl,
        name: "Indra Oki Sandy Portfolio",
        inLanguage: "id-ID",
        publisher: { "@id": `${baseUrl}/#person` },
      },
    ],
  };

  return (
    <html
      lang="id"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col font-sans transition-colors duration-200">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
          }}
        />
        <ThemeProvider>
          <LanguageProvider>
            <CommandMenuProvider>
              {children}
              <CommandMenu />
            </CommandMenuProvider>
          </LanguageProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}