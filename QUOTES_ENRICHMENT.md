# Quotes Enrichment — Working Document

## The Task
Enrich every quote in `Stoic/stoic_quotes/quotes.json` with structured metadata.
The file originally contained 5,247 quotes. After deduplication: **4,930 unique quotes**.

**Current progress: 18 quotes enriched. Next batch starts at index 18 (quote #19 in the deduplicated file).**

> **Note on deduplication:** 317 exact duplicates were removed on 2026-07-01.
> The 30 quotes we processed across batches 1–3 collapsed to 18 unique entries
> (quotes 13–24 were duplicates of 1–12 and were merged). All metadata was preserved.

---

## Schema Per Quote

```json
{
  "text": "original — keep exactly",
  "author": "original — keep exactly",
  "category": "one of four enum values",
  "one_word_title": "single sharp word",
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
- "Cope" (self-deception)
- "Glazed" (smiling through pain — like a donut, nothing sticks)
- "Narrator" (pain = your interpretation, not the event)
- "Encrypted" (unconquerable mind)
- "Drained" (complaining wastes finite energy)
- "Leashed" (accepting fate like the dog tied to the cart)
- "Loading" (perception → assent → comprehension → knowledge)

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
# Change 18:28 to the current start index
for i, q in enumerate(data['quotes'][18:28], start=19):
    print(f'{i}. [{q[\"author\"]}]')
    print(f'   {q[\"text\"]}')
    print()
"
```

2. Analyze each quote — one sentence of philosophical reasoning per quote.

3. Run the update script (change the slice and metadata list):
```python
python3 << 'EOF'
import json

metadata = [
    # 31
    {"category": "...", "one_word_title": "...", "emoji": "..."},
    # 32 ...
]

with open('Stoic/stoic_quotes/quotes.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

START_INDEX = 18  # 0-based index of first quote in this batch — update each time

for i, meta in enumerate(metadata):
    q = data['quotes'][START_INDEX + i]
    q.pop('tags', None)
    q['category']       = meta['category']
    q['one_word_title'] = meta['one_word_title']
    q['emoji']          = meta['emoji']

with open('Stoic/stoic_quotes/quotes.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
EOF
```

4. Commit:
```bash
git add Stoic/stoic_quotes/quotes.json
git commit -m "feat: add metadata to quotes 31-40"
git push origin main
```

5. **Update the progress line at the top of this file.**

---

## Progress Log

**Total unique quotes: 4,930 | Enriched: 18 | Remaining: 4,912**

| Batch | Index (0-based) | Quote # | Status |
|-------|-----------------|---------|--------|
| 1 | 0–9   | 1–18 (post-dedup) | ✅ Done |
| 2 | 18–27 | 19–28 | ⏳ Next |
| … | … | … | — |
| 493 | 4920–4929 | 4921–4930 | — |

---

## Notes on the Dataset
- **317 duplicates removed** on 2026-07-01. File is now clean.
- Early quotes (1–18 post-dedup) are all Zeno of Citium. From #19 onward authors diversify: Marcus Aurelius, Seneca, Epictetus, and occasional non-Stoic authors (Markus Zusak, Randy Pausch, Erin Hunter, etc.).
- Non-Stoic authors still get categorized by the quote's meaning, not by tradition.
- `work_stress` is rare in Zeno — expect it more in Marcus Aurelius and Seneca passages about professional life.
