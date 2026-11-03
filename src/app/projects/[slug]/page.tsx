import { notFound } from "next/navigation";
import { projectsData } from "@/data/projects";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ProjectDetailContent } from "@/components/projects/ProjectDetailContent";

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

export default async function ProjectDetailPage({ params }: ProjectDetailPageProps) {
  const { slug } = await params;
  const project = projectsData.find((p) => p.slug === slug);

  if (!project) {
    notFound();
  }

  const relatedProjects = projectsData
    .filter((p) => p.slug !== project.slug && p.category === project.category)
    .slice(0, 2);

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />

      <main className="flex-1 py-12 md:py-16">
        <ProjectDetailContent project={project} relatedProjects={relatedProjects} />
      </main>

      <Footer />
    </div>
  );
}
