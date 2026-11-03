"use client";

import { educationData } from "@/data/experience";
import { GraduationCap, Calendar } from "lucide-react";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function EducationSection() {
  const { t, language } = useLanguage();

  if (!educationData || educationData.length === 0) {
    return null;
  }

  const isEn = language === "en";

  return (
    <section id="education" className="py-20 border-t border-slate-200/80 bg-slate-50/50 dark:border-slate-800/80 dark:bg-slate-950/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            {t.education.tag}
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            {t.education.title}
          </p>
          <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
            {t.education.desc}
          </p>
        </div>

        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6">
          {educationData.map((edu, idx) => (
            <div
              key={idx}
              className="rounded-xl border border-slate-200 bg-white p-6 shadow-xs dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                    <GraduationCap size={22} />
                  </div>
                  <div>
                    <span className="inline-block rounded-md bg-blue-50 px-2 py-0.5 text-xs font-semibold text-blue-700 dark:bg-blue-950/60 dark:text-blue-300">
                      {isEn && edu.degreeEn ? edu.degreeEn : edu.degree}
                    </span>
                    <h3 className="mt-1 text-base font-bold text-slate-900 dark:text-white">
                      {isEn && edu.majorEn ? edu.majorEn : edu.major}
                    </h3>
                  </div>
                </div>

                <div className="flex items-center gap-1 text-xs font-medium text-slate-500 dark:text-slate-400">
                  <Calendar size={13} />
                  <span>{edu.graduationYear}</span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-slate-100 dark:border-slate-800">
                <p className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  {edu.institution}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
