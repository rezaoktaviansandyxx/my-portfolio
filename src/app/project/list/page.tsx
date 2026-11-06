"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ProjectCard } from "@/components/projects/ProjectCard";
import { projectsData } from "@/data/projects";
import { FadeIn } from "@/components/ui/MotionWrapper";
import { useLanguage } from "@/components/providers/LanguageProvider";

type FilterTab = "All" | "Flutter & Mobile" | "Web / React" | "POS & Desktop";

function matchesFilter(project: (typeof projectsData)[0], filter: FilterTab): boolean {
  if (filter === "All") return true;

  if (filter === "Flutter & Mobile") {
    return (
      project.category === "Mobile" ||
      project.technologies.some((t) => t.toLowerCase().includes("flutter"))
    );
  }

  if (filter === "Web / React") {
    return (
      project.category === "Frontend" ||
      project.technologies.some(
        (t) =>
          t.toLowerCase().includes("react") ||
          t.toLowerCase().includes("web") ||
          t.toLowerCase().includes("angular")
      )
    );
  }

  if (filter === "POS & Desktop") {
    return (
      project.category === "POS & Desktop" ||
      project.title.toLowerCase().includes("pos")
    );
  }

  return true;
}

export default function ProjectsListPage() {
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState<FilterTab>("All");

  const filterOptions: { id: FilterTab; label: string }[] = [
    { id: "All", label: t.projects.filterAll },
    { id: "Flutter & Mobile", label: t.projects.filterMobile },
    { id: "Web / React", label: t.projects.filterWeb },
    { id: "POS & Desktop", label: t.projects.filterPos },
  ];

  const filteredProjects = projectsData.filter((p) => matchesFilter(p, activeTab));

  const getTabCount = (tab: FilterTab) => {
    return projectsData.filter((p) => matchesFilter(p, tab)).length;
  };

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      <main className="flex-1 py-16 md:py-20">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <FadeIn>
            <div className="max-w-3xl">
              <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl dark:text-white">
                {t.projects.allProjectsTitle}
              </h1>
              <p className="mt-3 text-base text-slate-600 dark:text-slate-400">
                {t.projects.allProjectsDesc}
              </p>
            </div>
          </FadeIn>

          {/* Interactive Filter Tabs */}
          <FadeIn delay={0.1}>
            <div className="mt-8 flex flex-wrap gap-2.5">
              {filterOptions.map((option) => {
                const count = getTabCount(option.id);
                const isActive = activeTab === option.id;

                return (
                  <button
                    key={option.id}
                    onClick={() => setActiveTab(option.id)}
                    className={`relative flex items-center gap-2 rounded-xl px-4 py-2 text-xs sm:text-sm font-semibold transition-all duration-200 ${
                      isActive
                        ? "bg-blue-600 text-white shadow-sm shadow-blue-500/20"
                        : "border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    }`}
                  >
                    <span>{option.label}</span>
                    <span
                      className={`inline-flex items-center justify-center rounded-full px-2 py-0.5 text-[11px] font-bold ${
                        isActive
                          ? "bg-white/20 text-white"
                          : "bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400"
                      }`}
                    >
                      {count}
                    </span>
                  </button>
                );
              })}
            </div>
          </FadeIn>

          {/* Filtered Projects Grid with Smooth Transitions */}
          <motion.div
            layout
            className="mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            <AnimatePresence mode="popLayout">
              {filteredProjects.map((project) => (
                <motion.div
                  key={project.slug}
                  layout
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.25, ease: "easeOut" }}
                >
                  <ProjectCard project={project} />
                </motion.div>
              ))}
            </AnimatePresence>
          </motion.div>

          {filteredProjects.length === 0 && (
            <div className="mt-12 text-center py-12 rounded-2xl border border-dashed border-slate-200 dark:border-slate-800">
              <p className="text-sm text-slate-500 dark:text-slate-400">
                {t.projects.noProjectsFound}
              </p>
            </div>
          )}
        </div>
      </main>
      <Footer />
    </div>
  );
}
