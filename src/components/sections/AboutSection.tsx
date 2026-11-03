import { Code2, Smartphone, Globe, Layers } from "lucide-react";

export function AboutSection() {
  return (
    <section id="about" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            About Me
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            Dedikasi pada Rekayasa Antarmuka & Kualitas Perangkat Lunak
          </p>
        </div>

        <div className="mt-10 grid grid-cols-1 gap-12 lg:grid-cols-12">
          {/* Main Story / Professional Background */}
          <div className="space-y-4 text-slate-600 lg:col-span-7 dark:text-slate-400 text-base leading-relaxed">
            <p>
              Saya adalah seorang <strong className="text-slate-900 dark:text-slate-200">Flutter Developer</strong> dan <strong className="text-slate-900 dark:text-slate-200">Web Developer</strong> lulusan Sistem Informasi (D3) STMIK PPKIA Pradnya Paramita. Saya memiliki pengalaman kerja profesional selama satu tahun di <strong className="text-slate-900 dark:text-slate-200">Thunderlabs</strong> sebagai Frontend Developer.
            </p>
            <p>
              Fokus utama saya terletak pada pembangunan aplikasi mobile dan antarmuka web yang terstruktur rapi, berkinerja tinggi, dan mudah dikelola. Dalam portofolio nyata, saya telah mengembangkan aplikasi Point of Sale (POS) mobile dan platform web yang terintegrasi langsung dengan ekosistem backend <strong className="text-slate-900 dark:text-slate-200">ERPNext</strong> melalui protokol RESTful API.
            </p>
            <p>
              Saya senantiasa menerapkan standar rekayasa perangkat lunak modern: pemisahan state logic yang bersih (Provider di Flutter), modularitas komponen pada React/Next.js, serta desain antarmuka berbasis kebutuhan bisnis pengguna akhir.
            </p>
          </div>

          {/* Pillars of Competence Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 lg:col-span-5">
            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-400 dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                <Smartphone size={20} />
              </div>
              <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                Mobile Development
              </h3>
              <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                Aplikasi Flutter multiplatform, state management Provider, dan integrasi hardware POS/printer.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-400 dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                <Globe size={20} />
              </div>
              <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                Modern Web Frontends
              </h3>
              <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                Implementasi SPA dan SSR dengan React.js, Next.js, Angular, dan Tailwind CSS.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-400 dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                <Layers size={20} />
              </div>
              <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                API & ERP Integration
              </h3>
              <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                Sinkronisasi data antar modul sistem, REST API, dan integrasi backend ERPNext/Laravel.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-400 dark:border-slate-800 dark:bg-slate-900/60 dark:hover:border-blue-500">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                <Code2 size={20} />
              </div>
              <h3 className="mt-3 text-sm font-semibold text-slate-900 dark:text-white">
                Clean Architecture
              </h3>
              <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                Kode terstruktur, penamaan semantik, pemisahan data logic, dan kemudahan pemeliharaan.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
