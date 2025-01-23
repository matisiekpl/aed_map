const OpenAI = require('openai');
const input = require('input');

const client = new OpenAI();

const template = `
<pl-PL>
Tutaj wpisz lub wklej informacje o wersji w tym języku: pl-PL
</pl-PL>
<de-DE>
Tutaj wpisz lub wklej informacje o wersji w tym języku: de-DE
</de-DE>
<en-US>
Tutaj wpisz lub wklej informacje o wersji w tym języku: en-US
</en-US>
<es-ES>
Tutaj wpisz lub wklej informacje o wersji w tym języku: es-ES
</es-ES>
<fr-FR>
Tutaj wpisz lub wklej informacje o wersji w tym języku: fr-FR
</fr-FR>
<it-IT>
Tutaj wpisz lub wklej informacje o wersji w tym języku: it-IT
</it-IT>
`;

async function main() {
    const whatsNew = await input.text('What\'s new in this version?');
    const prompt = `Fill following template with translations of text: "${whatsNew}".Output ONLY filled template\n\n Template:\n\n${template}.`;
    const stream = await client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [{ role: 'user', content: prompt }],
        stream: true,
    });
    for await (const chunk of stream) {
        process.stdout.write(chunk.choices[0]?.delta?.content || '');
    }
}

main();