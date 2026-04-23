const OpenAI = require('openai');
const input = require('input');
const fs = require('fs');
const path = require('path');

const client = new OpenAI();

const languages = {
    'pl-PL': { ios: 'pl', android: 'pl-PL' },
    'de-DE': { ios: 'de-DE', android: 'de-DE' },
    'en-US': { ios: 'en-US', android: 'en-US' },
    'es-ES': { ios: 'es-ES', android: 'es-ES' },
    'fr-FR': { ios: 'fr-FR', android: 'fr-FR' },
    'it-IT': { ios: 'it', android: null },
};

async function main() {
    const whatsNew = await input.text("What's new in this version?");
    const template = Object.keys(languages).map(lang =>
        `<${lang}>\nTutaj wpisz lub wklej informacje o wersji w tym języku: ${lang}\n</${lang}>`
    ).join('\n');
    const prompt = `Fill following template with translations of text: "${whatsNew}". Output ONLY filled template\n\nTemplate:\n\n${template}`;

    const stream = await client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [{ role: 'user', content: prompt }],
        stream: true,
    });

    let output = '';
    for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content || '';
        process.stdout.write(content);
        output += content;
    }
    process.stdout.write('\n\n');

    const pubspec = fs.readFileSync(path.join(__dirname, 'pubspec.yaml'), 'utf8');
    const flutterVersionCode = parseInt(pubspec.match(/^version:\s*[^+]+\+(\d+)/m)[1], 10);
    const androidVersionCode = flutterVersionCode + 1000000000;

    for (const [lang, dirs] of Object.entries(languages)) {
        const match = output.match(new RegExp(`<${lang}>([\\s\\S]*?)</${lang}>`));
        if (!match) {
            console.log(`✗ No content found for ${lang}`);
            continue;
        }
        const content = match[1].trim();

        const iosDir = path.join(__dirname, 'ios', 'fastlane', 'metadata', dirs.ios);
        fs.mkdirSync(iosDir, { recursive: true });
        fs.writeFileSync(path.join(iosDir, 'release_notes.txt'), content);

        if (dirs.android) {
            const androidDir = path.join(__dirname, 'android', 'fastlane', 'metadata', 'android', dirs.android, 'changelogs');
            fs.mkdirSync(androidDir, { recursive: true });
            fs.writeFileSync(path.join(androidDir, `${androidVersionCode}.txt`), content);
            fs.writeFileSync(path.join(androidDir, 'default.txt'), content);
        }

        console.log(`✓ Wrote release notes for ${lang}`);
    }
}

main();
