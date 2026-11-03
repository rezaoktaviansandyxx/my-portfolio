import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, CheckCircle2, ChevronRight, Layers, User, Calendar, ExternalLink } from "lucide-react";
import { GithubIcon } from "@/components/ui/Icons";
import { projectsData } from "@/data/projects";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ProjectCard } from "@/components/projects/ProjectCard";

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

  const isCompleted = project.status === "Completed";
  const relatedProjects = projectsData
    .filter((p) => p.slug !== project.slug && p.category === project.category)
    .slice(0, 2);

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />

      <main className="flex-1 py-12 md:py-16">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          {/* Breadcrumbs */}
          <nav className="flex items-center gap-2 text-xs font-medium text-slate-500 dark:text-slate-400">
            <Link href="/" className="hover:text-blue-600 dark:hover:text-blue-400">Home</Link>
            <ChevronRight size={14} />
            <Link href="/projects" className="hover:text-blue-600 dark:hover:text-blue-400">Projects</Link>
            <ChevronRight size={14} />
            <span className="text-slate-900 dark:text-white truncate">{project.title}</span>
          </nav>

          {/* Header */}
          <div className="mt-6 border-b border-slate-200 pb-8 dark:border-slate-800">
            <div className="flex flex-wrap items-center gap-3">
              <span className="rounded-md bg-blue-50 px-2.5 py-1 text-xs font-semibold text-blue-700 dark:bg-blue-950/60 dark:text-blue-300">
                {project.category}
              </span>
              <span
                className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                  isCompleted
                    ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800/40"
                    : "bg-amber-50 text-amber-700 dark:bg-amber-950/60 dark:text-amber-300 border border-amber-200 dark:border-amber-800/40"
                }`}
              >
                {project.status}
              </span>
            </div>

            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl dark:text-white">
              {project.title}
            </h1>

            <p className="mt-3 text-base text-slate-600 leading-relaxed dark:text-slate-300">
              {project.shortDescription}
            </p>

            {/* Quick Meta Stats */}
            <div className="mt-6 grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-slate-100 dark:border-slate-850">
              <div>
                <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
                  Role / Posisi
                </p>
                <p className="mt-1 text-sm font-semibold text-slate-800 dark:text-slate-200">
                  {project.role}
                </p>
              </div>

              <div>
                <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
                  Status Proyek
                </p>
                <p className="mt-1 text-sm font-semibold text-slate-800 dark:text-slate-200">
                  {project.status}
                </p>
              </div>

              {project.githubUrl && (
                <div>
                  <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
                    Source Code
                  </p>
                  <a
                    href={project.githubUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="mt-1 inline-flex items-center gap-1 text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400"
                  >
                    <GithubIcon size={14} /> Repository
                  </a>
                </div>
              )}
            </div>
          </div>

          {/* Content Sections */}
          <div className="mt-8 space-y-10">
            {/* Overview */}
            {project.overview && (
              <div>
                <h2 className="text-lg font-bold text-slate-900 dark:text-white">
                  Ringkasan Proyek
                </h2>
                <p className="mt-3 text-sm sm:text-base leading-relaxed text-slate-600 dark:text-slate-300">
                  {project.overview}
                </p>
              </div>
            )}

            {/* Tech Stack */}
            <div>
              <h2 className="text-lg font-bold text-slate-900 dark:text-white">
                Teknologi & Alat yang Digunakan
              </h2>
              <div className="mt-3 flex flex-wrap gap-2">
                {project.technologies.map((tech) => (
                  <span
                    key={tech}
                    className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 shadow-xs dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200"
                  >
                    {tech}
                  </span>
                ))}
              </div>
            </div>

            {/* Responsibilities */}
            {project.responsibilities && project.responsibilities.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-slate-900 dark:text-white">
                  Tanggung Jawab & Kontribusi Teknis
                </h2>
                <ul className="mt-3 space-y-2.5">
                  {project.responsibilities.map((resp, idx) => (
                    <li key={idx} className="flex items-start gap-2.5 text-sm text-slate-600 dark:text-slate-300">
                      <CheckCircle2 size={16} className="mt-0.5 shrink-0 text-blue-600 dark:text-blue-400" />
                      <span>{resp}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>

          {/* Related Projects */}
          {relatedProjects.length > 0 && (
            <div className="mt-16 border-t border-slate-200 pt-10 dark:border-slate-800">
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                Proyek Terkait dalam Kategori yang Sama
              </h3>
              <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                {relatedProjects.map((p) => (
                  <ProjectCard key={p.slug} project={p} />
                ))}
              </div>
            </div>
          )}

          {/* Back link */}
          <div className="mt-12 pt-6 border-t border-slate-200 dark:border-slate-800">
            <Link
              href="/projects"
              className="inline-flex items-center gap-2 text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400"
            >
              <ArrowLeft size={16} />
              Kembali ke Semua Proyek
            </Link>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
