import type { MetadataRoute } from "next";
import { projectsData } from "@/data/projects";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = (
    process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app"
  ).replace(/\/$/, "");

  // Section routes render the homepage and declare `/` as their canonical URL.
  // Only list canonical, independently indexable pages here.
  return [
    { url: `${baseUrl}/` },
    { url: `${baseUrl}/projects/list` },
    ...projectsData.map((project) => ({
      url: `${baseUrl}/projects/${project.slug}`,
    })),
  ];
}
