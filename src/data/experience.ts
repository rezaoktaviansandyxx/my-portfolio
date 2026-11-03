import { WorkExperience, Education } from "@/types";
import { Language } from "@/lib/i18n";

export interface LocalizedWorkExperience extends WorkExperience {
  periodEn?: string;
  locationEn?: string;
  typeEn?: string;
  descriptionEn?: string;
  responsibilitiesEn?: string[];
}

export const localizedExperienceData: LocalizedWorkExperience[] = [
  {
    company: "PT Thunder Labs Indonesia",
    position: "Frontend Developer",
    period: "November 2025 - Oktober 2026 (1 tahun)",
    periodEn: "November 2025 - October 2026 (1 year)",
    location: "Jawa Timur, Indonesia",
    locationEn: "East Java, Indonesia",
    type: "Contract / Professional",
    typeEn: "Contract / Professional",
    description: "Bekerja secara profesional dalam pengembangan antarmuka frontend aplikasi dan implementasi sistem digital yang responsif dan efisien.",
    descriptionEn: "Worked professionally in frontend application development and implementation of responsive, scalable, and efficient digital systems.",
    responsibilities: [
      "Mengembangkan dan mengoptimalkan antarmuka aplikasi dengan fokus pada performa, skalabilitas, dan clean code.",
      "Mengintegrasikan layanan REST API antara antarmuka pengguna dan backend sistem.",
      "Berkolaborasi dalam tim pengembang untuk memastikan pengalaman pengguna yang intuitif dan konsisten."
    ],
    responsibilitiesEn: [
      "Engineered and optimized application user interfaces with a strong focus on performance, scalability, and clean code.",
      "Integrated RESTful API services bridging frontend interfaces with backend enterprise services.",
      "Collaborated in engineering teams to deliver intuitive, seamless, and consistent user experiences."
    ]
  },
  {
    company: "PT Integrasi Data ERP (IDE)",
    position: "Flutter Developer",
    period: "Januari 2025 - April 2025 (4 bulan)",
    periodEn: "January 2025 - April 2025 (4 months)",
    location: "Indonesia",
    locationEn: "Indonesia",
    type: "Contract / Project",
    typeEn: "Contract / Project",
    description: "Mengembangkan aplikasi mobile berbasis Flutter yang terintegrasi dengan ekosistem enterprise resource planning (ERP).",
    descriptionEn: "Engineered Flutter mobile applications integrated directly with enterprise resource planning (ERP) ecosystems.",
    responsibilities: [
      "Mengimplementasikan arsitektur aplikasi mobile Flutter dengan state management yang modular.",
      "Menghubungkan modul aplikasi dengan backend ERP melalui protokol REST API.",
      "Memastikan keandalan alur transaksi dan data antarmuka sistem secara real-time."
    ],
    responsibilitiesEn: [
      "Implemented modular mobile architecture in Flutter with scalable state management patterns.",
      "Connected application client modules with ERP backends using REST API protocols.",
      "Ensured high reliability of transactional workflows and real-time interface data sync."
    ]
  },
  {
    company: "PT. ARSOFT SOLUSI TEKNOLOGI",
    position: "Programmer",
    period: "April 2024 - September 2024 (6 bulan)",
    periodEn: "April 2024 - September 2024 (6 months)",
    location: "Surabaya, Jawa Timur, Indonesia",
    locationEn: "Surabaya, East Java, Indonesia",
    type: "Contract / Professional",
    typeEn: "Contract / Professional",
    description: "Terlibat dalam siklus hidup pengembangan perangkat lunak, perancangan modul aplikasi, dan pemeliharaan sistem.",
    descriptionEn: "Participated in software development lifecycles, application module design, and continuous system maintenance.",
    responsibilities: [
      "Merancang dan membangun fitur-fitur aplikasi sesuai dengan spesifikasi kebutuhan pengguna.",
      "Melakukan debugging, pemeliharaan kode, serta optimalisasi alur kerja program.",
      "Bekerja sama dalam tim teknis untuk mencapai target sprint dan penyelesaian fitur."
    ],
    responsibilitiesEn: [
      "Designed and built application features based on user requirements and technical specifications.",
      "Conducted debugging, code maintenance, and program workflow optimizations.",
      "Worked collaboratively in technical teams to hit sprint milestones and feature deadlines."
    ]
  },
  {
    company: "Radya Labs Teknologi",
    position: "Associate Mobile Developer",
    period: "Januari 2023 - Juni 2023 (6 bulan)",
    periodEn: "January 2023 - June 2023 (6 months)",
    location: "Bandung, Jawa Barat, Indonesia",
    locationEn: "Bandung, West Java, Indonesia",
    type: "Internship / Associate",
    typeEn: "Internship / Associate",
    description: "Bekerja dalam tim mobile developer dengan menerapkan framework Flutter dan metodologi agile daily sprint.",
    descriptionEn: "Worked within the mobile engineering team utilizing Flutter and practicing agile daily sprint methodologies.",
    responsibilities: [
      "Mempelajari dan mendalami framework Flutter untuk kebutuhan pengembangan aplikasi mobile lintas platform.",
      "Bekerja dalam tim pengembang dengan mengikuti daily sprint dan proses agile harian.",
      "Mengimplementasikan komponen antarmuka pengguna serta menyelesaikan task sesuai arahan tim senior."
    ],
    responsibilitiesEn: [
      "Deep-dived into Flutter framework for cross-platform mobile application development.",
      "Participated actively in daily standups, sprints, and agile team workflows.",
      "Implemented user interface components and delivered technical tasks under senior engineer guidance."
    ]
  },
  {
    company: "Seven Inc.",
    position: "Programmer (Internship BS CI)",
    period: "Juli 2021 - Oktober 2021 (4 bulan)",
    periodEn: "July 2021 - October 2021 (4 months)",
    location: "Bantul, D.I. Yogyakarta",
    locationEn: "Bantul, D.I. Yogyakarta, Indonesia",
    type: "Internship",
    typeEn: "Internship",
    description: "Magang pemrograman (BS CI) berfokus pada pengembangan aplikasi web menggunakan framework Laravel bersama tim pengembang.",
    descriptionEn: "Programming internship (BS CI) focusing on web application development with the Laravel framework alongside the engineering team.",
    responsibilities: [
      "Mempelajari dan mengimplementasikan fitur backend dan web berbasis framework Laravel (PHP).",
      "Berkolaborasi dalam tim proyek, pembagian tugas (task sharing), dan version control.",
      "Menyelesaikan implementasi modul program sesuai spesifikasi tugas yang diberikan."
    ],
    responsibilitiesEn: [
      "Learned and implemented backend and web features utilizing the Laravel (PHP) framework.",
      "Collaborated in project teams, code reviews, and Git version control workflows.",
      "Completed program module implementations according to provided task specifications."
    ]
  }
];

export const experienceData: WorkExperience[] = localizedExperienceData;

export const educationData: Education[] = [
  {
    institution: "CODE.ID",
    degree: "Bootcamp Intensive",
    degreeEn: "Intensive Bootcamp",
    major: "Flutter Mobile Developer",
    majorEn: "Flutter Mobile Developer",
    graduationYear: "2023"
  },
  {
    institution: "STMIK PPKIA Pradnya Paramita Malang",
    degree: "Associate's Degree (D3)",
    degreeEn: "Associate Degree (D3)",
    major: "Manajemen Sistem Informasi",
    majorEn: "Information Systems Management",
    graduationYear: "2019 - 2022"
  }
];
