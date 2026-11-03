"use client";

import { useState } from "react";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ProjectCard } from "@/components/projects/ProjectCard";
import { projectsData } from "@/data/projects";
import { ProjectCategory } from "@/types";

const categories: { label: string; value: ProjectCategory | "All" }[] = [
  { label: "Semua Proyek", value: "All" },
  { label: "Mobile (Flutter)", value: "Mobile" },
  { label: "Frontend Web", value: "Frontend" },
  { label: "Fullstack", value: "Fullstack" },
  { label: "Personal Project", value: "Personal Project" }
];

export default function ProjectsPage() {
  const [activeCategory, setActiveCategory] = useState<ProjectCategory | "All">("All");

  const filteredProjects =
    activeCategory === "All"
      ? projectsData
      : projectsData.filter((p) => p.category === activeCategory);

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      <main className="flex-1 py-16 md:py-20">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl">
            <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl dark:text-white">
              Daftar Seluruh Proyek
            </h1>
            <p className="mt-3 text-base text-slate-600 dark:text-slate-400">
              Kompilasi portofolio proyek mobile development berbasis Flutter dan aplikasi web dengan integrasi REST API & ERP.
            </p>
          </div>

          {/* Category Filters */}
          <div className="mt-8 flex flex-wrap gap-2">
            {categories.map((cat) => (
              <button
                key={cat.value}
                onClick={() => setActiveCategory(cat.value)}
                className={`rounded-lg px-4 py-2 text-xs font-semibold transition ${
                  activeCategory === cat.value
                    ? "bg-blue-600 text-white shadow-xs"
                    : "border border-slate-200 bg-white text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>

          {/* Projects Grid */}
          <div className="mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredProjects.map((project) => (
              <ProjectCard key={project.slug} project={project} />
            ))}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
