import { Project } from "@/types";

export const projectsData: Project[] = [
  {
    slug: "balimurni-pos",
    title: "Balimurni POS",
    shortDescription: "Sistem Point of Sale (POS) berbasis Flutter untuk operasional transaksi ritel yang terintegrasi dengan ERPNext via REST API.",
    technologies: ["Flutter", "Dart", "Provider", "REST API", "ERPNext"],
    role: "Frontend Developer",
    status: "Completed",
    category: "Mobile",
    featured: true,
    overview: "Aplikasi POS (Point of Sale) mobile yang dikembangkan untuk memperlancar proses transaksi harian, pengelolaan item, dan sinkronisasi data penjualan langsung ke sistem backend ERPNext.",
    responsibilities: [
      "Mengembangkan antarmuka pengguna (UI) mobile POS menggunakan Flutter & Dart.",
      "Menerapkan state management menggunakan Provider untuk pengelolaan state transaksi yang responsif.",
      "Mengintegrasikan REST API dengan sistem ERPNext untuk sinkronisasi data produk, stok, dan pencatatan transaksi.",
      "Memastikan kinerja aplikasi stabil dan konsisten pada alur transaksi kasir."
    ]
  },
  {
    slug: "website-balimurni",
    title: "Website Balimurni",
    shortDescription: "Aplikasi web responsif yang dibangun menggunakan Flutter Web dengan integrasi GoRouter dan ERPNext backend.",
    technologies: ["Flutter Web", "Provider", "GoRouter", "REST API", "ERPNext"],
    role: "Frontend Developer",
    status: "Completed",
    category: "Frontend",
    featured: true,
    overview: "Platform web yang dibangun menggunakan teknologi Flutter Web untuk kebutuhan presentasi layanan dan integrasi data bisnis Balimurni dengan sistem manajemen ERPNext.",
    responsibilities: [
      "Membangun antarmuka web yang terstruktur dan interaktif menggunakan Flutter Web.",
      "Mengatur arsitektur navigasi dan routing modular menggunakan GoRouter.",
      "Mengelola status data aplikasi menggunakan Provider.",
      "Menghubungkan layanan antarmuka dengan REST API backend ERPNext."
    ]
  },
  {
    slug: "stylishshop-cms",
    title: "StylishShop CMS",
    shortDescription: "Sistem Content Management System (CMS) modern berbasis React.js untuk manajemen produk dan katalog e-commerce.",
    technologies: ["React.js"],
    role: "Frontend Developer",
    status: "Completed",
    category: "Frontend",
    featured: true,
    overview: "Aplikasi web dashboard CMS untuk memfasilitasi administrasi konten produk, pembaruan katalog, dan monitoring inventaris StylishShop.",
    responsibilities: [
      "Merancang dan mengimplementasikan komponen antarmuka dasbor menggunakan React.js.",
      "Menyusun tata kelola komponen yang reusable dan terstruktur untuk form dan tabel data.",
      "Memastikan tampilan antarmuka ramah pengguna (clean UX) untuk kebutuhan admin."
    ]
  },
  {
    slug: "product-management-system",
    title: "Product Management System",
    shortDescription: "Aplikasi manajemen produk fullstack dengan frontend React.js dan backend API Laravel (PHP).",
    technologies: ["React.js", "Laravel", "PHP"],
    role: "Fullstack Developer",
    status: "Completed",
    category: "Fullstack",
    featured: true,
    overview: "Solusi end-to-end untuk manajemen inventaris dan produk bisnis, menggabungkan kemudahan antarmuka React.js dengan ketangguhan backend Laravel.",
    responsibilities: [
      "Mengembangkan arsitektur backend RESTful API menggunakan Laravel (PHP).",
      "Membangun antarmuka pengguna interaktif menggunakan React.js untuk manajemen data produk.",
      "Mengimplementasikan alur validasi data dan integrasi client-server yang efisien."
    ]
  },
  {
    slug: "stylishshop-mobile",
    title: "StylishShop Mobile",
    shortDescription: "Aplikasi e-commerce mobile yang dibangun dengan Flutter untuk pengalaman belanja yang intuitif.",
    technologies: ["Flutter"],
    role: "Frontend Developer",
    status: "Completed",
    category: "Mobile",
    featured: false,
    overview: "Aplikasi e-commerce berbasis Flutter yang dirancang untuk memberikan pengalaman navigasi katalog belanja yang lancar di perangkat mobile.",
    responsibilities: [
      "Membangun antarmuka pengguna mobile katalog belanja menggunakan Flutter.",
      "Menyusun alur navigasi aplikasi yang responsif dan nyaman digunakan.",
      "Menerapkan tata letak visual produk yang bersih dan modern."
    ]
  },
  {
    slug: "brewlink-company-profile",
    title: "Brewlink Company Profile",
    shortDescription: "Aplikasi company profile interaktif berbasis Flutter untuk representasi identitas brand Brewlink.",
    technologies: ["Flutter"],
    role: "Frontend Developer",
    status: "Completed",
    category: "Mobile",
    featured: false,
    overview: "Aplikasi profil perusahaan yang menampilkan portofolio produk, nilai brand, dan informasi kontak bisnis Brewlink.",
    responsibilities: [
      "Mengembangkan antarmuka aplikasi profil perusahaan dengan Flutter.",
      "Menyusun tata letak visual branding yang elegan dan profesional.",
      "Memastikan performa render tampilan mulus di berbagai ukuran layar."
    ]
  },
  {
    slug: "stocksaku-erp",
    title: "StockSaku ERP",
    shortDescription: "Sistem ERP manajemen stok dalam tahap pengembangan yang dibangun menggunakan Angular, FastAPI, dan PostgreSQL.",
    technologies: ["Angular", "FastAPI", "PostgreSQL"],
    role: "Personal Project",
    status: "In Development",
    category: "Personal Project",
    featured: false,
    overview: "Proyek sistem Enterprise Resource Planning (ERP) berfokus pada manajemen stok terpadu, dirancang dengan arsitektur backend modern FastAPI yang berkecepatan tinggi dan database PostgreSQL.",
    responsibilities: [
      "Merancang skema database relasional menggunakan PostgreSQL.",
      "Membangun service API backend berkinerja tinggi menggunakan FastAPI (Python).",
      "Mengembangkan modul antarmuka pengguna berbasis Angular."
    ]
  }
];
