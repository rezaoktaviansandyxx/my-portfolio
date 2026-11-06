"use client";

import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { projectsData } from "@/data/projects";
import { ProjectCard } from "@/components/projects/ProjectCard";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/MotionWrapper";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function FeaturedProjectsSection() {
  const { t } = useLanguage();
  const featured = projectsData.filter((p) => p.featured);

  return (
    <section id="projects" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <FadeIn>
          <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
            <div className="max-w-2xl">
              <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
                {t.projects.tag}
              </h2>
              <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
                {t.projects.title}
              </p>
              <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
                {t.projects.desc}
              </p>
            </div>

            <Link
              href="/projects/list"
              className="inline-flex items-center gap-1.5 text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300"
            >
              {t.projects.viewAll} ({projectsData.length})
              <ArrowRight size={16} />
            </Link>
          </div>
        </FadeIn>

        <StaggerContainer className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6" staggerDelay={0.12}>
          {featured.map((project, index) => (
            <StaggerItem key={project.slug}>
              <ProjectCard project={project} priority={index < 2} />
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
