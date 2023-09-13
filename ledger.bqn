⟨Journal, ParseJournal, ParseJournalPrices⟩ ← •Import "parse.bqn"
⟨ProcessInput⟩ ← •Import "process_input.bqn"
⟨ReportBal⟩ ← •Import "report_bal.bqn"

input ← •FChars "test.ledger"

j‿k‿p ← ParseJournalPrices input

⟨com, bal, errs, prices⟩ ← ProcessInput j‿k‿p

# fields_ta ← ⟨"index", "date", "date_cleared", "status", "ta_code", "desc"⟩
# fields_posting ← ⟨"index", "account", "ac", "ac_price"⟩

ReportBal bal