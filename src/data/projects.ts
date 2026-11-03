import { Project } from "@/types";

export const projectsData: Project[] = [
  {
    slug: "balimurni-pos",
    title: "Balimurni POS",
    shortDescription: "Sistem Point of Sale (POS) berbasis Flutter untuk terminal kasir (seperti perangkat iMin) dan desktop yang terintegrasi dengan ERPNext via REST API.",
    technologies: ["Flutter", "Dart", "Provider", "REST API", "ERPNext"],
    role: "Frontend Developer",
    category: "POS & Desktop",
    featured: true,
    overview: "Aplikasi Point of Sale (POS) yang dirancang khusus untuk operasional kasir pada terminal desktop dan perangkat POS (seperti iMin). Aplikasi ini memperlancar proses transaksi ritel harian, pencetakan struk kasir, manajemen item, dan sinkronisasi data transaksi secara real-time ke sistem backend ERPNext.",
    responsibilities: [
      "Mengembangkan antarmuka pengguna (UI) sistem kasir POS menggunakan Flutter & Dart untuk perangkat terminal POS dan desktop.",
      "Menerapkan state management menggunakan Provider untuk pengelolaan alur transaksi kasir yang cepat dan responsif.",
      "Mengintegrasikan REST API dengan sistem ERPNext untuk sinkronisasi katalog produk, stok, dan pencatatan riwayat transaksi.",
      "Mengoptimalkan stabilitas dan performa aplikasi untuk kebutuhan transaksi kasir berfrekuensi tinggi."
    ],
    image: "/images/projects/balimurni-pos/balimurni-pos-login.jpg",
    gallery: [
      "/images/projects/balimurni-pos/balimurni-pos-login.jpg",
      "/images/projects/balimurni-pos/balimurni-pos-profile.jpg",
      "/images/projects/balimurni-pos/balimurni-pos-printer.jpg"
    ]
  },
  {
    slug: "website-balimurni",
    title: "Website Balimurni",
    shortDescription: "Aplikasi web responsif yang dibangun menggunakan Flutter Web dengan integrasi GoRouter dan ERPNext backend.",
    technologies: ["Flutter Web", "Provider", "GoRouter", "REST API", "ERPNext"],
    role: "Frontend Developer",
    category: "Frontend",
    featured: true,
    overview: "Platform web yang dibangun menggunakan teknologi Flutter Web untuk kebutuhan presentasi layanan dan integrasi data bisnis Balimurni dengan sistem manajemen ERPNext.",
    responsibilities: [
      "Membangun antarmuka web yang terstruktur dan interaktif menggunakan Flutter Web.",
      "Mengatur arsitektur navigasi dan routing modular menggunakan GoRouter.",
      "Mengelola status data aplikasi menggunakan Provider.",
      "Menghubungkan layanan antarmuka dengan REST API backend ERPNext."
    ],
    image: "/images/projects/website-balimurni/website-balimurni-home.jpg",
    gallery: [
      "/images/projects/website-balimurni/website-balimurni-home.jpg",
      "/images/projects/website-balimurni/website-balimurni-products.jpg",
      "/images/projects/website-balimurni/website-balimurni-checkout.jpg",
      "/images/projects/website-balimurni/website-balimurni-order-detail.jpg",
      "/images/projects/website-balimurni/website-balimurni-coupon.jpg"
    ]
  },
  {
    slug: "stylishshop-cms",
    title: "StylishShop CMS",
    shortDescription: "Sistem Content Management System (CMS) modern berbasis React.js untuk manajemen produk dan katalog e-commerce.",
    technologies: ["React.js"],
    role: "Frontend Developer",
    category: "Frontend",
    featured: false,
    overview: "Aplikasi web dashboard CMS untuk memfasilitasi administrasi konten produk, pembaruan katalog, dan monitoring inventaris StylishShop.",
    responsibilities: [
      "Merancang dan mengimplementasikan komponen antarmuka dasbor menggunakan React.js.",
      "Menyusun tata kelola komponen yang reusable dan terstruktur untuk form dan tabel data.",
      "Memastikan tampilan antarmuka ramah pengguna (clean UX) untuk kebutuhan admin."
    ],
    image: "/images/projects/stylishshop-cms/stylishshop-cms-dashboard.jpg",
    gallery: [
      "/images/projects/stylishshop-cms/stylishshop-cms-dashboard.jpg",
      "/images/projects/stylishshop-cms/stylishshop-cms-products.jpg",
      "/images/projects/stylishshop-cms/stylishshop-cms-orders.jpg",
      "/images/projects/stylishshop-cms/stylishshop-cms-login.jpg"
    ]
  },
  {
    slug: "product-management-system",
    title: "Product Management System",
    shortDescription: "Aplikasi manajemen produk fullstack dengan frontend React.js dan backend API Laravel (PHP).",
    technologies: ["React.js", "Laravel", "PHP"],
    role: "Fullstack Developer",
    category: "Personal Project",
    featured: false,
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
    category: "Mobile",
    featured: true,
    overview: "Aplikasi e-commerce berbasis Flutter yang dirancang untuk memberikan pengalaman navigasi katalog belanja yang lancar di perangkat mobile.",
    responsibilities: [
      "Membangun antarmuka pengguna mobile katalog belanja menggunakan Flutter.",
      "Menyusun alur navigasi aplikasi yang responsif dan nyaman digunakan.",
      "Menerapkan tata letak visual produk yang bersih dan modern."
    ],
    image: "/images/projects/stylishshop-mobile/stylishshop-mobile-home.jpg",
    gallery: [
      "/images/projects/stylishshop-mobile/stylishshop-mobile-splash.jpg",
      "/images/projects/stylishshop-mobile/stylishshop-mobile-onboarding.jpg",
      "/images/projects/stylishshop-mobile/stylishshop-mobile-home.jpg",
      "/images/projects/stylishshop-mobile/stylishshop-mobile-categories.jpg",
      "/images/projects/stylishshop-mobile/stylishshop-mobile-cart.jpg",
      "/images/projects/stylishshop-mobile/stylishshop-mobile-login.jpg"
    ]
  },
  {
    slug: "brewlink-company-profile",
    title: "Brewlink Company Profile",
    shortDescription: "Aplikasi company profile interaktif berbasis Flutter untuk representasi identitas brand Brewlink.",
    technologies: ["Flutter"],
    role: "Frontend Developer",
    category: "Frontend",
    featured: true,
    overview: "Aplikasi profil perusahaan yang menampilkan portofolio produk, nilai brand, dan informasi kontak bisnis Brewlink.",
    responsibilities: [
      "Mengembangkan antarmuka aplikasi profil perusahaan dengan Flutter.",
      "Menyusun tata letak visual branding yang elegan dan profesional.",
      "Memastikan performa render tampilan mulus di berbagai ukuran layar."
    ],
    image: "/images/projects/brewlink/brewlink-hero.jpg",
    gallery: [
      "/images/projects/brewlink/brewlink-hero.jpg",
      "/images/projects/brewlink/brewlink-story.jpg",
      "/images/projects/brewlink/brewlink-outlet.jpg",
      "/images/projects/brewlink/brewlink-contact.jpg"
    ]
  },
  {
    slug: "stocksaku-erp",
    title: "StockSaku ERP",
    shortDescription: "Sistem ERP manajemen stok yang dirancang menggunakan Angular, FastAPI, dan PostgreSQL.",
    technologies: ["Angular", "FastAPI", "PostgreSQL"],
    role: "Personal Project",
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
