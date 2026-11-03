import { experienceData } from "@/data/experience";
import { Briefcase, Calendar, CheckCircle } from "lucide-react";

export function ExperienceSection() {
  return (
    <section id="experience" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            Work Experience
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            Pengalaman Kerja Profesional
          </p>
          <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
            Rekam jejak pengalaman kerja berbasis kontrak kerja profesional.
          </p>
        </div>

        <div className="mt-10 space-y-6">
          {experienceData.map((exp, idx) => (
            <div
              key={idx}
              className="relative rounded-2xl border border-slate-200 bg-white p-6 sm:p-8 shadow-xs dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                <div>
                  <div className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-3 py-0.5 text-xs font-medium text-blue-700 dark:border-blue-900/50 dark:bg-blue-950/50 dark:text-blue-300">
                    <Briefcase size={12} />
                    {exp.type}
                  </div>
                  <h3 className="mt-3 text-xl font-bold text-slate-900 dark:text-white">
                    {exp.position}
                  </h3>
                  <p className="text-base font-semibold text-blue-600 dark:text-blue-400">
                    {exp.company}
                  </p>
                </div>

                <div className="flex items-center gap-1.5 text-xs font-medium text-slate-500 sm:text-right dark:text-slate-400">
                  <Calendar size={14} />
                  <span>{exp.period}</span>
                </div>
              </div>

              <p className="mt-4 text-sm text-slate-600 leading-relaxed dark:text-slate-300">
                {exp.description}
              </p>

              {exp.responsibilities && exp.responsibilities.length > 0 && (
                <div className="mt-5 border-t border-slate-100 pt-5 dark:border-slate-800">
                  <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                    Tanggung Jawab & Kontribusi:
                  </h4>
                  <ul className="mt-3 space-y-2">
                    {exp.responsibilities.map((resp, rIdx) => (
                      <li key={rIdx} className="flex items-start gap-2.5 text-xs sm:text-sm text-slate-600 dark:text-slate-300">
                        <CheckCircle size={15} className="mt-0.5 shrink-0 text-blue-600 dark:text-blue-400" />
                        <span>{resp}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
