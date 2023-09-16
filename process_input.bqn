⟨ProcessInput⟩⇐

err ← "Error"
of ← 1‿0‿¯1

# Amounts to columns by commodity
AddCommodityCols ← {
    # commodity per TA
	t  ← ⊑¨2↓¨2⊏˘𝕩
	# unique commodities
	com ← ⍷t
	# amount array by commodities
	am ← (×´˘⊑˘2↑¨2↓˘𝕩)×t≡⌜com
	com‿am
}

RemCommodityCols ← {(<¨(≠𝕨)/1↑˘𝕩)∾¨⥊<¨(⟨≠𝕩, ≠𝕨⟩⥊1)∾¨(<¨⟨≠𝕩, ≠𝕨⟩⥊𝕨)∾¨(1↓˘𝕩)}
	
# Overflow rows for balancing
AddErrorRows ← {
    am‿j‿k :
	# empty TAs are used for balancing
	e ← 0=+´˘am
	# add empty posting fallback
	em ← (1↑˘j)(¬∘∊/⊣)(e/1↑˘k)
	# append fallback rows 
	t ← k∾(∾≍⟨em,(≠em)/≍⟨err, of, ⟨⟩⟩⟩)
	# put fallback rows to right index
	t⊏˜⍋({𝕩≡of}¨(2⊏˘t))+2×1↑˘t
}

# Find balancing errors
BalancingErrors ← {
    ⟨k, b⟩:
	# an error row may contain a currency exchange	
	e0 ← ({err≡𝕩}¨1⊏˘k)∧¬({0=+´𝕩}∧{2=+´|¨𝕩})˘×¨2↓˘b
	# an overflow row may contain one currency
	o0 ← {({of≡𝕩}¨2⊏˘k)∧¬{err≡𝕩}¨1⊏˘k}×¬({2>+´|¨𝕩})˘×¨2↓˘b
	m ← b/˜0<¨e0+o0
}

# match 𝕩 to 𝕨 based on id in first col of each
MatchFirst ← {⟨𝕨,𝕩⊏˜𝕨⊏○(⊑˘)𝕩⟩}
RemErrorRows ← {𝕩/˜{err≢𝕩}¨1⊏˘𝕩}

# add inverted sum of previous postings where sum of row is 0 (= virtual overflow posting)
BalanceTAs ← {am‿k0 : e ← 0=+´˘am ⋄ ∾≍⟨2↑˘k0, (--⟜»e/+`am)⌾(e⊸/)am⟩}

ExtractPrices ← {
    j‿com‿bal :
	# index of last posting per ta
	l ← 1⌾(¯1⊸⊑)<⟜«⥊1↑˘bal
	# balance tas
	c ← -⟜»l/+`2↓˘bal
	# two commodities in one posting
	i ← 2=+´˘0≠c
	# matching transaction data
	t ← 1⊑j MatchFirst˜ i/l/1↑˘bal
	# commodities
	cs ←(0≠i/c){𝕨/⊑𝕩}˘(+´i)⥊<com
	# amounts
	ams ← {h‿t : ¯1×t÷h}¨(1-˜0≠i/c)⊔˘i/c
	# build and return table
	d ← ∾≍⟨1⊑˘t, (+´i)‿1⥊<⟨00, 00⟩, cs, ams⟩
	↑‿4⥊{y‿m‿d‿t‿cf‿ct‿am : ⟨y, m, d⟩‿t‿⟨1, 1, cf⟩‿⟨1, am, ct⟩}˘d
}

# swap position of a/c and change base to new first a/c
ReversePrice ← {d‿t‿⟨fs, fa, fc⟩‿⟨ts, ta, tc⟩ : d‿t‿⟨ts, ta÷ta, tc⟩‿⟨fs, fa÷ta, fc⟩}

ProcessInput ← {
    j‿k‿p :
    com‿am ← AddCommodityCols k
	k0 ← AddErrorRows am‿j‿k
	com‿am ↩ AddCommodityCols k0
	bal ← BalanceTAs am‿k0
	errs ← ⍉∾⍉¨j MatchFirst˜ BalancingErrors k0‿bal
	bal ↩ RemErrorRows bal
	prices ← ∾⟜(ReversePrice˘) p∾ExtractPrices j‿com‿bal
	⟨com, bal, prices, errs⟩
}