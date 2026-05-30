module.exports = {
    content: [
        "./*.html",
        "./script.js"
    ],
    theme: {
        extend: {
            colors: {
                nebula: "#090d22",
                deepspace: "#11172d",
                stardust: "#16213e",
                cosmic: "#0f3460",
                neonblue: "#35d8ff",
                neonpurple: "#b678ff",
                neonpink: "#ff5cc8",
                cyanglow: "#42ffe0",
                goldstardust: "#ffd166"
            },
            fontFamily: {
                cyber: ["Orbitron", "Rajdhani", "Microsoft YaHei", "system-ui", "sans-serif"]
            },
            animation: {
                "pulse-slow": "pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite",
                "float": "float 7s ease-in-out infinite",
                "glow": "glow 2.6s ease-in-out infinite alternate"
            }
        }
    }
};
