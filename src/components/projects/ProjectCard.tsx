import Link from "next/link";
import Image from "next/image";
import { ArrowRight, Code, ExternalLink } from "lucide-react";
import { Project } from "@/types";
import { useLanguage } from "@/components/providers/LanguageProvider";

interface ProjectCardProps {
  project: Project;
  priority?: boolean;
}

export function ProjectCard({ project, priority = false }: ProjectCardProps) {
  const { language } = useLanguage();
  const isEn = language === "en";

  const description = isEn && project.shortDescriptionEn ? project.shortDescriptionEn : project.shortDescription;
  const role = isEn && project.roleEn ? project.roleEn : project.role;
  const category = isEn && project.categoryEn ? project.categoryEn : project.category;

  return (
    <div className="group flex flex-col justify-between overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xs transition duration-200 hover:-translate-y-1 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900 dark:hover:border-blue-500">
      <div>
        {/* Project Thumbnail if available */}
        {project.image && (
          <Link
            href={`/projects/${project.slug}`}
            className="block relative aspect-video w-full overflow-hidden bg-slate-100 dark:bg-slate-800"
          >
            <Image
              src={project.image}
              alt={project.title}
              fill
              priority={priority}
              className={`transition duration-300 group-hover:scale-105 ${
                project.category === "Mobile"
                  ? "object-contain p-2"
                  : "object-cover object-top"
              }`}
            />
          </Link>
        )}

        <div className="p-6">
          {/* Header Badges */}
          <div className="flex items-center justify-between gap-2">
            <span className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300">
              {role}
            </span>
            <span className="rounded-md bg-blue-50 px-2.5 py-1 text-xs font-medium text-blue-700 dark:bg-blue-950/60 dark:text-blue-300">
              {category}
            </span>
          </div>

          {/* Title */}
          <h3 className="mt-4 text-lg font-bold text-slate-900 group-hover:text-blue-600 dark:text-white dark:group-hover:text-blue-400 transition-colors">
            <Link href={`/projects/${project.slug}`}>{project.title}</Link>
          </h3>

          {/* Description */}
          <p className="mt-2 text-xs sm:text-sm text-slate-600 leading-relaxed dark:text-slate-400">
            {description}
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
      </div>

      {/* Footer CTA */}
      <div className="p-6 pt-0">
        <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
          <Link
            href={`/projects/${project.slug}`}
            className="inline-flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300"
          >
            {isEn ? "View Details" : "Lihat Detail"}
            <ArrowRight size={14} className="transition-transform group-hover:translate-x-1" />
          </Link>
        </div>
      </div>
    </div>
  );
}
