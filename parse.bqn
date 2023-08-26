⟨Journal, ParseJournal, ParseJournalPrices⟩⇐

Flatten ← {(∾𝕊¨)⍟(1<≡)⥊𝕩}
Trim ← {(∨`∧∨`⌾⌽)' '≠𝕩}⊸/
RemEmpty ← {𝕩/˜0≠≠¨𝕩}

F ← {0⊑𝕩}
R ← {1↓𝕩}
E ← {""≡𝕩}

I    ← {⟨"", 𝕩⟩}
Fail ← {𝕤 ⋄ ⟨-1, ""⟩}
Any  ← {¬E 𝕩 ? ⟨F 𝕩, R 𝕩⟩ ; Fail 1}
Err  ← {⟨-1, ""⟩≡𝕩}

_and_ ← {m0‿r0 ← 𝔽 𝕩 ⋄ ¬Err m0‿r0 ? m1‿r1 ← 𝔾 r0 ⋄ {¬Err m1‿r1 ? ⟨⟨m0, m1⟩, r1⟩ ; Fail 1} ; Fail 1}
_or_  ← {r ← 𝔽 𝕩 ⋄ ¬Err r ? r ; 𝔾 𝕩}

_mb       ← {r ← 𝔽 𝕩 ⋄ ¬Err r ? r ; I 𝕩}
_mb_rep   ← {m‿r ← 𝔽 𝕩 ⋄ ¬Err m‿r ? m0‿r0 ← 𝕊 r ⋄ ⟨m∾m0, r0⟩; I 𝕩}
_rep      ← {m‿r ← 𝔽 𝕩 ⋄ ¬Err m‿r ? m0‿r0 ← 𝔽 _mb_rep r ⋄ ⟨m∾m0, r0⟩ ; Fail 1}
_rep_sep_ ← {𝔽 _and_ ((𝔾 _and_ 𝔽) _mb_rep)}

_tf       ← {¬Err 𝕩 ? m‿r ← 𝕩 ⋄ ⟨𝔽 m, r⟩ ; 𝕩}
Listify   ← {⟨e0, e⟩ : (<e0)∾e}

End     ← {E 𝕩 ? I 𝕩 ; Fail 1}

String  ← {𝕨≡(≠𝕨)↑𝕩 ? ⟨𝕨, (≠𝕨)↓𝕩⟩ ; Fail 1}

