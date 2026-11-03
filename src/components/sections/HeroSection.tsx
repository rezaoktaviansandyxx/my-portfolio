import Link from "next/link";
import { ArrowDownToLine, ArrowRight, Mail, CheckCircle2 } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { contactData } from "@/data/navigation";

export function HeroSection() {
  return (
    <section className="relative overflow-hidden py-20 md:py-28 lg:py-32">
      {/* Background soft ambient grid */}
      <div className="absolute inset-0 -z-10 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:24px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]" />

      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col items-start max-w-3xl">
          {/* Status Badge */}
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/20 bg-emerald-50/80 px-3 py-1 text-xs font-medium text-emerald-700 backdrop-blur-sm dark:border-emerald-500/30 dark:bg-emerald-950/40 dark:text-emerald-300">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500" />
            </span>
            Available for Full-time Roles & Freelance Projects
          </div>

          {/* Name & Title */}
          <h1 className="mt-6 text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl lg:text-6xl dark:text-white">
            Hi, saya <span className="text-blue-600 dark:text-blue-400">{contactData.name}</span>
          </h1>

          <p className="mt-3 text-xl font-semibold tracking-tight text-slate-700 sm:text-2xl dark:text-slate-200">
            {contactData.title}
          </p>

          {/* Short Professional Description */}
          <p className="mt-5 text-base leading-relaxed text-slate-600 sm:text-lg dark:text-slate-400">
            Software Developer dengan pengalaman membangun aplikasi mobile multiplatform menggunakan Flutter serta antarmuka web modern dengan React.js dan Next.js. Berpengalaman dalam integrasi RESTful API, arsitektur state management yang bersih, dan sistem ERP terpadu.
          </p>

          {/* Key Value Highlights */}
          <div className="mt-6 flex flex-wrap gap-y-2 gap-x-4 text-xs font-medium text-slate-600 dark:text-slate-300">
            <span className="flex items-center gap-1.5">
              <CheckCircle2 size={15} className="text-blue-600 dark:text-blue-400" />
              1 Tahun Pengalaman Kerja Profesional
            </span>
            <span className="flex items-center gap-1.5">
              <CheckCircle2 size={15} className="text-blue-600 dark:text-blue-400" />
              Produksi Mobile POS & Web ERP
            </span>
            <span className="flex items-center gap-1.5">
              <CheckCircle2 size={15} className="text-blue-600 dark:text-blue-400" />
              Clean Code & Scalable Architecture
            </span>
          </div>

          {/* Call to Actions */}
          <div className="mt-8 flex flex-wrap items-center gap-4">
            <a
              href="/cv/resume.pdf"
              download
              className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 active:scale-95"
            >
              <ArrowDownToLine size={17} />
              Download CV
            </a>

            <Link
              href="/contact"
              className="inline-flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 dark:hover:bg-slate-800"
            >
              Contact Me
              <ArrowRight size={16} />
            </Link>

            {/* Social Icons Quick Access */}
            <div className="flex items-center gap-2 pl-2">
              <a
                href={contactData.github}
                target="_blank"
                rel="noopener noreferrer"
                aria-label="GitHub profile"
                className="flex h-11 w-11 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition hover:bg-slate-100 hover:text-slate-900 dark:border-slate-800 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-white"
              >
                <GithubIcon size={20} />
              </a>

              <a
                href={contactData.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                aria-label="LinkedIn profile"
                className="flex h-11 w-11 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition hover:bg-slate-100 hover:text-blue-600 dark:border-slate-800 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-blue-400"
              >
                <LinkedinIcon size={20} />
              </a>

              <a
                href={`mailto:${contactData.email}`}
                aria-label="Send email"
                className="flex h-11 w-11 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition hover:bg-slate-100 hover:text-slate-900 dark:border-slate-800 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-white"
              >
                <Mail size={20} />
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
