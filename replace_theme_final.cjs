const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, 'src');

const replacements = [
    { search: /bg-white\/([0-9]+)/g, replace: 'bg-charcoal-900/$1' },
    { search: /bg-blush-50/g, replace: 'bg-charcoal-800/60' },
    { search: /bg-clinical-blue\/30/g, replace: 'bg-charcoal-800/40' },
    { search: /bg-clinical-blue/g, replace: 'bg-charcoal-800' },
    { search: /text-science-blue-500/g, replace: 'text-glow-teal-400' },
    { search: /text-science-blue-200/g, replace: 'text-charcoal-400' },
    { search: /text-science-blue-100/g, replace: 'text-charcoal-500' },
    { search: /text-charcoal-800/g, replace: 'text-charcoal-200' },
    { search: /text-charcoal-700/g, replace: 'text-charcoal-200' },
    { search: /border-blush-100/g, replace: 'border-charcoal-700/50' },
    { search: /border-blush-200/g, replace: 'border-glow-teal-500/30' },
    { search: /bg-gray-50\/50/g, replace: 'bg-charcoal-800/30' },
    { search: /bg-gray-50/g, replace: 'bg-charcoal-800/30' }
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

console.log('Starting final theme mass cleanup...');
processDirectory(srcDir);
console.log('Cleanup complete.');
