"use client";

import Link from "next/link";
import Image from "next/image";
import { ArrowLeft, CheckCircle2, ChevronRight } from "lucide-react";
import { GithubIcon } from "@/components/ui/Icons";
import { Project } from "@/types";
import { ProjectCard } from "@/components/projects/ProjectCard";
import { ProjectGallery } from "@/components/projects/ProjectGallery";
import { useLanguage } from "@/components/providers/LanguageProvider";

interface ProjectDetailContentProps {
  project: Project;
  relatedProjects: Project[];
}

export function ProjectDetailContent({ project, relatedProjects }: ProjectDetailContentProps) {
  const { t, language } = useLanguage();
  const isEn = language === "en";

  const description = isEn && project.shortDescriptionEn ? project.shortDescriptionEn : project.shortDescription;
  const overview = isEn && project.overviewEn ? project.overviewEn : project.overview;
  const responsibilities = isEn && project.responsibilitiesEn ? project.responsibilitiesEn : project.responsibilities;
  const role = isEn && project.roleEn ? project.roleEn : project.role;
  const category = isEn && project.categoryEn ? project.categoryEn : project.category;

  return (
    <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
      {/* Breadcrumbs */}
      <nav className="flex items-center gap-2 text-xs font-medium text-slate-500 dark:text-slate-400">
        <Link href="/" className="hover:text-blue-600 dark:hover:text-blue-400">
          {t.nav.home}
        </Link>
        <ChevronRight size={14} />
        <Link href="/projects" className="hover:text-blue-600 dark:hover:text-blue-400">
          {t.nav.projects}
        </Link>
        <ChevronRight size={14} />
        <span className="text-slate-900 dark:text-white truncate">{project.title}</span>
      </nav>

      {/* Header */}
      <div className="mt-6 border-b border-slate-200 pb-8 dark:border-slate-800">
        <div className="flex flex-wrap items-center gap-3">
          <span className="rounded-md bg-blue-50 px-2.5 py-1 text-xs font-semibold text-blue-700 dark:bg-blue-950/60 dark:text-blue-300">
            {category}
          </span>
        </div>

        <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl dark:text-white">
          {project.title}
        </h1>

        <p className="mt-3 text-base text-slate-600 leading-relaxed dark:text-slate-300">
          {description}
        </p>

        {/* Featured Image */}
        {project.image && (
          <div className="mt-6 overflow-hidden rounded-2xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900 shadow-md">
            <div
              className={`relative w-full ${
                project.category === "Mobile"
                  ? "h-80 sm:h-96 md:h-112.5"
                  : "aspect-video"
              }`}
            >
              <Image
                src={project.image}
                alt={project.title}
                fill
                priority
                className={
                  project.category === "Mobile"
                    ? "object-contain p-4"
                    : "object-cover"
                }
              />
            </div>
          </div>
        )}

        {/* Quick Meta Stats */}
        <div className="mt-6 grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-slate-100 dark:border-slate-850">
          <div>
            <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
              {t.projects.roleLabel}
            </p>
            <p className="mt-1 text-sm font-semibold text-slate-800 dark:text-slate-200">
              {role}
            </p>
          </div>

          <div>
            <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
              {t.projects.categoryLabel}
            </p>
            <p className="mt-1 text-sm font-semibold text-slate-800 dark:text-slate-200">
              {category}
            </p>
          </div>

          {project.githubUrl && (
            <div>
              <p className="text-[11px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">
                {t.projects.sourceCodeLabel}
              </p>
              <a
                href={project.githubUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="mt-1 inline-flex items-center gap-1 text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400"
              >
                <GithubIcon size={14} /> {t.projects.repository}
              </a>
            </div>
          )}
        </div>
      </div>

      {/* Content Sections */}
      <div className="mt-8 space-y-10">
        {/* Overview */}
        {overview && (
          <div>
            <h2 className="text-lg font-bold text-slate-900 dark:text-white">
              {t.projects.overviewTitle}
            </h2>
            <p className="mt-3 text-sm sm:text-base leading-relaxed text-slate-600 dark:text-slate-300">
              {overview}
            </p>
          </div>
        )}

        {/* Tech Stack */}
        <div>
          <h2 className="text-lg font-bold text-slate-900 dark:text-white">
            {t.projects.technologiesTitle}
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
        {responsibilities && responsibilities.length > 0 && (
          <div>
            <h2 className="text-lg font-bold text-slate-900 dark:text-white">
              {t.projects.responsibilitiesTitle}
            </h2>
            <ul className="mt-3 space-y-2.5">
              {responsibilities.map((resp, idx) => (
                <li key={idx} className="flex items-start gap-2.5 text-sm text-slate-600 dark:text-slate-300">
                  <CheckCircle2 size={16} className="mt-0.5 shrink-0 text-blue-600 dark:text-blue-400" />
                  <span>{resp}</span>
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Gallery Screenshots */}
        {project.gallery && project.gallery.length > 0 && (
          <div>
            <h2 className="text-lg font-bold text-slate-900 dark:text-white">
              {t.projects.galleryTitle}
            </h2>
            <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
              {t.projects.gallerySubtitle}
            </p>
            <ProjectGallery
              title={project.title}
              gallery={project.gallery}
              isMobile={project.category === "Mobile"}
            />
          </div>
        )}
      </div>

      {/* Related Projects */}
      {relatedProjects.length > 0 && (
        <div className="mt-16 border-t border-slate-200 pt-10 dark:border-slate-800">
          <h3 className="text-base font-bold text-slate-900 dark:text-white">
            {t.projects.relatedProjectsTitle}
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
          {t.projects.backToProjects}
        </Link>
      </div>
    </div>
  );
}
