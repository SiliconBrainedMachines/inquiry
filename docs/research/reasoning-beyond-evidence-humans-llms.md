# Reasoning Beyond Evidence: Abduction, Rationalization, and Hallucination in Humans and Large Language Models

## Abstract
Humans and large language models both often move from incomplete evidence to plausible conclusions that are not yet sufficiently warranted by the available data [@douven2025abduction; @ji2022hallucination; @lin2022truthfulqa]. The core philosophical distinction is not between "reasoning" and "error," but between legitimate abductive hypothesis generation and the later mistake of presenting a hypothesis as if it were already established [@douven2025abduction]. On the human side, classic and contemporary cognitive research shows that people frequently lack reliable introspective access to the processes that produced a judgment and instead generate post hoc explanations based on implicit causal theories, explanatory preferences, and source-attribution mechanisms [@nisbett1977telling; @johnson1993source; @lombrozo2014explanation]. On the LLM side, the literature shows that ungrounded but fluent text generation is a systematic phenomenon, that models reproduce human falsehoods from training data, and that even when models can express useful uncertainty in some settings, calibration is incomplete and context-sensitive [@ji2022hallucination; @lin2022truthfulqa; @kadavath2022lmknow]. The resulting practical conclusion is that the problem should be treated as an epistemic systems problem: hypotheses, evidence, assumptions, and confidence need to be separated explicitly, because neither humans nor current LLMs are naturally truth-tracking enough to collapse those steps into one utterance safely [@bommasani2021foundation; @kadavath2022lmknow].

## Research Question
Why do humans and large language models arrive at conclusions that are not sufficiently supported by evidence, how should this be interpreted philosophically, and what does the literature suggest about causes, limits, and mitigations [@douven2025abduction; @ji2022hallucination]?

## Scope and Constraints
This investigation focuses on everyday and scientific abductive reasoning, post hoc rationalization, source-monitoring error, and LLM hallucination or unsupported assertion in interactive systems [@douven2025abduction; @johnson1993source; @ji2022hallucination]. It does not attempt a full clinical review of psychiatric confabulation, a complete history of heuristics-and-biases research, or a mechanistic account of specific model internals beyond what the selected sources support [@johnson1993source; @bommasani2021foundation]. The evidence base is a curated web-accessible set of philosophical reference material, psychology articles and reviews, and LLM evaluation papers rather than an exhaustive systematic review [@douven2025abduction; @lin2022truthfulqa; @kadavath2022lmknow].

## Method (Staged Protocol)
Stage 1 normalized the problem by separating three candidate labels that are often conflated in discussion: abduction, rationalization or confabulation, and hallucination [@douven2025abduction; @nisbett1977telling; @ji2022hallucination]. Stage 2 gathered candidate sources from philosophy, cognitive psychology, memory research, and LLM evaluation so that the comparison would not rely on a single disciplinary lens [@douven2025abduction; @johnson1993source; @lin2022truthfulqa]. Stage 3 triaged those sources by direct relevance to the concrete user experience of "the system answered first, then explained later that it had merely assumed," prioritizing sources on introspective limits, explanation-driven inference, model truthfulness, calibration, and system opacity [@nisbett1977telling; @lombrozo2014explanation; @kadavath2022lmknow; @bommasani2021foundation]. Stage 4 extracted definitional, empirical, and evaluative claims from the curated set [@douven2025abduction; @ji2022hallucination]. Stage 5 synthesized the results into explicit conclusions with confidence levels and unresolved limits, especially where the analogy between humans and LLMs is useful but imperfect [@johnson1993source; @bommasani2021foundation].

## Findings by Stage

### Stage 1 - Problem Framing
The problem is real and conceptually sharper than "AI hallucinates" or "humans jump to conclusions" [@ji2022hallucination; @douven2025abduction]. In the philosophical literature, abduction is an ampliative form of inference that goes beyond the premises by selecting or generating an explanation for the observed data; it is common, often useful, and still controversial in its normative status precisely because explanatory appeal is not the same thing as evidential proof [@douven2025abduction]. The same literature also emphasizes a structural weakness sometimes described as the "best of a bad lot" problem: a reasoner may choose the best explanation among those considered while still missing the actually correct explanation entirely [@douven2025abduction].

