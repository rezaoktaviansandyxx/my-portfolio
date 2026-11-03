import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/providers/ThemeProvider";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Indra Oki Sandy | Flutter Developer & Web Developer",
  description: "Portofolio profesional Indra Oki Sandy - Flutter Developer & Web Developer dengan spesialisasi pengembangan mobile, integrasi REST API, dan sistem ERP.",
  keywords: ["Flutter Developer", "Web Developer", "React.js", "Next.js", "Dart", "ERPNext", "Indra Oki Sandy"],
  authors: [{ name: "Indra Oki Sandy" }],
  openGraph: {
    title: "Indra Oki Sandy | Flutter Developer & Web Developer",
    description: "Portofolio profesional Flutter Developer & Web Developer dengan pengalaman 1 tahun profesional dan integrasi sistem ERP.",
    type: "website",
    locale: "id_ID"
  }
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="id"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col font-sans transition-colors duration-200">
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
