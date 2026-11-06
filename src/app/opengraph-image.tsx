import { ImageResponse } from "next/og";

export const alt = "Indra Oki Sandy - Flutter & Web Developer";
export const size = {
  width: 1200,
  height: 630,
};
export const contentType = "image/png";

export default async function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          height: "100%",
          width: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "60px 80px",
          backgroundColor: "#090d16",
          backgroundImage:
            "radial-gradient(circle at 10% 20%, rgba(37, 99, 235, 0.15) 0%, transparent 40%), radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.15) 0%, transparent 40%)",
          color: "white",
          fontFamily: "sans-serif",
        }}
      >
        {/* Top bar / status */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "12px",
            }}
          >
            <div
              style={{
                width: "14px",
                height: "14px",
                borderRadius: "50%",
                backgroundColor: "#22c55e",
              }}
            />
            <span
              style={{
                fontSize: "20px",
                fontWeight: 600,
                color: "#94a3b8",
                letterSpacing: "0.05em",
                textTransform: "uppercase",
              }}
            >
              Open for Opportunities
            </span>
          </div>
          <div
            style={{
              fontSize: "20px",
              fontWeight: 500,
              color: "#64748b",
            }}
          >
            indraokisandy.my.id
          </div>
        </div>

        {/* Center content */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            gap: "20px",
          }}
        >
          <div
            style={{
              fontSize: "64px",
              fontWeight: 800,
              letterSpacing: "-0.03em",
              lineHeight: 1.1,
              color: "#ffffff",
            }}
          >
            Indra Oki Sandy
          </div>
          <div
            style={{
              fontSize: "32px",
              fontWeight: 600,
              background: "linear-gradient(to right, #60a5fa, #a78bfa)",
              backgroundClip: "text",
              WebkitBackgroundClip: "text",
              color: "transparent",
            }}
          >
            Flutter Developer &amp; Web Developer
          </div>
          <div
            style={{
              fontSize: "22px",
              color: "#94a3b8",
              maxWidth: "850px",
              lineHeight: 1.5,
            }}
          >
            Membangun aplikasi mobile &amp; web modern yang terintegrasi dengan REST API dan sistem ERP.
          </div>
        </div>

        {/* Tech tags footer */}
        <div
          style={{
            display: "flex",
            gap: "14px",
            flexWrap: "wrap",
          }}
        >
          {["Flutter", "Dart", "Next.js", "React", "REST API", "ERPNext"].map(
            (tech) => (
              <div
                key={tech}
                style={{
                  padding: "10px 22px",
                  borderRadius: "9999px",
                  backgroundColor: "rgba(255, 255, 255, 0.06)",
                  border: "1px solid rgba(255, 255, 255, 0.12)",
                  color: "#e2e8f0",
                  fontSize: "18px",
                  fontWeight: 500,
                }}
              >
                {tech}
              </div>
            )
          )}
        </div>
      </div>
    ),
    {
      ...size,
    }
  );
}