That matters here because the user-described failure mode is not simply that a mind or a model used abduction; it is that an abductive or explanatory leap appears to have been presented as if it were already evidentially settled [@douven2025abduction]. In other words, the key failure is often not hypothesis generation itself, but the collapse of the boundary between hypothesis, confidence, and verified conclusion [@douven2025abduction; @kadavath2022lmknow].

### Stage 2 - Source Discovery
The selected source set covers four necessary angles [@douven2025abduction; @lin2022truthfulqa]. First, a philosophical account of abduction was needed to avoid using the word loosely as a synonym for any unsupported guess [@douven2025abduction]. Second, classic cognitive-psychology work was needed to test whether humans really do generate post hoc reasons that outrun their evidential basis or introspective access [@nisbett1977telling]. Third, memory and attribution research was needed to explain how false reasons or false origins can arise without deliberate deception [@johnson1993source]. Fourth, LLM-specific evaluation and survey papers were needed to distinguish general reasoning under uncertainty from model-specific failure modes such as hallucination, mimicry of falsehoods, imperfect self-evaluation, and broad sociotechnical opacity [@ji2022hallucination; @lin2022truthfulqa; @kadavath2022lmknow; @bommasani2021foundation].

### Stage 3 - Source Triage
The highest-value philosophical source was the Stanford Encyclopedia entry on abduction because it provides both the modern inferential framing and the central criticism that explanatory ranking can still pick "the best of a bad lot" [@douven2025abduction]. The highest-value human studies were Nisbett and Wilson on verbal reports of mental processes, Johnson et al. on source monitoring, and Lombrozo and Gwynne on explanation-guided generalization, because together they cover post hoc rationalization, source-attribution error, and the way explanations themselves shape what people infer next [@nisbett1977telling; @johnson1993source; @lombrozo2014explanation]. The highest-value LLM sources were Ji et al. for the taxonomy of hallucination, Lin et al. for direct evidence that models mimic common human falsehoods, Kadavath et al. for calibration and self-evaluation, and Bommasani et al. for the broader claim that foundation models remain incompletely understood and propagate defects downstream [@ji2022hallucination; @lin2022truthfulqa; @kadavath2022lmknow; @bommasani2021foundation].

### Stage 4 - Evidence Extraction
Philosophically, abduction is not deduction and not simple induction; it is explanatory reasoning that extends beyond what the premises strictly entail [@douven2025abduction]. That makes abduction indispensable for discovery but inherently fallible, and the literature explicitly warns that explanatory attractiveness does not guarantee truth [@douven2025abduction]. This is the first antecedent of the problem: systems that must act under underdetermination will often generate candidate explanations before they possess decisive evidence [@douven2025abduction].

Human cognition adds a second antecedent: people often cannot directly inspect the higher-order processes that produced a judgment [@nisbett1977telling]. Nisbett and Wilson's review argues that when people explain their own judgments, choices, or responses, they frequently rely not on transparent introspection but on implicit causal theories about what would be a plausible cause of the observed response [@nisbett1977telling]. This is highly relevant to the user's experience, because the later statement "I assumed X" can be informative at a coarse level while still failing to be a reliable causal reconstruction of the original reasoning process [@nisbett1977telling].

Human memory research adds a third antecedent: errors can arise not only from inference but from misattributing where a mental content came from [@johnson1993source]. Johnson, Hashtroudi, and Lindsay describe source monitoring as the process by which people judge whether content came from perception, reflection, imagination, testimony, or some other source, and they argue that these judgments are flexible, effortful to varying degrees, and vulnerable to error [@johnson1993source]. They explicitly connect disruptions in source monitoring to confabulation, amnesia, aging, cryptomnesia, and incorporation of fiction into fact [@johnson1993source]. This helps explain how someone can sincerely report a reason, memory, or evidential origin that is simply wrong without intending to deceive [@johnson1993source].

