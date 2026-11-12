import { notFound } from "next/navigation";
import { projectsData } from "@/data/projects";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ProjectDetailContent } from "@/components/projects/ProjectDetailContent";
import type { Metadata } from "next";

interface ProjectDetailPageProps {
  params: Promise<{
    slug: string;
  }>;
}

export async function generateStaticParams() {
  return projectsData.map((project) => ({
    slug: project.slug,
  }));
}

export async function generateMetadata({ params }: ProjectDetailPageProps): Promise<Metadata> {
  const { slug } = await params;
  const project = projectsData.find((item) => item.slug === slug);

  if (!project) {
    return { title: "Proyek Tidak Ditemukan", robots: { index: false, follow: false } };
  }

  const image = project.image ? [{ url: project.image, alt: project.title }] : undefined;

  return {
    title: project.title,
    description: project.shortDescription,
    alternates: { canonical: `/projects/${project.slug}` },
    openGraph: {
      title: `${project.title} | Indra Oki Sandy`,
      description: project.shortDescription,
      url: `/projects/${project.slug}`,
      type: "article",
      images: image,
    },
    twitter: {
      card: "summary_large_image",
      title: `${project.title} | Indra Oki Sandy`,
      description: project.shortDescription,
      images: image?.map(({ url }) => url),
    },
  };
}

export default async function ProjectDetailPage({ params }: ProjectDetailPageProps) {
  const { slug } = await params;
  const project = projectsData.find((p) => p.slug === slug);

  if (!project) {
    notFound();
  }

  const baseUrl = (
    process.env.NEXT_PUBLIC_SITE_URL || "https://indraokisandy-dev.vercel.app"
  ).replace(/\/$/, "");
  const projectJsonLd = {
    "@context": "https://schema.org",
    "@type": "CreativeWork",
    name: project.title,
    description: project.shortDescription,
    url: `${baseUrl}/projects/${project.slug}`,
    ...(project.image ? { image: `${baseUrl}${project.image}` } : {}),
    creator: { "@type": "Person", name: "Indra Oki Sandy", url: baseUrl },
    keywords: project.technologies.join(", "),
  };

  const relatedProjects = projectsData
    .filter((p) => p.slug !== project.slug && p.category === project.category)
    .slice(0, 2);

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(projectJsonLd).replace(/</g, "\\u003c"),
        }}
      />

      <main className="flex-1 py-12 md:py-16">
        <ProjectDetailContent project={project} relatedProjects={relatedProjects} />
      </main>

      <Footer />
    </div>
  );
}
