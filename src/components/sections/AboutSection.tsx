"use client";

import { Smartphone, Monitor, Database, GitBranch } from "lucide-react";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/MotionWrapper";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function AboutSection() {
  const { t } = useLanguage();

  return (
    <section id="about" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <FadeIn>
          <div className="max-w-2xl">
            <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
              {t.about.tag}
            </h2>
            <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
              {t.about.title}
            </p>
          </div>
        </FadeIn>

        <div className="mt-10 grid grid-cols-1 gap-12 lg:grid-cols-12">
          {/* Main Story / Professional Background */}
          <FadeIn direction="up" delay={0.1} className="space-y-4 text-slate-600 lg:col-span-7 dark:text-slate-400 text-base leading-relaxed">
            <p>
              {t.about.p1_1} <strong className="text-slate-900 dark:text-slate-200">{t.about.p1_flutter}</strong> {t.about.p1_and} <strong className="text-slate-900 dark:text-slate-200">{t.about.p1_web}</strong> {t.about.p1_edu} <strong className="text-slate-900 dark:text-slate-200">{t.about.p1_thunder}</strong> {t.about.p1_role}
            </p>
            <p>
              {t.about.p2_1} <strong className="text-slate-900 dark:text-slate-200">{t.about.p2_erp}</strong> {t.about.p2_api}
            </p>
            <p>
              {t.about.p3}
            </p>
          </FadeIn>

          {/* Pillars of Competence Cards */}
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 gap-4 lg:col-span-5" staggerDelay={0.1}>
            <StaggerItem>
              <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <Smartphone size={20} />
                </div>
                <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                  {t.about.card1_title}
                </h3>
                <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                  {t.about.card1_desc}
                </p>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <Monitor size={20} />
                </div>
                <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                  {t.about.card2_title}
                </h3>
                <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                  {t.about.card2_desc}
                </p>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <Database size={20} />
                </div>
                <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                  {t.about.card3_title}
                </h3>
                <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                  {t.about.card3_desc}
                </p>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <GitBranch size={20} />
                </div>
                <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                  {t.about.card4_title}
                </h3>
                <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                  {t.about.card4_desc}
                </p>
              </div>
            </StaggerItem>
          </StaggerContainer>
        </div>
      </div>
    </section>
  );
}
