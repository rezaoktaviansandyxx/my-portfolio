import { MetadataRoute } from "next";
import { projectsData } from "@/data/projects";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = (
    process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app"
  ).replace(/\/$/, "");

  // Ubah tanggal ini hanya saat konten benar-benar berubah
  const lastUpdated = new Date("2026-11-06");

  const staticRoutes: MetadataRoute.Sitemap = [
    { url: `${baseUrl}/`, lastModified: lastUpdated, priority: 1.0 },
    { url: `${baseUrl}/about/`, lastModified: lastUpdated, priority: 0.9 },
    { url: `${baseUrl}/skills/`, lastModified: lastUpdated, priority: 0.9 },
    { url: `${baseUrl}/projects/`, lastModified: lastUpdated, priority: 0.9 },
    { url: `${baseUrl}/experience/`, lastModified: lastUpdated, priority: 0.9 },
    { url: `${baseUrl}/education/`, lastModified: lastUpdated, priority: 0.8 },
    { url: `${baseUrl}/contact/`, lastModified: lastUpdated, priority: 0.8 },
    { url: `${baseUrl}/project/list/`, lastModified: lastUpdated, priority: 0.9 },
  ];

  const projectRoutes: MetadataRoute.Sitemap = projectsData.map((project) => ({
    url: `${baseUrl}/projects/${project.slug}/`,
    lastModified: lastUpdated,
    priority: 0.7,
  }));

  return [...staticRoutes, ...projectRoutes];
}
