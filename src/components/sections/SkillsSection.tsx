import { skillCategoriesData } from "@/data/skills";
import { Check } from "lucide-react";

export function SkillsSection() {
  return (
    <section id="skills" className="py-20 border-t border-slate-200/80 bg-slate-50/50 dark:border-slate-800/80 dark:bg-slate-950/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            Technical Stack
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            Keahlian Teknis & Alat Kerja
          </p>
          <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
            Daftar teknologi dan keahlian yang secara nyata telah diterapkan dalam pengembangan aplikasi produksi maupun personal engineering.
          </p>
        </div>

        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {skillCategoriesData.map((item) => (
            <div
              key={item.category}
              className="rounded-xl border border-slate-200/90 bg-white p-6 shadow-xs transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
              <h3 className="text-base font-semibold text-slate-900 dark:text-white pb-3 border-b border-slate-100 dark:border-slate-800">
                {item.category}
              </h3>

              <div className="mt-4 flex flex-wrap gap-2">
                {item.skills.map((skill) => (
                  <span
                    key={skill}
                    className="inline-flex items-center gap-1.5 rounded-md border border-slate-200/80 bg-slate-50 px-2.5 py-1 text-xs font-medium text-slate-700 transition hover:border-blue-300 dark:border-slate-800 dark:bg-slate-800/60 dark:text-slate-200"
                  >
                    <Check size={12} className="text-blue-600 dark:text-blue-400" />
                    {skill}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
