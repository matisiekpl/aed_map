const OpenAI = require('openai');
const input = require('input');
const fs = require('fs');
const path = require('path');

const client = new OpenAI();

const languages = ['pl-PL', 'de-DE', 'en-US', 'es-ES', 'fr-FR', 'it-IT'];

const template = languages.map(lang => 
  `<${lang}>\nTutaj wpisz lub wklej informacje o wersji w tym języku: ${lang}\n</${lang}>`
).join('\n');

async function main() {
    const whatsNew = await input.text("What's new in this version?");
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
    
    const metadataDir = path.join(__dirname, 'ios', 'fastlane', 'metadata');
    
    for (const lang of languages) {
        const regex = new RegExp(`<${lang}>([\\s\\S]*?)</${lang}>`);
        const match = output.match(regex);
        if (match) {
            const langDir = path.join(metadataDir, lang);
            fs.mkdirSync(langDir, { recursive: true });
            fs.writeFileSync(path.join(langDir, 'release_notes.txt'), match[1].trim());
            console.log(`✓ Wrote release notes for ${lang}`);
        } else {
            console.log(`✗ No content found for ${lang}`);
        }
    }
}

main();
