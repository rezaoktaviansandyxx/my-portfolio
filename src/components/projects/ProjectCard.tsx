import Link from "next/link";
import { ArrowRight, Code, ExternalLink } from "lucide-react";
import { Project } from "@/types";

interface ProjectCardProps {
  project: Project;
}

export function ProjectCard({ project }: ProjectCardProps) {
  const isCompleted = project.status === "Completed";

  return (
    <div className="group flex flex-col justify-between rounded-2xl border border-slate-200 bg-white p-6 shadow-xs transition duration-200 hover:-translate-y-1 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900 dark:hover:border-blue-500">
      <div>
        {/* Header Badges */}
        <div className="flex items-center justify-between gap-2">
          <span className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300">
            {project.role}
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

        {/* Title */}
        <h3 className="mt-4 text-lg font-bold text-slate-900 group-hover:text-blue-600 dark:text-white dark:group-hover:text-blue-400 transition-colors">
          <Link href={`/projects/${project.slug}`}>{project.title}</Link>
        </h3>

        {/* Description */}
        <p className="mt-2 text-xs sm:text-sm text-slate-600 leading-relaxed dark:text-slate-400">
          {project.shortDescription}
        </p>

        {/* Tech Stack */}
        <div className="mt-4 flex flex-wrap gap-1.5">
          {project.technologies.map((tech) => (
            <span
              key={tech}
              className="rounded-md bg-blue-50/80 px-2 py-0.5 text-[11px] font-medium text-blue-700 dark:bg-slate-800 dark:text-blue-300"
            >
              {tech}
            </span>
          ))}
        </div>
      </div>

      {/* Footer CTA */}
      <div className="mt-6 pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
        <Link
          href={`/projects/${project.slug}`}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300"
        >
          View Case Details
          <ArrowRight size={14} className="transition-transform group-hover:translate-x-1" />
        </Link>
      </div>
    </div>
  );
}
