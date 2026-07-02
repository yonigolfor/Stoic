# Quotes Enrichment — Working Document

## The Task
Enrich every quote in `Stoic/stoic_quotes/quotes.json` with structured metadata.
The file originally contained 5,247 quotes. After deduplication: **4,930 unique quotes**.

**Current progress: 40 quotes enriched. Next batch starts at index 40 (quote #41 in the deduplicated file).**

> **Note on deduplication:** 317 exact duplicates were removed on 2026-07-01.
> The 30 quotes we processed across batches 1–3 collapsed to 18 unique entries
> (quotes 13–24 were duplicates of 1–12 and were merged). All metadata was preserved.

---

## Schema Per Quote

```json
{
  "text": "original English — keep exactly",
  "author": "original — keep exactly",
  "category": "one of four enum values",
  "one_word_title_en": "single sharp English word",
  "one_word_title_he": "מילה אחת בעברית מודרנית",
  "text_he": "תרגום עברי טבעי ושוטף",
  "author_he": "שם המחבר בעברית",
  "emoji": "single emoji"
}
```

### Category Enum (strict — no other values allowed)
| Value | When to use |
|-------|-------------|
| `work_stress` | Pressure, overwhelm, burnout, performance anxiety, career tension |
| `focus` | Attention, clarity, presence, perception, knowledge, distraction |
| `discipline` | Consistency, habits, self-mastery, silence, endurance, willpower |
| `emotional_control` | Acceptance, equanimity, reframing pain, fate, relationships, anxiety |

---

## Style Guide — Title & Emoji

**The vibe:** witty, sharp, slightly ironic, modern psychological framing.

### Title Rules
- Single word only — no exceptions
- Avoid the obvious: never use "Discipline", "Focus", "Strength", "Wisdom"
- Think modern slang, psychology terms, or unexpected metaphors
- Ask: *what would a sharp therapist or Gen-Z philosopher call this concept?*

**Good examples from completed batches:**

| EN | HE | Quote |
|----|-----|-------|
| Cope | פייק | self-deception |
| Glazed | אטום | smiling through pain |
| Narrator | מספר | pain = your interpretation |
| Encrypted | מוצפן | unconquerable mind |
| Drained | בזבוז | complaining wastes energy |
| Leashed | מקבל | accepting fate |
| Loading | טוען | perception → knowledge |

### Hebrew Title Rules (`one_word_title_he`)
- One word only, modern spoken Israeli Hebrew
- Avoid textbook/formal Hebrew (לא: משמעת, חוכמה, עוצמה)
- Use everyday words with attitude: זורם, פייק, בוס, אטום, תאום, טוען
- Should hit the same ironic/punchy vibe as the English title

### Hebrew Translation Rules (`text_he`)
- Natural, flowing, conversational — like a smart friend over coffee
- **Forbidden words:** אנוכי, חפץ, על נקלה, בל יעבור, הלז, כי תחפוץ
- Keep it punchy and rhythmic — every word should earn its place
- OK to paraphrase slightly if it makes the Hebrew more natural

### Emoji Rules
- No 🧠 for mind, no ⚔️ for discipline, no 📿 for stoicism
- Abstract and witty connections win over literal ones
- Fruits, animals, random objects are encouraged if the metaphor is clever
- One emoji only

**Good examples:**
- 🍩 for "Glazed" (sweet coating, nothing sticks)
- 🧲 for "Vetted" (good people attract each other)
- 🪫 for "Drained" (low battery = wasted energy on complaining)
- 🐕 for "Leashed" (the literal dog in Zeno's cart metaphor)
- 📅 for "Later" (scheduling future anxiety away)

---

## How to Run the Next Batch

1. Read the next 10 quotes (update the slice to match current index):
```python
python3 -c "
import json
with open('Stoic/stoic_quotes/quotes.json') as f:
    data = json.load(f)
# Change 40:50 to the current start index
for i, q in enumerate(data['quotes'][40:50], start=41):
    print(f'{i}. [{q[\"author\"]}]')
    print(f'   {q[\"text\"]}')
    print()
"
```

2. Analyze each quote — one sentence of philosophical reasoning per quote.

3. Run the update script (change `START_INDEX` and `metadata` list each batch):
```python
python3 << 'EOF'
import json

metadata = [
    # 19
    {
        "category": "...",
        "one_word_title_en": "...",
        "one_word_title_he": "...",
        "text_he": "...",
        "author_he": "...",
        "emoji": "..."
    },
    # 20 ...
]

with open('Stoic/stoic_quotes/quotes.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

START_INDEX = 40  # 0-based — update each batch

for i, meta in enumerate(metadata):
    q = data['quotes'][START_INDEX + i]
    q.pop('tags', None)
    q['category']        = meta['category']
    q['one_word_title_en'] = meta['one_word_title_en']
    q['one_word_title_he'] = meta['one_word_title_he']
    q['text_he']           = meta['text_he']
    q['author_he']         = meta['author_he']
    q['emoji']             = meta['emoji']

with open('Stoic/stoic_quotes/quotes.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
EOF
```

4. Commit:
```bash
git add Stoic/stoic_quotes/quotes.json
git commit -m "feat: add metadata to quotes 41-50"
git push origin main
```

5. **Update the progress line at the top of this file.**

---

## Progress Log

**Total unique quotes: 4,930 | Enriched: 40 | Remaining: 4,890**

| Batch | Index (0-based) | Quote # | Status |
|-------|-----------------|---------|--------|
| 1 | 0–9   | 1–18 (post-dedup) | ✅ Done |
| 2 | 10–17 | 19–28 (post-dedup) | ✅ Done |
| 3 | 18–29 | 19–30 | ✅ Done |
| 4 | 30–39 | 31–40 | ✅ Done |
| 5 | 40–49 | 41–50 | ⏳ Next |
| … | … | … | — |
| 493 | 4920–4929 | 4921–4930 | — |

---

## Notes on the Dataset
- **317 duplicates removed** on 2026-07-01. File is now clean.
- Early quotes (1–18 post-dedup) are all Zeno of Citium. From #19 onward authors diversify: Marcus Aurelius, Seneca, Epictetus, and occasional non-Stoic authors (Markus Zusak, Randy Pausch, Erin Hunter, etc.).
- Non-Stoic authors still get categorized by the quote's meaning, not by tradition.
- `work_stress` is rare in Zeno — expect it more in Marcus Aurelius and Seneca passages about professional life.
