import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Daftar Proyek",
  description:
    "Jelajahi proyek aplikasi Flutter, POS, dan web yang dikembangkan oleh Indra Oki Sandy.",
  alternates: { canonical: "/projects/list" },
  openGraph: {
    title: "Daftar Proyek | Indra Oki Sandy",
    description:
      "Jelajahi proyek aplikasi Flutter, POS, dan web yang dikembangkan oleh Indra Oki Sandy.",
    url: "/projects/list",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Daftar Proyek | Indra Oki Sandy",
    description:
      "Jelajahi proyek aplikasi Flutter, POS, dan web yang dikembangkan oleh Indra Oki Sandy.",
  },
};

export default function ProjectsListLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
