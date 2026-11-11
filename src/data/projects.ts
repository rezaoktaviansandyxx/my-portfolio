import { Project } from "@/types";

export const projectsData: Project[] = [
  {
    slug: "balimurni-pos",
    title: "Balimurni POS",
    shortDescription: "Sistem Point of Sale (POS) berbasis Flutter untuk terminal kasir (seperti perangkat iMin) dan desktop yang terintegrasi dengan ERPNext via REST API.",
    shortDescriptionEn: "Flutter-based Point of Sale (POS) system for cashier terminals (such as iMin devices) and desktop workstations integrated with ERPNext via REST API.",
    technologies: ["Flutter", "Dart", "Provider", "REST API", "ERPNext"],
    role: "Frontend Developer",
    roleEn: "Frontend Developer",
    category: "POS & Desktop",
    categoryEn: "POS & Desktop",
    featured: true,
    overview: "Aplikasi Point of Sale (POS) yang dirancang khusus untuk operasional kasir pada terminal desktop dan perangkat POS (seperti iMin). Aplikasi ini memperlancar proses transaksi ritel harian, pencetakan struk kasir, manajemen item, dan sinkronisasi data transaksi secara real-time ke sistem backend ERPNext.",
    overviewEn: "Point of Sale (POS) application designed specifically for cashier workflows on desktop terminals and dedicated POS hardware (such as iMin). It streamlines daily retail operations, thermal receipt printing, item catalogue management, and real-time transaction synchronization with ERPNext backend services.",
    challenge: "Alur kasir perlu berjalan pada terminal POS dan desktop, sambil menjaga katalog, stok, dan transaksi tetap terhubung ke ERPNext.",
    challengeEn: "Cashier workflows needed to run across POS terminals and desktop workstations while keeping catalogues, stock, and transactions connected to ERPNext.",
    solution: "Membangun antarmuka Flutter dengan state management Provider, integrasi REST API ERPNext, serta dukungan alur pencetakan struk.",
    solutionEn: "Built Flutter interfaces with Provider state management, ERPNext REST API integration, and receipt printing workflows.",
    outcome: "Cakupan fitur yang terdokumentasi meliputi alur kasir, katalog item, sinkronisasi transaksi, dan pencetakan struk.",
    outcomeEn: "Documented feature coverage includes cashier workflows, item catalogues, transaction synchronization, and receipt printing.",
    responsibilities: [
      "Mengembangkan antarmuka pengguna (UI) sistem kasir POS menggunakan Flutter & Dart untuk perangkat terminal POS dan desktop.",
      "Menerapkan state management menggunakan Provider untuk pengelolaan alur transaksi kasir yang cepat dan responsif.",
      "Mengintegrasikan REST API dengan sistem ERPNext untuk sinkronisasi katalog produk, stok, dan pencatatan riwayat transaksi.",
      "Mengoptimalkan stabilitas dan performa aplikasi untuk kebutuhan transaksi kasir berfrekuensi tinggi."
    ],
    responsibilitiesEn: [
      "Engineered cashier POS user interfaces using Flutter & Dart for POS terminal hardware and desktop environments.",
      "Implemented state management using Provider for fast, reliable, and responsive transactional workflows.",
      "Integrated RESTful APIs with ERPNext to synchronize product catalogues, stock availability, and transaction logging.",
      "Optimized application stability and rendering performance for high-frequency checkout operations."
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
    shortDescriptionEn: "Responsive web application built using Flutter Web with GoRouter modular navigation and ERPNext backend integration.",
    technologies: ["Flutter Web", "Provider", "GoRouter", "REST API", "ERPNext"],
    role: "Frontend Developer",
    roleEn: "Frontend Developer",
    category: "Frontend",
    categoryEn: "Frontend",
    featured: true,
    overview: "Platform web yang dibangun menggunakan teknologi Flutter Web untuk kebutuhan presentasi layanan dan integrasi data bisnis Balimurni dengan sistem manajemen ERPNext.",
    overviewEn: "Web platform built using Flutter Web to showcase service offerings and connect commercial business data with the ERPNext management ecosystem.",
    challenge: "Situs perlu menyajikan konten dan alur belanja sekaligus menggunakan data bisnis yang terhubung ke ERPNext.",
    challengeEn: "The site needed to present business content and shopping flows while using business data connected to ERPNext.",
    solution: "Menyusun navigasi modular dengan GoRouter, mengelola state menggunakan Provider, dan menghubungkan antarmuka ke REST API ERPNext.",
    solutionEn: "Structured modular navigation with GoRouter, managed state with Provider, and connected the interface to ERPNext REST APIs.",
    outcome: "Galeri mendokumentasikan halaman beranda, produk, checkout, detail pesanan, dan kupon.",
    outcomeEn: "The gallery documents the home, products, checkout, order detail, and coupon screens.",
    responsibilities: [
      "Membangun antarmuka web yang terstruktur dan interaktif menggunakan Flutter Web.",
      "Mengatur arsitektur navigasi dan routing modular menggunakan GoRouter.",
      "Mengelola status data aplikasi menggunakan Provider.",
      "Menghubungkan layanan antarmuka dengan REST API backend ERPNext."
    ],
    responsibilitiesEn: [
      "Built clean, interactive web interfaces using Flutter Web.",
      "Structured modular routing and navigation architecture using GoRouter.",
      "Managed client application state reliably using Provider.",
      "Connected interface data services with ERPNext backend REST APIs."
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
    shortDescriptionEn: "Modern React.js Content Management System (CMS) for e-commerce product management and catalogue administration.",
    technologies: ["React.js"],
    role: "Frontend Developer",
    roleEn: "Frontend Developer",
    category: "Frontend",
    categoryEn: "Frontend",
    featured: false,
    overview: "Aplikasi web dashboard CMS untuk memfasilitasi administrasi konten produk, pembaruan katalog, dan monitoring inventaris StylishShop.",
    overviewEn: "CMS dashboard web application designed to facilitate product content management, catalogue updates, and inventory tracking for StylishShop.",
    challenge: "Administrasi katalog dan pesanan membutuhkan tampilan dashboard yang memudahkan pengelolaan data operasional.",
    challengeEn: "Catalogue and order administration called for a dashboard interface suited to operational data management.",
    solution: "Membangun komponen dashboard React.js untuk ringkasan, produk, pesanan, dan login; detail backend tidak tercantum pada dokumentasi proyek.",
    solutionEn: "Built React.js dashboard components for overview, products, orders, and login; backend details are not documented for this project.",
    outcome: "Screenshot yang tersedia menunjukkan halaman dashboard, produk, pesanan, dan login.",
    outcomeEn: "Available screenshots show the dashboard, products, orders, and login screens.",
    responsibilities: [
      "Merancang dan mengimplementasikan komponen antarmuka dasbor menggunakan React.js.",
      "Menyusun tata kelola komponen yang reusable dan terstruktur untuk form dan tabel data.",
      "Memastikan tampilan antarmuka ramah pengguna (clean UX) untuk kebutuhan admin."
    ],
    responsibilitiesEn: [
      "Designed and implemented dashboard UI components using React.js.",
      "Structured modular and reusable component architectures for data forms and tables.",
      "Ensured intuitive, clean user experiences tailored for operational administration."
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
    shortDescriptionEn: "Full-stack product management system combining a React.js frontend with Laravel (PHP) RESTful APIs.",
    technologies: ["React.js", "Laravel", "PHP"],
    role: "Fullstack Developer",
    roleEn: "Fullstack Developer",
    category: "Personal Project",
    categoryEn: "Personal Project",
    featured: false,
    overview: "Solusi end-to-end untuk manajemen inventaris dan produk bisnis, menggabungkan kemudahan antarmuka React.js dengan ketangguhan backend Laravel.",
    overviewEn: "End-to-end solution for business inventory and catalogue management, bridging responsive React.js client interfaces with robust Laravel backends.",
    challenge: "Proyek ini mengeksplorasi alur pengelolaan produk melalui aplikasi web dengan frontend dan API backend.",
    challengeEn: "This project explores product management workflows through a web application with a frontend and backend API.",
    solution: "Menghubungkan antarmuka React.js dengan REST API Laravel serta alur validasi data.",
    solutionEn: "Connected a React.js interface to Laravel REST APIs and data validation workflows.",
    outcome: "Screenshot yang tersedia mencakup landing page, dashboard, daftar produk, dan formulir tambah produk.",
    outcomeEn: "Available screenshots cover a landing page, dashboard, product list, and add-product form.",
    responsibilities: [
      "Mengembangkan arsitektur backend RESTful API menggunakan Laravel (PHP).",
      "Membangun antarmuka pengguna interaktif menggunakan React.js untuk manajemen data produk.",
      "Mengimplementasikan alur validasi data dan integrasi client-server yang efisien."
    ],
    responsibilitiesEn: [
      "Developed scalable RESTful API backend architecture using Laravel (PHP).",
      "Built interactive user interfaces with React.js for product cataloguing and stock actions.",
      "Implemented reliable data validation workflows and efficient client-server interactions."
    ],
    image: "/images/projects/product-management-system/pms-landing.jpg",
    gallery: [
      "/images/projects/product-management-system/pms-landing.jpg",
      "/images/projects/product-management-system/pms-dashboard.jpg",
      "/images/projects/product-management-system/pms-products.jpg",
      "/images/projects/product-management-system/pms-add-product.jpg"
    ]
  },
  {
    slug: "stylishshop-mobile",
    title: "StylishShop Mobile",
    shortDescription: "Aplikasi e-commerce mobile yang dibangun dengan Flutter untuk pengalaman belanja yang intuitif.",
    shortDescriptionEn: "Flutter mobile e-commerce application crafted for seamless, intuitive shopping experiences.",
    technologies: ["Flutter"],
    role: "Frontend Developer",
    roleEn: "Frontend Developer",
    category: "Mobile",
    categoryEn: "Mobile",
    featured: true,
    overview: "Aplikasi e-commerce berbasis Flutter yang dirancang untuk memberikan pengalaman navigasi katalog belanja yang lancar di perangkat mobile.",
    overviewEn: "Mobile e-commerce application engineered with Flutter to deliver smooth catalogue browsing, cart management, and seamless mobile interactions.",
    challenge: "Aplikasi perlu menyajikan penelusuran katalog dan keranjang dalam alur yang sesuai untuk layar mobile.",
    challengeEn: "The application needed to present catalogue browsing and cart flows suited to mobile screens.",
    solution: "Membangun antarmuka Flutter untuk onboarding, kategori, katalog produk, keranjang, dan login.",
    solutionEn: "Built Flutter interfaces for onboarding, categories, product browsing, cart, and login.",
    outcome: "Galeri mendokumentasikan enam layar utama dari splash/onboarding hingga keranjang dan login.",
    outcomeEn: "The gallery documents six key screens from splash/onboarding through cart and login.",
    responsibilities: [
      "Membangun antarmuka pengguna mobile katalog belanja menggunakan Flutter.",
      "Menyusun alur navigasi aplikasi yang responsif dan nyaman digunakan.",
      "Menerapkan tata letak visual produk yang bersih dan modern."
    ],
    responsibilitiesEn: [
      "Built responsive shopping catalogue mobile interfaces with Flutter.",
      "Structured smooth application transitions and user-friendly mobile navigation.",
      "Implemented clean, modern product presentation layouts."
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
    shortDescriptionEn: "Interactive company profile application engineered with Flutter showcasing Brewlink's brand identity.",
    technologies: ["Flutter"],
    role: "Frontend Developer",
    roleEn: "Frontend Developer",
    category: "Frontend",
    categoryEn: "Frontend",
    featured: true,
    overview: "Aplikasi profil perusahaan yang menampilkan portofolio produk, nilai brand, dan informasi kontak bisnis Brewlink.",
    overviewEn: "Corporate profile application presenting product portfolios, core brand narratives, and commercial contact channels for Brewlink.",
    challenge: "Informasi brand, cerita perusahaan, outlet, dan kontak perlu disajikan dalam satu pengalaman profil yang konsisten.",
    challengeEn: "Brand information, company story, outlets, and contact details needed a consistent company-profile experience.",
    solution: "Membangun tampilan profil perusahaan berbasis Flutter dengan halaman brand, cerita, outlet, dan kontak.",
    solutionEn: "Built a Flutter company-profile interface with brand, story, outlet, and contact pages.",
    outcome: "Screenshot yang tersedia menunjukkan halaman utama, cerita, outlet, dan kontak.",
    outcomeEn: "Available screenshots show the home, story, outlet, and contact screens.",
    responsibilities: [
      "Mengembangkan antarmuka aplikasi profil perusahaan dengan Flutter.",
      "Menyusun tata letak visual branding yang elegan dan profesional.",
      "Memastikan performa render tampilan mulus di berbagai ukuran layar."
    ],
    responsibilitiesEn: [
      "Developed company profile mobile & web interfaces using Flutter.",
      "Architected elegant, professional brand presentation layouts.",
      "Ensured fluid rendering performance across diverse screen resolutions."
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
    shortDescriptionEn: "Stock and inventory management ERP system built with Angular, FastAPI, and PostgreSQL.",
    technologies: ["Angular", "FastAPI", "PostgreSQL"],
    role: "Personal Project",
    roleEn: "Personal Project",
    category: "Personal Project",
    categoryEn: "Personal Project",
    featured: false,
    overview: "Proyek sistem Enterprise Resource Planning (ERP) berfokus pada manajemen stok terpadu, dirancang dengan arsitektur backend modern FastAPI yang berkecepatan tinggi dan database PostgreSQL.",
    overviewEn: "Enterprise Resource Planning (ERP) project focused on integrated stock operations, engineered with high-performance FastAPI backend services and PostgreSQL relational database architecture.",
    challenge: "Proyek personal ini sedang dikembangkan untuk mengeksplorasi pengelolaan stok dengan frontend Angular dan backend FastAPI.",
    challengeEn: "This personal project is in development and explores stock management with an Angular frontend and FastAPI backend.",
    solution: "Rancangan teknologi yang tercatat menggunakan Angular, FastAPI, dan PostgreSQL.",
    solutionEn: "The documented technology choices are Angular, FastAPI, and PostgreSQL.",
    outcome: "Status saat ini: proyek personal dalam pengembangan; hasil akhir belum dicatat.",
    outcomeEn: "Current status: personal project in development; final outcomes have not been documented.",
    responsibilities: [
      "Merancang skema database relasional menggunakan PostgreSQL.",
      "Membangun service API backend berkinerja tinggi menggunakan FastAPI (Python).",
      "Mengembangkan modul antarmuka pengguna berbasis Angular."
    ],
    responsibilitiesEn: [
      "Designed relational database schemas and queries using PostgreSQL.",
      "Built high-performance REST APIs using FastAPI (Python).",
      "Engineered frontend client management interfaces with Angular."
    ]
  }
];
