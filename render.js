const fs = require('fs');
const axios = require('axios');
const pug = require('pug');
const intl = require('intl');
const path = require('path');
const formatter = new intl.DateTimeFormat('pl', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
});

const include = fs.readFileSync('include.html', 'utf8');

fs.readdirSync('.').forEach(file => {
    if (file.startsWith('turek') || file.endsWith('epub') || file.endsWith('pdf')) {
        fs.copyFileSync(path.resolve(__dirname, file), path.resolve(__dirname, 'public', file));
        console.log('Copied ' + file);
    }
});

if (!fs.existsSync('public/js')) {
    fs.mkdirSync('public/js');
    fs.writeFileSync('public/js/main.js', '');
}

async function main() {
    let wp = await axios.get('https://wp.aedmapa.pl/wp-json/wp/v2/posts?_embed');
    wp = wp.data;

    let blog = pug.renderFile('src/pug/blog.pug');
    let items = '';

    wp.forEach(post => {
        let content = pug.renderFile('src/pug/post.pug');
        content = content.replace(new RegExp('{{title}}', 'g'), post['title']['rendered']);
        content = content.replace('{{content}}', post['content']['rendered'].replace(new RegExp('<p>', 'g'), '<p class="text-xl font-extrabold leading-7 mb-10">').replace(new RegExp('<img', 'g'), '<img class="block mb-6 w-full h-112 object-cover border-3 border-indigo-900 rounded-2xl shadow-lg" '));
        if (post['excerpt'] != null)
            content = content.replace('{{excerpt}}', '<div class="mb-6">' + post['excerpt']['rendered'] + '</div>');
        content = content.replace('{{date}}', formatter.format(new Date(post['date'])));
        if (post['_embedded']['wp:featuredmedia'] != null)
            content = content.replace('%7B%7Bimage%7D%7D', post['_embedded']['wp:featuredmedia'][0]['source_url']);
        fs.writeFileSync('public/' + post['slug'] + '.html', content);
        console.log('Rendered ' + post['slug'] + '.html');
        if (post['_embedded']['wp:featuredmedia'] != null) {
            let item = fs.readFileSync('post.html', 'utf8');
            item = item.replace('{{title}}', post['title']['rendered']);
            item = item.replace('{{link}}', '/' + post['slug'] + '.html');
            item = item.replace('{{date}}', formatter.format(new Date(post['date'])));
            if (post['excerpt'] != null)
                item = item.replace('{{excerpt}}', post['excerpt']['rendered']);
            item = item.replace('{{image}}', post['_embedded']['wp:featuredmedia'][0]['source_url']);
            items += item;
        }
    });

    blog = blog.replace('{{posts}}', items);
    fs.writeFileSync('public/blog.html', blog);

    fs.readdirSync('public').forEach(file => {
        if (file.endsWith('.html')) {
            let content = fs.readFileSync('public/' + file, 'utf8');
            content = '<!DOCTYPE html>\n' + content;
            content = content.replace('<head>', '<head>' + include);
            content = content.replace(new RegExp('<a', 'g'), '<a aria-label="Czytaj więcej o AED"');
            content = content.replace(new RegExp('<img', 'g'), '<img alt="AED"');
            content = content.replace(new RegExp('.png', 'g'), '.webp');
            fs.writeFileSync('public/' + file, content);
        }
    });
}

main();