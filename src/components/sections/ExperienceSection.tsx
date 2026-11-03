"use client";

import { localizedExperienceData } from "@/data/experience";
import { Briefcase, Calendar, MapPin, CheckCircle } from "lucide-react";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/MotionWrapper";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function ExperienceSection() {
  const { t, language } = useLanguage();

  return (
    <section id="experience" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <FadeIn>
          <div className="max-w-2xl">
            <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
              {t.experience.tag}
            </h2>
            <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
              {t.experience.title}
            </p>
            <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
              {t.experience.desc}
            </p>
          </div>
        </FadeIn>

        <StaggerContainer className="mt-10 space-y-6" staggerDelay={0.15}>
          {localizedExperienceData.map((exp, idx) => {
            const isEn = language === "en";
            const period = isEn && exp.periodEn ? exp.periodEn : exp.period;
            const location = isEn && exp.locationEn ? exp.locationEn : exp.location;
            const type = isEn && exp.typeEn ? exp.typeEn : exp.type;
            const description = isEn && exp.descriptionEn ? exp.descriptionEn : exp.description;
            const responsibilities = isEn && exp.responsibilitiesEn ? exp.responsibilitiesEn : exp.responsibilities;

            return (
              <StaggerItem key={idx}>
                <div className="relative rounded-2xl border border-slate-200 bg-white p-6 sm:p-8 shadow-xs dark:border-slate-800 dark:bg-slate-900 transition hover:shadow-md hover:border-slate-300 dark:hover:border-slate-700">
                  <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                    <div>
                      {type && (
                        <div className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-3 py-0.5 text-xs font-medium text-blue-700 dark:border-blue-900/50 dark:bg-blue-950/50 dark:text-blue-300">
                          <Briefcase size={12} />
                          {type}
                        </div>
                      )}
                      <h3 className="mt-3 text-xl font-bold text-slate-900 dark:text-white">
                        {exp.position}
                      </h3>
                      <p className="text-base font-semibold text-blue-600 dark:text-blue-400">
                        {exp.company}
                      </p>
                    </div>

                    <div className="flex flex-col sm:items-end gap-1.5 text-xs font-medium text-slate-500 sm:text-right dark:text-slate-400">
                      <div className="flex items-center gap-1.5">
                        <Calendar size={14} />
                        <span>{period}</span>
                      </div>
                      {location && (
                        <div className="flex items-center gap-1.5 text-slate-400 dark:text-slate-500">
                          <MapPin size={13} />
                          <span>{location}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Description */}
                  <p className="mt-4 text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                    {description}
                  </p>

                  {/* Responsibilities */}
                  {responsibilities && responsibilities.length > 0 && (
                    <div className="mt-4 space-y-2 border-t border-slate-100 dark:border-slate-800 pt-4">
                      {responsibilities.map((r, i) => (
                        <div key={i} className="flex items-start gap-2 text-xs text-slate-600 dark:text-slate-300">
                          <CheckCircle size={14} className="text-emerald-500 shrink-0 mt-0.5" />
                          <span>{r}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </StaggerItem>
            );
          })}
        </StaggerContainer>
      </div>
    </section>
  );
}