CC      ← {m‿r ← Any 𝕩 ⋄ (⊑m∊𝕨)∧¬Err m‿r ? m‿r ; Fail 1}
NotCC   ← {m‿r ← Any 𝕩 ⋄ (¬⊑m∊𝕨)∧¬Err m‿r ? m‿r ; Fail 1}
Until   ← {s ← (𝕨⍷𝕩)»0⥊˜≠𝕩 ⋄ ∨´s ? m‿r ← {𝕩⊔˜0<+`s} 𝕩 ⋄ ⟨m,r⟩; Fail 1}
Digit   ← {('0'+↕10) CC 𝕩}
Lower   ← {('a'+↕26) CC 𝕩}
Upper   ← {('A'+↕26) CC 𝕩}
Char    ← Upper _or_ Lower
Numeric ← {•ParseFloat 𝕩} _tf Digit _rep
Lf      ← "" _tf {⟨@+10⟩ CC 𝕩}
NotLF   ← {⟨@+10⟩ NotCC 𝕩}
LfOrEnd ← Lf _or_ End
Rest    ← {End _or_ (NotLF _mb_rep) 𝕩}

DecSep  ← {"." CC 𝕩}
Float   ← {•ParseFloat >Flatten 𝕩} _tf (Digit _rep) _and_ ((DecSep _and_ (Digit _rep)) _mb)

Space   ← {" " CC 𝕩}
DateSep ← {"/-." CC 𝕩}
Status  ← {"*!" CC 𝕩}
Eq      ← {"=" CC 𝕩}
Sign    ← {"-" CC 𝕩}
YMD     ← {⟨⟨⟨⟨y, ·⟩, m⟩, ·⟩, d⟩ : y‿m‿d} _tf Numeric _and_ DateSep _and_ Numeric _and_ DateSep _and_ Numeric

NoSpace  ← {(" "∾@+10) NotCC 𝕩}
Quote    ← {"""" CC 𝕩}
Enclosed ← {⟨⟨·, r⟩, ·⟩ : r} _tf Quote _and_ ({"""" NotCC 𝕩} _rep) _and_ Quote
TAcode   ← (Char _or_ Digit )_rep

EqYMDOpt  ← {1<≠𝕩 ? 1⊑𝕩 ; ""} _tf (Eq _and_ YMD) _mb
StatusOpt ← {0<≠𝕩 ? ⊑𝕩 ; ""} _tf (Status _and_ Space) _mb
TACodeOpt ← {0<≠𝕩 ? ⟨⟨⟨·, s⟩, ·⟩, ·⟩ ← 𝕩 ⋄ s ; ""} _tf ({"(" String 𝕩} _and_ TACode _and_ {")" String 𝕩} _and_ Space) _mb

NoComm ← {(";"∾@+10) NotCC 𝕩} _mb_rep
Comm   ← {0<≠𝕩 ? 1⊑𝕩 ; ""} _tf { ";" CC 𝕩} _and_ Rest

PHeader ← YMD _and_ EqYMDOpt _and_ Space _and_ StatusOpt _and_ TACodeOpt _and_ NoComm _and_ (Comm _mb)
Header  ← {⟨⟨⟨⟨⟨⟨y, y1⟩, ·⟩, s⟩, t⟩, c⟩, ·⟩ : ⟨y, y1, s, t, c⟩} _tf PHeader

Num          ← Float _or_ Numeric
Symb         ← {("0123456789-.@; """∾@+10) NotCC 𝕩}
Symbs        ← Symb _rep
Spaces       ← Space _rep
#SymbsSpaces  ← Flatten _tf Symbs _and_ ((Spaces _and_ Symbs) _mb_rep)
Com          ← Symbs _or_ Enclosed
SpaceMB      ← "" _tf Space _mb
# Box the return since -1 is valid
SignsSpaceMB ← {⟨n, ·⟩ : <¯1⋆≠n} _tf ((Sign _mb_rep) _and_ (Space _mb_rep))

AmountSNC   ← {⟨⟨⟨s, a⟩, ·⟩, c⟩ : ⟨⊑s, a, c⟩} _tf SignsSpaceMB _and_ Num _and_ SpaceMB _and_ Com
AmountSCN   ← {⟨⟨⟨s, c⟩, ·⟩, a⟩ : ⟨⊑s, a, c⟩} _tf SignsSpaceMB _and_ (Com _mb) _and_ SpaceMB _and_ Num
AmountCSN   ← {⟨⟨⟨⟨c, ·⟩, s⟩, ·⟩, a⟩ : ⟨⊑s, a, c⟩} _tf (Com _mb) _and_ SpaceMB _and_ SignsSpaceMB _and_ SpaceMB _and_ Num
Amount      ← AmountSNC _or_ AmountSCN _or_ AmountCSN
PriceAmount ← {⟨⟨⟨·, t⟩, ·⟩, a⟩ : ⋄ ⟨t, a⟩} _tf (Spaces _and_ ({"@@" String 𝕩} _or_ {"@" String 𝕩}) _and_ Spaces _and_ Amount)

Comment  ← ⟨"c"⟩ _tf Space _mb_rep _and_ Comm

Account       ← ⊑ _tf (Listify _tf ((Symb _rep) _rep_sep_ {":" String 𝕩}))

PostingAmount ← {⟨⟨⟨⟨acc, ·⟩, ·⟩, am⟩, am0⟩ : ⋄ ⟨Trim acc, am, am0⟩} _tf (Account _and_ Space _and_ Spaces _and_ Amount _and_ (PriceAmount _mb))
PostingCom    ← "" _tf Comm
PostingEmpty  ← {⟨Trim 𝕩, ⟨1, 0, -1⟩, ⟨⟩⟩} _tf Rest
Posting       ← {⟨·, r⟩ : r} _tf Spaces _and_ (PostingAmount _or_ PostingCom _or_ PostingEmpty)
Postings      ← RemEmpty _tf (Listify _tf (Posting _rep_sep_ Lf))

EmptyLine    ← "c" _tf Space _mb_rep
Entry        ← {⟨⟨⟨h, ·⟩, p⟩, ·⟩ : ⟨"e", ⟨⟨h, p⟩⟩⟩} _tf Header _and_ Lf _and_ Postings _and_ ((Lf _and_ EmptyLine) _or_ End)
Include      ← {⟨·, f⟩ : ⋄ ⟨"i", ⊑Journal •FChars f⟩} _tf ({"include " String 𝕩} _and_ Rest)
PriceLine    ← {⟨⟨⟨⟨⟨·, d⟩, ·⟩, c⟩, ·⟩, n⟩: ⟨"p", ⟨d, ⟨00, 00⟩, c, n⟩⟩} _tf {"P " String 𝕩} _and_ YMD _and_ Spaces _and_ Com _and_ Spaces _and_ Amount
JournalEntry ← Include _or_ Entry _or_ PriceLine _or_ Comment

Journal       ← {⟨h, t⟩: (<h)∾∾´<¨t} _tf (JournalEntry _rep_sep_ ((EmptyLine _and_ Lf) _mb_rep))
KeepEntries   ← {⊑¨⊑¨1↓¨𝕩/˜(⊑¨𝕩)∊"e"‿"i"}
KeepPrices    ← {⊑¨1↓¨𝕩/˜(⊑¨𝕩)∊⋈"p"}
JournalMatrix ← {(>(↕≠𝕩)∾¨0⊑¨𝕩)‿(>((↕≠𝕩)/˜≠¨1⊑¨𝕩)∾¨∾1⊑¨𝕩)}
ParseJournal  ← {JournalMatrix KeepEntries ⊑Journal 𝕩}
ParseJournalPrices ← {j ← Journal 𝕩 ⋄ (JournalMatrix KeepEntries ⊑j)∾<>KeepPrices ⊑j}
