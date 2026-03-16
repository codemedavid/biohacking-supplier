/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Cute Aesthetic Pink & Purple Theme
        'theme-bg': '#FDF8FF',           // Soft lavender white
        'theme-text': '#3D2B4A',         // Deep purple-brown

        // Primary - Soft Pink
        'blush': {
          DEFAULT: '#E8A0BF',
          50: '#FFF5FA',
          100: '#FFE8F3',
          200: '#FFCCE3',
          300: '#F5B5CF',
          400: '#E8A0BF',
          500: '#D4849E',
          600: '#C06B87',
          700: '#A85270',
          800: '#8A3D5A',
          900: '#6B2D44',
        },

        // Accent - Soft Purple / Lavender
        'glow-teal': {
          DEFAULT: '#B08DD4',
          50: '#F8F4FC',
          100: '#F0E8F8',
          200: '#E2D2F1',
          300: '#D3BBE9',
          400: '#C4A5E0',
          500: '#B08DD4',
          600: '#9A72C4',
          700: '#7E56AB',
          800: '#644490',
          900: '#4A3370',
        },

        // Secondary - Rose Gold
        'rose': {
          DEFAULT: '#D4A0B9',
          50: '#FDF6F9',
          100: '#FBEDF3',
          200: '#F5D5E3',
          300: '#EEBDD3',
          400: '#E4A5C3',
          500: '#D4A0B9',
          600: '#C07EA0',
          700: '#A85E84',
          800: '#8A4568',
          900: '#6B2F4E',
        },

        // Neutral - Warm plum tones
        'charcoal': {
          DEFAULT: '#3D2B4A',
          50: '#FDFCFE',
          100: '#F7F3F9',
          200: '#EDE6F2',
          300: '#DDD2E6',
          400: '#BBA8CC',
          500: '#9980AD',
          600: '#7A608F',
          700: '#5E4672',
          800: '#453357',
          900: '#332540',
        },

        // Backgrounds
        'cream': '#FDF8FF',
        'blush-light': '#FFF0F8',
        'warm-white': '#FEFBFF',
      },
      fontFamily: {
        sans: ['Poppins', 'sans-serif'],
        heading: ['Poppins', 'sans-serif'],
        serif: ['Poppins', 'sans-serif'],
      },
      boxShadow: {
        'sm': '0 1px 3px rgba(61, 43, 74, 0.04)',
        'DEFAULT': '0 2px 8px rgba(61, 43, 74, 0.06)',
        'md': '0 4px 12px rgba(61, 43, 74, 0.06)',
        'lg': '0 8px 24px rgba(61, 43, 74, 0.08)',
        'soft': '0 4px 16px rgba(232, 160, 191, 0.15)',
        'luxury': '0 8px 32px rgba(176, 141, 212, 0.18)',
      },
      borderRadius: {
        'none': '0',
        'sm': '0.375rem',
        'DEFAULT': '0.75rem',
        'md': '1rem',
        'lg': '1.25rem',
        'xl': '1.5rem',
        '2xl': '2rem',
        'full': '9999px',
      },
      animation: {
        'fadeIn': 'fadeIn 0.6s ease-out',
        'slideUp': 'slideUp 0.5s ease-out',
        'float': 'float 6s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        },
      },
    },
  },
  plugins: [],
}
