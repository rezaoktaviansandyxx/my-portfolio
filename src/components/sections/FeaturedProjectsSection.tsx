import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { projectsData } from "@/data/projects";
import { ProjectCard } from "@/components/projects/ProjectCard";

export function FeaturedProjectsSection() {
  const featured = projectsData.filter((p) => p.featured);

  return (
    <section id="projects" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
          <div className="max-w-2xl">
            <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
              Featured Projects
            </h2>
            <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
              Sorotan Proyek Unggulan
            </p>
            <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
              Aplikasi mobile produksi dan platform web modern yang terintegrasi dengan REST API dan sistem ERP.
            </p>
          </div>

          <Link
            href="/projects"
            className="inline-flex items-center gap-1.5 text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300"
          >
            Lihat Semua Proyek ({projectsData.length})
            <ArrowRight size={16} />
          </Link>
        </div>

        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6">
          {featured.map((project) => (
            <ProjectCard key={project.slug} project={project} />
          ))}
        </div>
      </div>
    </section>
  );
}
