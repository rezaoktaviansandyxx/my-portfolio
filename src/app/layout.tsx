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

const baseUrl = (process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app").replace(/\/$/, "");

export const metadata: Metadata = {
  metadataBase: new URL(baseUrl),
  title: {
    default: "Indra Oki Sandy | Flutter Developer & Web Developer",
    template: "%s | Indra Oki Sandy",
  },
  description: "Portofolio profesional Indra Oki Sandy - Flutter Developer & Web Developer dengan spesialisasi pengembangan mobile, integrasi REST API, dan sistem ERP.",
  keywords: ["Flutter Developer", "Web Developer", "React.js", "Next.js", "Dart", "ERPNext", "Indra Oki Sandy"],
  authors: [{ name: "Indra Oki Sandy", url: baseUrl }],
  creator: "Indra Oki Sandy",
  openGraph: {
    title: "Indra Oki Sandy | Flutter Developer & Web Developer",
    description: "Portofolio profesional Flutter Developer & Web Developer dengan pengalaman 1 tahun profesional dan integrasi sistem ERP.",
    url: baseUrl,
    siteName: "Indra Oki Sandy Portfolio",
    type: "website",
    locale: "id_ID",
  },
  twitter: {
    card: "summary_large_image",
    title: "Indra Oki Sandy | Flutter Developer & Web Developer",
    description: "Portofolio profesional Flutter Developer & Web Developer dengan pengalaman 1 tahun profesional dan integrasi sistem ERP.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Person",
    name: "Indra Oki Sandy",
    jobTitle: "Flutter Developer & Web Developer",
    url: baseUrl,
    sameAs: [
      "https://github.com/indraokisandy",
      "https://linkedin.com/in/indra-oki-sandy-3b6040243",
    ],
    knowsAbout: [
      "Flutter",
      "Dart",
      "React.js",
      "Next.js",
      "REST API",
      "ERPNext",
      "Mobile Development",
      "Web Development"
    ]
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
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
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
