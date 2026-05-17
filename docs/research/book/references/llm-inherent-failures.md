# LLM Inherent Failure Modes — Are They Architectural?

**Purpose:** Research document to substantiate Prologue ¶9 — the claim that LLM failures are inherent to the architecture, not bugs to be patched.
**Status:** Reference document.

---

## Core Thesis

LLM failures (hallucination, confabulation, plausible nonsense) are **not bugs** — they are consequences of how the architecture works. They diminish in frequency with better models and more data, but they do not disappear because they arise from the fundamental mechanism: next-token prediction over probability distributions.

---

## Key Evidence

### 1. "Hallucination is Inevitable" (Xu, Jain & Kankanhalli, 2024)

> "Researchers have proposed that hallucinations are inevitable and are an innate limitation of large language models."

**Source:** Xu, Ziwei; Jain, Sanjay; Kankanhalli, Mohan (2024). "Hallucination is Inevitable: An Innate Limitation of Large Language Models." arXiv:2401.11817.

**Key argument:** The mathematical framework of LLMs (autoregressive next-token prediction) guarantees that hallucinations cannot be fully eliminated. The model must always "guess" the next token, even when it lacks sufficient information. This is not a deficiency in training data — it is a property of the architecture.

### 2. OpenAI's Own Diagnosis (2025)

> "Hallucinations occur because the training and evaluation of LLMs reward guessing over acknowledging uncertainty."

**Source:** Business Insider, September 2025, citing OpenAI researchers.

**Key argument:** The training process (including RLHF) incentivizes the model to produce confident answers rather than say "I don't know." This is a training incentive problem, but it's also architectural — the model has no built-in mechanism for epistemic uncertainty.

### 3. The Next-Token Prediction Problem

> "The pre-training of generative pretrained transformers (GPT) involves predicting the next word. It incentivizes GPT models to 'give a guess' about what the next word is, even when they lack information."

**Source:** Wikipedia, citing OpenAI technical documentation.

**Implication:** The fundamental operation — predicting the most probable next token — is inherently **abductive**. The model infers the best explanation (most probable continuation) from incomplete information. Abduction, unlike deduction, does not guarantee truth. It guarantees plausibility. This is exactly Peirce's abductive reasoning: inference to the best explanation, which can be wrong.

### 4. Cascade Effect

> "An AI generates each next word based on a sequence of previous words (including the words it has itself previously generated during the same conversation), causing a cascade of possible hallucinations as the response grows longer."

**Source:** Ji et al. (2023), "Survey of Hallucination in Natural Language Generation," ACM Computing Surveys.

**Implication:** Each hallucinated token increases the probability of further hallucination. The error compounds. This is structural — it cannot be eliminated by better data alone.

### 5. Anthropic's Interpretability Research (2025)

> Anthropic identified internal circuits in Claude that cause it to decline to answer questions unless it knows the answer. "Hallucinations were found to occur when this inhibition happens incorrectly, such as when Claude recognizes a name but lacks sufficient information about that person."

**Source:** Anthropic, "Tracing Thoughts of a Large Language Model," March 2025.

**Implication:** Even with safety circuits designed to prevent hallucination, the failure mode persists because the model cannot reliably distinguish between "enough information to answer" and "some information that resembles enough." Pattern recognition ≠ knowledge.

### 6. "ChatGPT is Bullshit" (Hicks, Humphries & Slater, 2024)

> "The models are 'in an important way indifferent to the truth of their outputs', with true statements only accidentally true, and false ones accidentally false."

**Source:** Hicks, Humphries & Slater (2024), "ChatGPT is bullshit," Ethics and Information Technology, 26(2).

**Key argument:** Using Harry Frankfurt's philosophical definition of "bullshit" (speech indifferent to truth), LLM outputs qualify as bullshit — not lies (which require knowledge of truth), but statements where truth-value is irrelevant to the generation process. The architecture does not model truth; it models probability.

---

## Evolution Across Model Generations

