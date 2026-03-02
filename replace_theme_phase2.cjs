const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, 'src');

const replacements = [
    // Page Backgrounds
    { search: /bg-gradient-to-br from-white via-gold-50\/10 to-white/g, replace: 'bg-theme-bg' },
    { search: /bg-gradient-to-br from-sky-50 via-blue-50 to-cyan-50/g, replace: 'bg-theme-bg' },
    { search: /bg-gradient-to-r from-sky-100 to-blue-100/g, replace: 'bg-charcoal-900/40 backdrop-blur-md border-b border-charcoal-700/50' },
    { search: /bg-gradient-to-r from-sky-50 to-blue-50/g, replace: 'bg-charcoal-900/40' },
    { search: /from-sky-100 to-blue-100/g, replace: 'from-charcoal-800 to-charcoal-900' },
    { search: /bg-gradient-to-br from-\[#FADADD\] via-\[#FDF5F7\] to-white/g, replace: 'bg-theme-bg' },

    // Text colors
    { search: /text-navy-900/g, replace: 'text-white' },
    { search: /text-black/g, replace: 'text-white' },
    { search: /text-charcoal-100/g, replace: 'text-white' },
    { search: /text-sky-500/g, replace: 'text-glow-teal-400' },
    { search: /text-sky-600/g, replace: 'text-glow-teal-400' },
    { search: /text-sky-700/g, replace: 'text-glow-teal-300' },
    { search: /from-sky-500 to-blue-600/g, replace: 'from-glow-teal-400 to-blush-500' },

    // Backgrounds / Borders
    { search: /bg-navy-900/g, replace: 'bg-charcoal-800' },
    { search: /bg-navy-50/g, replace: 'bg-charcoal-800/40' },
    { search: /border-navy-900\/30/g, replace: 'border-charcoal-700/50' },
    { search: /border-navy-900/g, replace: 'border-charcoal-700/50' },
    { search: /border-sky-100/g, replace: 'border-charcoal-700/50' },
    { search: /border-sky-200/g, replace: 'border-charcoal-700/50' },
    { search: /border-sky-300/g, replace: 'border-charcoal-600/50' },
    { search: /bg-sky-50 /g, replace: 'bg-charcoal-800/40 ' },
    { search: /bg-sky-100/g, replace: 'bg-charcoal-800/60' },
    { search: /bg-sky-300/g, replace: 'bg-charcoal-700' },
    { search: /bg-sky-500/g, replace: 'bg-blush-600' },
    { search: /hover:bg-sky-600/g, replace: 'hover:bg-blush-700' },
    { search: /bg-cyan-50/g, replace: 'bg-charcoal-900/40' },
    { search: /bg-blue-50/g, replace: 'bg-charcoal-900/40' },
    { search: /bg-gold-50\/50/g, replace: 'bg-charcoal-800/40' },
    { search: /bg-white/g, replace: 'bg-charcoal-900/40' },

    // Specific Order tracking fixes
    { search: /border-navy-700\/30/g, replace: 'border-charcoal-700/50' },
    { search: /text-navy-700/g, replace: 'text-charcoal-200' },
];

function processDirectory(directory) {
    const files = fs.readdirSync(directory);

    for (const file of files) {
        const fullPath = path.join(directory, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDirectory(fullPath);
        } else if (fullPath.endsWith('.tsx') || fullPath.endsWith('.ts')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            let originalContent = content;

            replacements.forEach(rule => {
                content = content.replace(rule.search, rule.replace);
            });

            if (content !== originalContent) {
                fs.writeFileSync(fullPath, content, 'utf8');
                console.log(`Updated: ${fullPath.replace(__dirname, '')}`);
            }
        }
    }
}

console.log('Starting Phase 2 theme mass cleanup...');
processDirectory(srcDir);
console.log('Cleanup complete.');