A fourth antecedent is that explanations are not passive summaries of evidence; they actively reshape later inference [@lombrozo2014explanation]. Lombrozo and Gwynne showed experimentally that the type of explanation privileged by a person changes how that person generalizes properties from known to novel cases, and that explanatory modes can even be primed experimentally [@lombrozo2014explanation]. In their experiments, functional explanations reliably shifted subsequent generalization toward shared functions, even when participants had access to the same underlying information [@lombrozo2014explanation]. This suggests that once an explanation frame is adopted, later judgments are filtered through it rather than built afresh from neutral evidence each time [@lombrozo2014explanation].

On the LLM side, the survey literature shows that hallucination is not an anecdotal defect but a broad class of ungrounded generation problems across summarization, dialogue, question answering, data-to-text generation, translation, and LLM settings [@ji2022hallucination]. Ji et al. emphasize that fluent generation and factual faithfulness come apart, which is exactly the surface pattern the user describes: the answer sounds coherent even when the supporting evidence is absent or weak [@ji2022hallucination].

TruthfulQA adds a sharper causal clue: models often reproduce falsehoods that humans commonly say or believe [@lin2022truthfulqa]. Lin, Hilton, and Evans built a benchmark explicitly designed so that an answerer who merely imitates common textual patterns will fail, and they found that models produced many false answers that mimic popular misconceptions, with larger models not automatically becoming more truthful [@lin2022truthfulqa]. Their interpretation is directly relevant here: optimizing imitation of human text is not the same as optimizing truthfulness under evidence [@lin2022truthfulqa].

Kadavath et al. complicate the picture in an important way [@kadavath2022lmknow]. Their results suggest that language models can sometimes estimate whether a particular answer is likely to be true and can produce useful confidence-style signals such as P(True) or P(I Know), especially in controlled formats [@kadavath2022lmknow]. However, the same paper also reports limitations in calibration on new tasks, which means that useful self-evaluation exists but is not strong enough to treat every retrospective explanation or confidence statement as reliable [@kadavath2022lmknow]. The upshot is not "models have no metacognition" but rather "their uncertainty expression is partial, format-sensitive, and still requires external verification" [@kadavath2022lmknow].

Bommasani et al. reinforce a broader systems-level lesson: foundation models remain insufficiently understood in how they work, when they fail, and what their emergent properties imply for downstream deployments [@bommasani2021foundation]. If the underlying model is opaque and its defects are inherited by adapted systems, then a smooth retrospective sentence such as "I assumed X" should be treated as a plausible interface-level summary, not as an audited provenance trace [@bommasani2021foundation].

### Stage 5 - Synthesis and Limits
**Conclusion 1, confidence high:** the phenomenon exists in both humans and LLMs, but not because they are the same kind of system [@nisbett1977telling; @johnson1993source; @ji2022hallucination]. Humans exhibit bounded introspection, source-attribution error, and explanation-shaped inference; LLMs exhibit fluent ungrounded generation, imitation of falsehoods from training data, and incomplete calibration [@nisbett1977telling; @johnson1993source; @lombrozo2014explanation; @lin2022truthfulqa; @kadavath2022lmknow].

**Conclusion 2, confidence high:** the user's concrete experience is best described as a collapse between hypothesis generation and evidentially warranted assertion [@douven2025abduction; @ji2022hallucination]. In a human, the later explanation of why a wrong judgment occurred may itself be a post hoc theory rather than a transparent readout of the original process [@nisbett1977telling]. In an LLM, the later explanation is also generated text and therefore should not be over-read as a privileged window into the model's true causal pathway [@bommasani2021foundation; @kadavath2022lmknow].

**Conclusion 3, confidence medium-high:** calling every such failure "abduction" is too generous [@douven2025abduction]. Proper abduction names a fallible but often rational move from data to explanatory hypothesis; the specific failure arises when the system fails to mark that move as hypothetical, fails to separate assumption from observed evidence, or fails to trigger verification before asserting the result as fact [@douven2025abduction; @ji2022hallucination].

