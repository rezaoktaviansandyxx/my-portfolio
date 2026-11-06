import { MetadataRoute } from "next";
import { projectsData } from "@/data/projects";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = (
    process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app"
  ).replace(/\/$/, "");

  // Ubah tanggal ini hanya saat konten benar-benar berubah
  const lastUpdated = new Date("2026-11-05");

  const staticRoutes: MetadataRoute.Sitemap = [
    { url: `${baseUrl}/`, lastModified: lastUpdated, priority: 1.0 },
    { url: `${baseUrl}/project/list/`, lastModified: lastUpdated, priority: 0.9 },
    { url: `${baseUrl}/contact/`, lastModified: lastUpdated, priority: 0.8 },
  ];

  const projectRoutes: MetadataRoute.Sitemap = projectsData.map((project) => ({
    url: `${baseUrl}/projects/${project.slug}/`,
    lastModified: lastUpdated,
    priority: 0.7,
  }));

  return [...staticRoutes, ...projectRoutes];
}