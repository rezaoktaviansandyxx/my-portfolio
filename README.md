# Personal Developer Portfolio - Indra Oki Sandy

Website personal portfolio profesional yang dibangun menggunakan Next.js (App Router), TypeScript, dan Tailwind CSS. Dirancang untuk kebutuhan melamar pekerjaan sebagai **Flutter Developer** & **Web Developer** serta menawarkan jasa freelance profesional.

---

## 🛠️ Tech Stack

- **Framework:** Next.js (App Router, Turbopack, React 19)
- **Language:** TypeScript
- **Styling:** Tailwind CSS (Corporate Minimalist Design System)
- **Icons:** Lucide React & Vector SVG Brand Icons
- **Theme:** Dual Theme Mode (Clean Light Mode sebagai default + Dark Mode switchable)
- **Deployment Platform:** Vercel

---

## 📁 Struktur Arsitektur Folder

```text
src/
├── app/
│   ├── layout.tsx                # Root layout, metadata, SEO & ThemeProvider
│   ├── page.tsx                  # Homepage utama (Hero, About, Skills, Featured Projects, Exp, Edu, Contact)
│   ├── globals.css               # Design system token & theme variables
│   ├── projects/
│   │   ├── page.tsx              # Halaman katalog seluruh proyek dengan filter kategori
│   │   └── [slug]/
│   │       └── page.tsx          # Dynamic route detail proyek & SSR/Static generation
│   └── contact/
│       └── page.tsx              # Halaman kontak profesional terpisah
│
├── components/
│   ├── layout/                   # Navbar (sticky & responsive drawer), Footer
│   ├── providers/                # ThemeProvider (Dark / Light mode state)
│   ├── sections/                 # HeroSection, AboutSection, SkillsSection, ExperienceSection, etc.
│   ├── projects/                 # ProjectCard
│   └── ui/                       # Icons (GithubIcon, LinkedinIcon, dll)
│
├── data/
│   ├── projects.ts               # Data 7 proyek faktual
│   ├── skills.ts                 # Kategori keahlian teknis nyata
│   ├── experience.ts             # Data pengalaman kerja & pendidikan
│   └── navigation.ts             # Navigasi & kontak terverifikasi
│
├── types/
│   └── index.ts                  # TypeScript interfaces (Project, Experience, Contact, dll)
│
└── lib/
    └── utils.ts                  # Utility helper (cn / clsx & twMerge)

public/
├── cv/
│   └── resume.pdf                # Lokasi file CV / Resume untuk tombol unduh
```

---

## 🚀 Cara Menjalankan Project Secara Lokal

1. **Clone repository (jika belum berada di repositori):**
   ```bash
   git clone https://github.com/rezaoktaviansandyxx/my-portfolio.git
   cd my-portfolio
   ```

2. **Install dependensi:**
   ```bash
   npm install
   ```

3. **Jalankan development server:**
   ```bash
   npm run dev
   ```
   Buka browser di [http://localhost:3000](http://localhost:3000).

4. **Menjalankan test build produksi:**
   ```bash
   npm run build
   npm run start
   ```

---

## 📄 Menambahkan File CV Anda

Untuk mengaktifkan fungsi tombol **Download CV**:
- Simpan file resume Anda dengan nama file: `resume.pdf`
- Letakkan di dalam direktori: `public/cv/resume.pdf`

---

## 🌐 Panduan Deployment ke Vercel

1. Push seluruh source code ke repository GitHub Anda (`github.com/rezaoktaviansandyxx/my-portfolio`).
2. Masuk ke [Vercel](https://vercel.com/) menggunakan akun GitHub Anda.
3. Klik tombol **Add New...** > **Project**.
4. Pilih repository `my-portfolio` dan klik **Import**.
5. Vercel secara otomatis mendeteksi konfigurasi:
   - **Framework Preset:** Next.js
   - **Build Command:** `next build`
   - **Output Directory:** `.next`
6. Klik tombol **Deploy**. Dalam hitungan detik website portfolio Anda sudah live di URL `*.vercel.app` atau domain kustom Anda.