**Conclusion 4, confidence medium-high:** the most robust mitigation is not the elimination of abductive reasoning but the explicit serialization of epistemic steps [@douven2025abduction; @lin2022truthfulqa; @kadavath2022lmknow]. Systems should externalize what is observed, what is inferred, what is assumed, what alternatives were considered, and how confident the system is before final commitment [@kadavath2022lmknow].

**Unresolved uncertainty, confidence medium:** the analogy between human confabulation and LLM hallucination is useful but not identity-preserving [@johnson1993source; @bommasani2021foundation]. Humans have memory systems, agency, and phenomenology; LLMs are sequence models trained to extend text distributions [@johnson1993source; @bommasani2021foundation]. The safest comparison is therefore functional: both can output plausible unsupported claims, but the mechanisms and ontological commitments differ [@ji2022hallucination; @bommasani2021foundation].

## Discussion
I understand the problem the user is pointing to, and the literature supports treating it as a serious epistemic failure mode rather than a mere nuisance [@nisbett1977telling; @lin2022truthfulqa]. The frustrating part is not only that an answer is wrong, but that the later explanation often arrives in a tone of confidence and conceptual neatness that invites the user to mistake it for a genuine account of why the system erred [@nisbett1977telling; @bommasani2021foundation]. In humans, this is familiar from post hoc rationalization: we often report why we acted as we did by appealing to what would have been a sensible cause, not necessarily to the cause that actually operated [@nisbett1977telling]. In LLMs, the analogous risk is that the model produces a second plausible narrative about the first answer, even though the model has no direct introspective faculty comparable to an inspected causal trace [@bommasani2021foundation; @kadavath2022lmknow].

This suggests a philosophical reframing. The central issue is not simply that people or models "reason badly." It is that explanatory systems are often optimized to produce coherence under uncertainty, while users often need provenance under evidential discipline [@lombrozo2014explanation; @ji2022hallucination]. Coherence and provenance are not the same thing [@ji2022hallucination; @lin2022truthfulqa]. A coherent answer may be a useful hypothesis; a provenance-backed answer is one whose relation to evidence has been made explicit and can be checked [@douven2025abduction; @kadavath2022lmknow].

For practical human-AI interaction, the literature implies several disciplined moves [@lin2022truthfulqa; @kadavath2022lmknow]. First, ask the system to separate observed evidence, assumptions, and inferred conclusions instead of letting them appear in one undifferentiated paragraph [@douven2025abduction; @kadavath2022lmknow]. Second, ask for direct source quotation or explicit provenance when the claim matters, because fluency is not evidence [@ji2022hallucination; @lin2022truthfulqa]. Third, treat retrospective statements such as "I assumed" as a clue about failure mode, not as a verified account of internal causation [@nisbett1977telling; @bommasani2021foundation]. Fourth, when possible, force a second stage in which the system evaluates its own answer or declares uncertainty before finalizing it, because self-evaluation can help even though it is imperfect [@kadavath2022lmknow].

The deeper implication is almost Peircean: abduction is acceptable as the beginning of inquiry, but dangerous when disguised as the end of inquiry [@douven2025abduction].

## Conclusion
The problem is real, intelligible, and historically deep [@douven2025abduction; @nisbett1977telling]. Humans and LLMs both produce unsupported conclusions because both rely, in different ways, on mechanisms that privilege plausible explanation, coherence, or learned association before evidential closure is complete [@nisbett1977telling; @lombrozo2014explanation; @ji2022hallucination; @lin2022truthfulqa]. What users experience as "the system just made something up and only later admitted it had assumed too much" is best understood as the mismanagement of abductive or explanatory generation under weak truth controls, followed by an often unreliable retrospective narrative about that failure [@douven2025abduction; @nisbett1977telling; @bommasani2021foundation]. The correct response is therefore architectural as much as philosophical: keep hypothesis generation, evidence display, uncertainty, and verification visibly separate [@kadavath2022lmknow; @lin2022truthfulqa].

