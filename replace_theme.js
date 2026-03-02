const fs = require('fs');
const path = require('path');

const srcDirs = [
    path.join(__dirname, 'src/components'),
    path.join(__dirname, 'src/hooks'),
    path.join(__dirname, 'src')
];

const replacements = [
    { search: /bg-white(?!\/)/g, replace: 'bg-charcoal-900/40 backdrop-blur-md' },
    { search: /bg-gray-50/g, replace: 'bg-theme-bg' },
    { search: /bg-gray-100/g, replace: 'bg-charcoal-800/50' },
    { search: /border-gray-100/g, replace: 'border-charcoal-800/50' },
    { search: /border-gray-200/g, replace: 'border-charcoal-700/50' },
    { search: /border-gray-300/g, replace: 'border-charcoal-600/50' },
    { search: /text-gray-400/g, replace: 'text-charcoal-500' },
    { search: /text-gray-500/g, replace: 'text-charcoal-400' },
    { search: /text-gray-600/g, replace: 'text-charcoal-300' },
    { search: /text-gray-700/g, replace: 'text-charcoal-200' },
    { search: /text-gray-900/g, replace: 'text-white' },
    { search: /text-science-blue-900/g, replace: 'text-white' },
    { search: /text-science-blue-700/g, replace: 'text-blush-300' },
    { search: /text-blush-900/g, replace: 'text-white' },
    { search: /bg-cool-gray/g, replace: 'bg-theme-bg' },
    { search: /shadow-clinical/g, replace: 'shadow-[0_0_15px_rgba(0,0,0,0.3)]' },
    { search: /bg-secondary-50/g, replace: 'bg-charcoal-900/60' },
    // specific fixes for root containers
    { search: /min-h-screen bg-charcoal-900\/40 backdrop-blur-md/g, replace: 'min-h-screen bg-theme-bg' }
];

function processDirectory(directory) {
    const files = fs.readdirSync(directory);

    for (const file of files) {
        const fullPath = path.join(directory, file);
        if (fs.statSync(fullPath).isDirectory()) {
            if (!fullPath.includes('node_modules')) {
                processDirectory(fullPath);
            }
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

console.log('Starting theme mass replace...');
srcDirs.forEach(dir => {
    if (fs.existsSync(dir) && fs.statSync(dir).isDirectory()) {
        try {
            processDirectory(dir);
        } catch (e) {
            // ignore if it's the root dir trying to recursive same things
        }
    }
});
console.log('Theme replacement complete.');
