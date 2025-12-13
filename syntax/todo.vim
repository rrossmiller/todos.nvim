" Checkbox patterns
syntax match todoUnchecked /-\s*\[\s*\]\s.*/ contains=todoBracket
syntax match todoChecked   /-\s*\[x\]\s.*/  contains=todoBracket

" Capture just the brackets
syntax match todoBracket /\[\s*\]/ contained
syntax match todoBracket /\[x\]/   contained

" Highlight rules
hi def link todoUnchecked Identifier
hi def link todoChecked   Comment

" Strike-through for completed
hi! todoChecked term=strikethrough cterm=strikethrough gui=strikethrough

syntax match todoIndent /^\s\{4}/
hi def link todoIndent Comment