## Limitations
This report is a structured, curated synthesis rather than a full systematic review or meta-analysis. Several classic neighboring literatures, especially the full heuristics-and-biases canon and recent philosophical work explicitly describing LLMs as truth-indifferent or bullshitters, were considered conceptually but not included as core evidence because web-accessible extraction during this run was incomplete or blocked. The comparison between human confabulation and LLM hallucination is therefore strongest at the level of functional analogy, not literal identity [@bommasani2021foundation; @johnson1993source].

## References
```bibtex
@online{douven2025abduction,
  title={Abduction},
  author={Douven, Igor},
  year={2025},
  note={Stanford Encyclopedia of Philosophy, substantive revision June 18, 2025},
  url={https://plato.stanford.edu/entries/abduction/}
}

@article{nisbett1977telling,
  title={Telling More Than We Can Know: Verbal Reports on Mental Processes},
  author={Nisbett, Richard E. and Wilson, Timothy D.},
  journal={Psychological Review},
  volume={84},
  number={3},
  pages={231--259},
  year={1977},
  url={https://psycnet.apa.org/doi/10.1037/0033-295X.84.3.231}
}

@article{johnson1993source,
  title={Source Monitoring},
  author={Johnson, Marcia K. and Hashtroudi, Shahin and Lindsay, D. Stephen},
  journal={Psychological Bulletin},
  volume={114},
  number={1},
  pages={3--28},
  year={1993},
  url={https://psycnet.apa.org/doi/10.1037/0033-2909.114.1.3}
}

@article{lombrozo2014explanation,
  title={Explanation and Inference: Mechanistic and Functional Explanations Guide Property Generalization},
  author={Lombrozo, Tania and Gwynne, Nicholas Z.},
  journal={Frontiers in Human Neuroscience},
  volume={8},
  pages={700},
  year={2014},
  doi={10.3389/fnhum.2014.00700},
  url={https://www.frontiersin.org/article/10.3389/fnhum.2014.00700/abstract}
}

@article{ji2022hallucination,
  title={Survey of Hallucination in Natural Language Generation},
  author={Ji, Ziwei and Lee, Nayeon and Frieske, Rita and Yu, Tiezheng and Su, Dan and Xu, Yan and Ishii, Etsuko and Bang, Yejin and Chen, Delong and Madotto, Andrea and Fung, Pascale},
  journal={ACM Computing Surveys},
  year={2022},
  url={https://arxiv.org/abs/2202.03629}
}

@inproceedings{lin2022truthfulqa,
  title={TruthfulQA: Measuring How Models Mimic Human Falsehoods},
  author={Lin, Stephanie and Hilton, Jacob and Evans, Owain},
  booktitle={Proceedings of the 60th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)},
  pages={3214--3252},
  year={2022},
  doi={10.18653/v1/2022.acl-long.229},
  url={https://aclanthology.org/2022.acl-long.229/}
}

@article{kadavath2022lmknow,
  title={Language Models (Mostly) Know What They Know},
  author={Kadavath, Saurav and Conerly, Tom and Askell, Amanda and Henighan, Tom and Drain, Dawn and Perez, Ethan and Schiefer, Nicholas and Hatfield-Dodds, Zac and DasSarma, Nova and Tran-Johnson, Eli and others},
  journal={arXiv preprint arXiv:2207.05221},
  year={2022},
  url={https://arxiv.org/abs/2207.05221}
}

@article{bommasani2021foundation,
  title={On the Opportunities and Risks of Foundation Models},
  author={Bommasani, Rishi and Hudson, Drew A. and Adeli, Ehsan and Altman, Russ and Arora, Simran and von Arx, Sydney and Bernstein, Michael S. and Bohg, Jeannette and Bosselut, Antoine and Brunskill, Emma and others},
  journal={arXiv preprint arXiv:2108.07258},
  year={2021},
  url={https://arxiv.org/abs/2108.07258}
}
```