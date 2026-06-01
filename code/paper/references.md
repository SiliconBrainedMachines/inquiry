# References

> **Type:** method
> **Status:** stable
> **Used by:** every document that makes an external claim

All external claims in this folder must cite a key defined here. Entries are
BibTeX-ready. Philosophical primary sources are cited by standard editions; reception may
vary by translation, so locators (e.g. Stephanus pages, CP volume.paragraph) are given
where they anchor a specific claim.

## Philosophical primary sources

```bibtex
@book{plato_theaetetus,
  author    = {Plato},
  title     = {Theaetetus},
  note       = {Maieutics / midwife method, 148e--151d. Stephanus pagination},
  year      = {c. 369 BCE}
}

@book{descartes_discourse,
  author    = {Descartes, Ren\'e},
  title     = {Discourse on the Method},
  year      = {1637}
}

@book{descartes_meditations,
  author    = {Descartes, Ren\'e},
  title     = {Meditations on First Philosophy},
  year      = {1641}
}

@incollection{peirce_dih,
  author    = {Peirce, Charles Sanders},
  title     = {Deduction, Induction, and Hypothesis},
  booktitle = {Popular Science Monthly},
  volume    = {13},
  pages     = {470--482},
  year      = {1878}
}

@book{peirce_cp,
  author    = {Peirce, Charles Sanders},
  editor    = {Hartshorne, Charles and Weiss, Paul and Burks, Arthur W.},
  title     = {Collected Papers of Charles Sanders Peirce},
  publisher = {Harvard University Press},
  note       = {Abduction: CP 5.171, CP 5.180--5.212},
  year      = {1931--1958}
}

@book{dewey_htwt,
  author    = {Dewey, John},
  title     = {How We Think},
  publisher = {D. C. Heath},
  year      = {1910}
}

@book{dewey_logic,
  author    = {Dewey, John},
  title     = {Logic: The Theory of Inquiry},
  publisher = {Henry Holt and Company},
  year      = {1938}
}
```

## Method and design (supporting)

```bibtex
@book{toulmin_uses,
  author    = {Toulmin, Stephen E.},
  title     = {The Uses of Argument},
  publisher = {Cambridge University Press},
  year      = {1958}
}

@book{polya_htsi,
  author    = {P\'olya, George},
  title     = {How to Solve It},
  publisher = {Princeton University Press},
  year      = {1945}
}

@book{simon_sciences,
  author    = {Simon, Herbert A.},
  title     = {The Sciences of the Artificial},
  publisher = {MIT Press},
  year      = {1969}
}
```

## Large language models and reasoning scaffolds

```bibtex
@inproceedings{brown2020gpt3,
  author    = {Brown, Tom B. and others},
  title     = {Language Models are Few-Shot Learners},
  booktitle = {Advances in Neural Information Processing Systems (NeurIPS)},
  year      = {2020},
  note       = {arXiv:2005.14165}
}

@inproceedings{wei2022cot,
  author    = {Wei, Jason and Wang, Xuezhi and Schuurmans, Dale and Bosma, Maarten and Ichter, Brian and Xia, Fei and Chi, Ed and Le, Quoc and Zhou, Denny},
  title     = {Chain-of-Thought Prompting Elicits Reasoning in Large Language Models},
  booktitle = {Advances in Neural Information Processing Systems (NeurIPS)},
  year      = {2022},
  note       = {arXiv:2201.11903}
}

@inproceedings{yao2023react,
  author    = {Yao, Shunyu and Zhao, Jeffrey and Yu, Dian and Du, Nan and Shafran, Izhak and Narasimhan, Karthik and Cao, Yuan},
  title     = {ReAct: Synergizing Reasoning and Acting in Language Models},
  booktitle = {International Conference on Learning Representations (ICLR)},
  year      = {2023},
  note       = {arXiv:2210.03629}
}

@inproceedings{yao2023tot,
  author    = {Yao, Shunyu and Yu, Dian and Zhao, Jeffrey and Shafran, Izhak and Griffiths, Thomas L. and Cao, Yuan and Narasimhan, Karthik},
  title     = {Tree of Thoughts: Deliberate Problem Solving with Large Language Models},
  booktitle = {Advances in Neural Information Processing Systems (NeurIPS)},
  year      = {2023},
  note       = {arXiv:2305.10601}
}

@inproceedings{schick2023toolformer,
  author    = {Schick, Timo and Dwivedi-Yu, Jane and Dess\`i, Roberto and Raileanu, Roberta and Lomeli, Maria and Zettlemoyer, Luke and Cancedda, Nicola and Scialom, Thomas},
  title     = {Toolformer: Language Models Can Teach Themselves to Use Tools},
  booktitle = {Advances in Neural Information Processing Systems (NeurIPS)},
  year      = {2023},
  note       = {arXiv:2302.04761}
}
```

## Verification note

arXiv identifiers are given for the LLM works so each can be resolved at
`https://arxiv.org/abs/<id>`. Philosophical sources are widely available in standard
editions; locators are provided so a specific claim can be checked against the text
rather than the work as a whole.
