"use client";

import { skillCategoriesData } from "@/data/skills";
import { Check } from "lucide-react";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/MotionWrapper";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function SkillsSection() {
  const { t } = useLanguage();

  return (
    <section id="skills" className="py-20 border-t border-slate-200/80 bg-slate-50/50 dark:border-slate-800/80 dark:bg-slate-950/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <FadeIn>
          <div className="max-w-2xl">
            <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
              {t.skills.tag}
            </h2>
            <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
              {t.skills.title}
            </p>
            <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
              {t.skills.desc}
            </p>
          </div>
        </FadeIn>

        <StaggerContainer className="mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" staggerDelay={0.08}>
          {skillCategoriesData.map((item) => (
            <StaggerItem key={item.category}>
              <div className="rounded-xl border border-slate-200/90 bg-white p-6 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:shadow-md hover:border-blue-300 dark:border-slate-800 dark:bg-slate-900 dark:hover:border-blue-600/50">
                <h3 className="text-base font-semibold text-slate-900 dark:text-white pb-3 border-b border-slate-100 dark:border-slate-800">
                  {item.category}
                </h3>

                <div className="mt-4 flex flex-wrap gap-2">
                  {item.skills.map((skill) => (
                    <span
                      key={skill}
                      className="inline-flex items-center gap-1.5 rounded-md border border-slate-200/80 bg-slate-50 px-2.5 py-1 text-xs font-medium text-slate-700 transition-colors duration-150 hover:border-blue-400 hover:text-blue-600 hover:bg-blue-50/50 dark:border-slate-800 dark:bg-slate-800/60 dark:text-slate-200 dark:hover:border-blue-500 dark:hover:text-blue-300"
                    >
                      <Check size={12} className="text-blue-600 dark:text-blue-400" />
                      {skill}
                    </span>
                  ))}
                </div>
              </div>
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