| Model | Release | Hallucination Rate (approx.) | Notable Changes |
|-------|---------|------------------------------|-----------------|
| GPT-3.5 (ChatGPT launch) | Nov 2022 | Very high — 47% fabricated references (Cureus study) | No RLHF safety on citations |
| GPT-4 | Mar 2023 | Significantly reduced — better reasoning, still hallucinated | Improved with RLHF, but "plausible nonsense" persisted |
| GPT-4 Turbo | Nov 2023 | Further reduced, especially with RAG | Still hallucinated on edge cases |
| Claude 3 / Gemini 1.5 | 2024 | Lower rates on benchmarks | Better "I don't know" responses, but confabulation remained |
| GPT-4o / Claude 3.5+ | 2024-2025 | Measurably lower but non-zero | Deloitte still caught submitting hallucinated citations (Oct 2025) |
| Current (2026) | Ongoing | Rare but persistent | Frequency decreases; **type** remains identical |

**Key observation:** Each generation reduces the *rate* of hallucination. No generation has changed the *type*. The same failure modes persist:
- Fabricated citations
- Plausible but false reasoning
- Confident statements without epistemic basis
- Category confusion
- Drift from context over long conversations

---

## The Abductive Machine Argument

### Why "Abductive" Is Precise

Charles Sanders Peirce defined three types of inference:
1. **Deduction**: From rules and cases to conclusions (certain)
2. **Induction**: From cases to generalizations (probable)
3. **Abduction**: From observations to best explanations (plausible)

An LLM is fundamentally an abductive machine:
- Given a sequence of tokens (observation), it infers the most plausible next token (best explanation)
- It does not verify truth — it maximizes probability
- It does not distinguish knowledge from pattern — it treats all learned patterns equally
- It generates what *sounds right*, not what *is right*

### The Philosophical Failures Are the Same Failures

| LLM Failure Mode | Philosophical Problem | Philosopher |
|---|---|---|
| Hallucination (fabricated facts) | Confabulation / False belief | Epistemology (since Plato) |
| Plausible nonsense with confidence | Bullshit (indifference to truth) | Frankfurt (1986, *On Bullshit*) |
| Ambiguity in interpretation | Meaning is use, not reference | Wittgenstein (PI, 1953) |
| Invalid reasoning dressed as logic | Sophistical refutation | Aristotle (*Soph. Ref.*, 4th c. BC) |
| Category confusion | Category mistake | Ryle (1949, *The Concept of Mind*) |
| Drift / loss of context | Failure of relevance | Grice (1975, Maxims of Conversation) |
| Overconfident false claims | Epistemic vice | Virtue epistemology (Zagzebski, Sosa) |

---

## Implications for the Book

1. **The failures are not bugs to be patched — they are consequences of working with language through an abductive architecture.** Better models reduce frequency, not type.

2. **The solutions are layered:** Prompt engineering, RAG, MCPs, and tool integrations address symptoms at secondary layers. The primary layer — how humans communicate meaning — requires tools from the discipline that has studied meaning for 2,500 years: philosophy.

3. **The book's position is not anti-technology.** It is: "The technology is extraordinary. The failures it reveals are ancient. The tools to address them already exist."

4. **Key quote for Prologue ¶9:** "They changed in frequency, not in kind" — this is the empirical claim the research supports.

---

## Sources

- Xu, Jain & Kankanhalli (2024). "Hallucination is Inevitable." arXiv:2401.11817
- Ji et al. (2023). "Survey of Hallucination in NLG." ACM Computing Surveys 55(12)
- Hicks, Humphries & Slater (2024). "ChatGPT is bullshit." Ethics & Info Tech 26(2)
- Anthropic (2025). "Tracing Thoughts of a Large Language Model."
- OpenAI (2023). "GPT-4 Technical Report." arXiv:2303.08774
- Frankfurt, Harry (1986/2005). *On Bullshit.* Princeton University Press.
- Peirce, Charles Sanders. Collected Papers, esp. on abduction (CP 5.171-5.212)
- Wikipedia: "Hallucination (artificial intelligence)" — accessed April 2026
