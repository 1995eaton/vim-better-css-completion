" Vim completion script
" Language:	CSS 3
" Maintainer:	Jake Eaton (1995eaton@gmail.com)
" Last Change:	2014 Jun 23
" Previous Maintainer: Mikolaj Machowski ( mikmach AT wp DOT pl )

  let s:colors = split("rgba( rgb( aqua black blue fuchsia gray green lime maroon navy olive orange purple red silver teal white yellow transparent currentcolor grey aliceblue antiquewhite aquamarine azure beige bisque blanchedalmond blueviolet brown burlywood cadetblue chartreuse chocolate coral cornflowerblue cornsilk crimson cyan darkblue darkcyan darkgoldenrod darkgray darkgreen darkgrey darkkhaki darkmagenta darkolivegreen darkorange darkorchid darkred darksalmon darkseagreen darkslateblue darkslategray darkslategrey darkturquoise darkviolet deeppink deepskyblue dimgray dimgrey dodgerblue firebrick floralwhite forestgreen gainsboro ghostwhite gold goldenrod greenyellow honeydew hotpink indianred indigo ivory khaki lavender lavenderblush lawngreen lemonchiffon lightblue lightcoral lightcyan lightgoldenrodyellow lightgray lightgreen lightgrey lightpink lightsalmon lightseagreen lightskyblue lightslategray lightslategrey lightsteelblue lightyellow limegreen linen magenta mediumaquamarine mediumblue mediumorchid mediumpurple mediumseagreen mediumslateblue mediumspringgreen mediumturquoise mediumvioletred midnightblue mintcream mistyrose moccasin navajowhite oldlace olivedrab orangered orchid palegoldenrod palegreen paleturquoise palevioletred papayawhip peachpuff peru pink plum powderblue rosybrown royalblue saddlebrown salmon sandybrown seagreen seashell sienna skyblue slateblue slategray slategrey snow springgreen steelblue tan thistle tomato turquoise violet wheat whitesmoke yellowgreen")
let s:values = split("a abbr acronym address applet area article aside audio b base basefont bdi bdo bgsound big blink blockquote body br button canvas caption center cite code col colgroup content data datalist dd decorator del details dfn dialog dir div dl dt element em embed fieldset figcaption figure font footer form frame frameset h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins isindex kbd keygen label legend li link listing main map mark marquee menu menuitem meta meter nav nobr noframes noscript object ol optgroup option output p param plaintext pre progress q rp rt ruby s samp script section select shadow small source spacer span strike strong style sub summary sup table tbody td template textarea tfoot th thead time title title tr track tt u ul var video wbr xmp table-layout visibility background-repeat content list-style-image clear text-underline-mode overflow-x stroke-linejoin baseline-shift border-bottom-width marquee-speed margin-top-collapse max-height box-orient font-stretch text-underline-style text-overline-mode -webkit-background-composite border-left-width box-shadow -webkit-writing-mode text-line-through-mode border-collapse page-break-inside border-top-width outline-color text-line-through-style outline-style cursor border-width border-style size background-size direction marquee-direction enable-background float overflow-y margin-bottom-collapse box-reflect overflow text-rendering text-align list-style-position margin-bottom color-interpolation background-origin word-wrap font-weight margin-before-collapse text-overline-width text-transform border-right-style border-left-style -webkit-text-emphasis font-style speak color-rendering list-style-type -webkit-text-combine outline font dominant-baseline display -webkit-text-emphasis-position image-rendering alignment-baseline outline-width text-line-through-width box-align border-right-width border-top-style line-height text-overflow overflow-wrap box-direction margin-after-collapse page-break-before border-image text-decoration position font-family text-overflow-mode border-bottom-style unicode-bidi clip-rule margin-left margin-top zoom text-overline-style max-width caption-side empty-cells pointer-events letter-spacing background-clip -webkit-font-smoothing border font-size font-variant vertical-align marquee-style white-space text-underline-width box-lines page-break-after clip-path margin marquee-repetition margin-right word-break word-spacing -webkit-text-emphasis-style -webkit-transform image-resolution box-sizing clip resize align-content align-items align-self flex-direction justify-content flex-wrap -webkit-animation-timing-function -webkit-animation-direction -webkit-animation-play-state -webkit-animation-fill-mode -webkit-backface-visibility -webkit-box-decoration-break -webkit-column-break-after -webkit-column-break-before -webkit-column-break-inside -webkit-column-span -webkit-column-count -webkit-column-gap -webkit-line-break -webkit-perspective -webkit-perspective-origin text-align-last -webkit-text-decoration-line -webkit-text-decoration-style -webkit-text-decoration-skip -webkit-transform-origin -webkit-transform-style -webkit-transition-timing-function -webkit-flex -webkit-flex-basis -webkit-flex-flow -webkit-flex-grow -webkit-flex-shrink -webkit-animation -webkit-animation-delay -webkit-animation-duration -webkit-animation-iteration-count -webkit-animation-name -webkit-column-rule -webkit-column-rule-color -webkit-column-rule-style -webkit-column-rule-width -webkit-column-width -webkit-columns -webkit-order -webkit-text-decoration-color -webkit-text-emphasis-color -webkit-transition -webkit-transition-delay -webkit-transition-duration -webkit-transition-property background background-attachment background-color background-image background-position background-position-x background-position-y background-repeat-x background-repeat-y border-top border-right border-bottom border-left border-radius bottom color counter-increment counter-reset grid-template-columns grid-template-rows height image-orientation left list-style min-height min-width opacity orphans outline-offset padding padding-bottom padding-left padding-right padding-top page quotes right tab-size text-indent text-shadow top unicode-range widows width z-index")

function! csscomplete#CompleteCSS(findstart, base)

if a:findstart
	" We need whole line to proper checking
	let line = getline('.')
	let start = col('.') - 1
	let compl_begin = col('.') - 2
	while start >= 0 && line[start - 1] =~ '\%(\k\|-\)'
		let start -= 1
	endwhile
	let b:compl_context = line[0:compl_begin]
	return start
endif

" There are few chars important for context:
" ^ ; : { } /* */
" Where ^ is start of line and /* */ are comment borders
" Depending on their relative position to cursor we will know what should
" be completed. 
" 1. if nearest are ^ or { or ; current word is property
" 2. if : it is value (with exception of pseudo things)
" 3. if } we are outside of css definitions
" 4. for comments ignoring is be the easiest but assume they are the same
"    as 1. 
" 5. if @ complete at-rule
" 6. if ! complete important
if exists("b:compl_context")
	let line = b:compl_context
	unlet! b:compl_context
else
	let line = a:base
endif

let res = []
let res2 = []
let borders = {}

" Check last occurrence of sequence

let openbrace  = strridx(line, '{')
let closebrace = strridx(line, '}')
let colon      = strridx(line, ':')
let semicolon  = strridx(line, ';')
let opencomm   = strridx(line, '/*')
let closecomm  = strridx(line, '*/')
let style      = strridx(line, 'style\s*=')
let atrule     = strridx(line, '@')
let exclam     = strridx(line, '!')

if openbrace > -1
	let borders[openbrace] = "openbrace"
endif
if closebrace > -1
	let borders[closebrace] = "closebrace"
endif
if colon > -1
	let borders[colon] = "colon"
endif
if semicolon > -1
	let borders[semicolon] = "semicolon"
endif
if opencomm > -1
	let borders[opencomm] = "opencomm"
endif
if closecomm > -1
	let borders[closecomm] = "closecomm"
endif
if style > -1
	let borders[style] = "style"
endif
if atrule > -1
	let borders[atrule] = "atrule"
endif
if exclam > -1
	let borders[exclam] = "exclam"
endif


if len(borders) == 0 || borders[max(keys(borders))] =~ '^\%(openbrace\|semicolon\|opencomm\|closecomm\|style\)$'
	" Complete properties


	let entered_property = matchstr(line, '.\{-}\zs[a-zA-Z-]*$')

	for m in s:values
		if m =~? '^'.entered_property
			call add(res, m . ':')
		elseif m =~? entered_property
			call add(res2, m . ':')
		endif
	endfor

	return res + res2

elseif borders[max(keys(borders))] == 'colon'
	" Get name of property
	let prop = tolower(matchstr(line, '\zs[a-zA-Z-]*\ze\s*:[^:]\{-}$'))

  if prop == 'table-layout'
    let values = ['auto', 'fixed']
  elseif prop == 'visibility'
    let values = ['hidden', 'visible', 'collapse']
  elseif prop == 'background-repeat'
    let values = ['repeat', 'repeat-x', 'repeat-y', 'no-repeat', 'space', 'round']
  elseif prop == 'content'
    let values = ['list-item', 'close-quote', 'no-close-quote', 'no-open-quote', 'open-quote']
  elseif prop == 'list-style-image'
    let values = ['url(', 'none']
  elseif prop == 'clear'
    let values = ['none', 'left', 'right', 'both']
  elseif prop == 'text-underline-mode'
    let values = ['continuous', 'skip-white-space']
  elseif prop == 'overflow-x'
    let values = ['hidden', 'auto', 'visible', 'overlay', 'scroll']
  elseif prop == 'stroke-linejoin'
    let values = ['round', 'miter', 'bevel']
  elseif prop == 'baseline-shift'
    let values = ['baseline', 'sub', 'super']
  elseif prop == 'border-bottom-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'marquee-speed'
    let values = ['normal', 'slow', 'fast']
  elseif prop == 'margin-top-collapse'
    let values = ['collapse', 'separate', 'discard']
  elseif prop == 'max-height'
    let values = ['none']
  elseif prop == 'box-orient'
    let values = ['horizontal', 'vertical', 'inline-axis', 'block-axis']
  elseif prop == 'font-stretch'
    let values = ['normal', 'wider', 'narrower', 'ultra-condensed', 'extra-condensed', 'condensed', 'semi-condensed', 'semi-expanded', 'expanded', 'extra-expanded', 'ultra-expanded']
  elseif prop == 'text-underline-style'
    let values = ['none', 'dotted', 'dashed', 'solid', 'double', 'dot-dash', 'dot-dot-dash', 'wave']
  elseif prop == 'text-overline-mode'
    let values = ['continuous', 'skip-white-space']
  elseif prop == '-webkit-background-composite'
    let values = ['highlight', 'clear', 'copy', 'source-over', 'source-in', 'source-out', 'source-atop', 'destination-over', 'destination-in', 'destination-out', 'destination-atop', 'xor', 'plus-darker', 'plus-lighter']
  elseif prop == 'border-left-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'box-shadow'
    let values = ['inset', 'none']
  elseif prop == '-webkit-writing-mode'
    let values = ['lr', 'rl', 'tb', 'lr-tb', 'rl-tb', 'tb-rl', 'horizontal-tb', 'vertical-rl', 'vertical-lr', 'horizontal-bt']
  elseif prop == 'text-line-through-mode'
    let values = ['continuous', 'skip-white-space']
  elseif prop == 'border-collapse'
    let values = ['collapse', 'separate']
  elseif prop == 'page-break-inside'
    let values = ['auto', 'avoid']
  elseif prop == 'border-top-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'outline-color'
    let values = ['invert']
  elseif prop == 'text-line-through-style'
    let values = ['none', 'dotted', 'dashed', 'solid', 'double', 'dot-dash', 'dot-dot-dash', 'wave']
  elseif prop == 'outline-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == 'cursor'
    let values = ['none', 'copy', 'auto', 'crosshair', 'default', 'pointer', 'move', 'vertical-text', 'cell', 'context-menu', 'alias', 'progress', 'no-drop', 'not-allowed', '-webkit-zoom-in', '-webkit-zoom-out', 'e-resize', 'ne-resize', 'nw-resize', 'n-resize', 'se-resize', 'sw-resize', 's-resize', 'w-resize', 'ew-resize', 'ns-resize', 'nesw-resize', 'nwse-resize', 'col-resize', 'row-resize', 'text', 'wait', 'help', 'all-scroll', '-webkit-grab', '-webkit-grabbing', 'url(']
  elseif prop == 'border-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'border-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == 'size'
    let values = ['a3', 'a4', 'a5', 'b4', 'b5', 'landscape', 'ledger', 'legal', 'letter', 'portrait']
  elseif prop == 'background-size'
    let values = ['contain', 'cover']
  elseif prop == 'direction'
    let values = ['ltr', 'rtl']
  elseif prop == 'marquee-direction'
    let values = ['left', 'right', 'auto', 'reverse', 'forwards', 'backwards', 'ahead', 'up', 'down']
  elseif prop == 'enable-background'
    let values = ['accumulate', 'new']
  elseif prop == 'float'
    let values = ['none', 'left', 'right']
  elseif prop == 'overflow-y'
    let values = ['hidden', 'auto', 'visible', 'overlay', 'scroll']
  elseif prop == 'margin-bottom-collapse'
    let values = ['collapse', 'separate', 'discard']
  elseif prop == 'box-reflect'
    let values = ['left', 'right', 'above', 'below']
  elseif prop == 'overflow'
    let values = ['hidden', 'auto', 'visible', 'overlay', 'scroll']
  elseif prop == 'text-rendering'
    let values = ['auto', 'optimizeSpeed', 'optimizeLegibility', 'geometricPrecision']
  elseif prop == 'text-align'
    let values = ['-webkit-auto', 'start', 'end', 'left', 'right', 'center', 'justify', '-webkit-left', '-webkit-right', '-webkit-center']
  elseif prop == 'list-style-position'
    let values = ['outside', 'inside', 'hanging']
  elseif prop == 'margin-bottom'
    let values = ['auto']
  elseif prop == 'color-interpolation'
    let values = ['linearrgb']
  elseif prop == 'background-origin'
    let values = ['border-box', 'content-box', 'padding-box']
  elseif prop == 'word-wrap'
    let values = ['normal', 'break-word']
  elseif prop == 'font-weight'
    let values = ['normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900']
  elseif prop == 'margin-before-collapse'
    let values = ['collapse', 'separate', 'discard']
  elseif prop == 'text-overline-width'
    let values = ['normal', 'medium', 'auto', 'thick', 'thin']
  elseif prop == 'text-transform'
    let values = ['none', 'capitalize', 'uppercase', 'lowercase']
  elseif prop == 'border-right-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == 'border-left-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == '-webkit-text-emphasis'
    let values = ['circle', 'filled', 'open', 'dot', 'double-circle', 'triangle', 'sesame']
  elseif prop == 'font-style'
    let values = ['italic', 'oblique', 'normal']
  elseif prop == 'speak'
    let values = ['none', 'normal', 'spell-out', 'digits', 'literal-punctuation', 'no-punctuation']
  elseif prop == 'color-rendering'
    let values = ['auto', 'optimizeSpeed', 'optimizeQuality']
  elseif prop == 'list-style-type'
    let values = ['none', 'inline', 'disc', 'circle', 'square', 'decimal', 'decimal-leading-zero', 'arabic-indic', 'binary', 'bengali', 'cambodian', 'khmer', 'devanagari', 'gujarati', 'gurmukhi', 'kannada', 'lower-hexadecimal', 'lao', 'malayalam', 'mongolian', 'myanmar', 'octal', 'oriya', 'persian', 'urdu', 'telugu', 'tibetan', 'thai', 'upper-hexadecimal', 'lower-roman', 'upper-roman', 'lower-greek', 'lower-alpha', 'lower-latin', 'upper-alpha', 'upper-latin', 'afar', 'ethiopic-halehame-aa-et', 'ethiopic-halehame-aa-er', 'amharic', 'ethiopic-halehame-am-et', 'amharic-abegede', 'ethiopic-abegede-am-et', 'cjk-earthly-branch', 'cjk-heavenly-stem', 'ethiopic', 'ethiopic-halehame-gez', 'ethiopic-abegede', 'ethiopic-abegede-gez', 'hangul-consonant', 'hangul', 'lower-norwegian', 'oromo', 'ethiopic-halehame-om-et', 'sidama', 'ethiopic-halehame-sid-et', 'somali', 'ethiopic-halehame-so-et', 'tigre', 'ethiopic-halehame-tig', 'tigrinya-er', 'ethiopic-halehame-ti-er', 'tigrinya-er-abegede', 'ethiopic-abegede-ti-er', 'tigrinya-et', 'ethiopic-halehame-ti-et', 'tigrinya-et-abegede', 'ethiopic-abegede-ti-et', 'upper-greek', 'upper-norwegian', 'asterisks', 'footnotes', 'hebrew', 'armenian', 'lower-armenian', 'upper-armenian', 'georgian', 'cjk-ideographic', 'hiragana', 'katakana', 'hiragana-iroha', 'katakana-iroha']
  elseif prop == '-webkit-text-combine'
    let values = ['none', 'horizontal']
  elseif prop == 'outline'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9,()#]\+\)\?$'
			let values = ["rgb(", "#"]
		elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+\%([a-zA-Z]\+\)\?$'
      let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
		elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		else
			return []
		endif
  elseif prop == 'font'
    let values = ['caption', 'icon', 'menu', 'message-box', 'small-caption', '-webkit-mini-control', '-webkit-small-control', '-webkit-control', 'status-bar', 'italic', 'oblique', 'small-caps', 'normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900', 'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large', '-webkit-xxx-large', 'smaller', 'larger', 'serif', 'sans-serif', 'cursive', 'fantasy', 'monospace', '-webkit-body', '-webkit-pictograph']
  elseif prop == 'dominant-baseline'
    let values = ['middle', 'auto', 'central', 'text-before-edge', 'text-after-edge', 'ideographic', 'alphabetic', 'hanging', 'mathematical', 'use-script', 'no-change', 'reset-size']
  elseif prop == 'display'
    let values = ['none', 'inline', 'block', 'list-item', 'run-in', 'compact', 'inline-block', 'table', 'inline-table', 'table-row-group', 'table-header-group', 'table-footer-group', 'table-row', 'table-column-group', 'table-column', 'table-cell', 'table-caption', '-webkit-box', '-webkit-inline-box', 'flex', 'inline-flex', 'grid', 'inline-grid']
  elseif prop == '-webkit-text-emphasis-position'
    let values = ['over', 'under']
  elseif prop == 'image-rendering'
    let values = ['auto', 'optimizeSpeed', 'optimizeQuality']
  elseif prop == 'alignment-baseline'
    let values = ['baseline', 'middle', 'auto', 'before-edge', 'after-edge', 'central', 'text-before-edge', 'text-after-edge', 'ideographic', 'alphabetic', 'hanging', 'mathematical']
  elseif prop == 'outline-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'text-line-through-width'
    let values = ['normal', 'medium', 'auto', 'thick', 'thin']
  elseif prop == 'box-align'
    let values = ['baseline', 'center', 'stretch', 'start', 'end']
  elseif prop == 'border-right-width'
    let values = ['medium', 'thick', 'thin']
  elseif prop == 'border-top-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == 'line-height'
    let values = ['normal']
  elseif prop == 'text-overflow'
    let values = ['clip', 'ellipsis']
  elseif prop == 'overflow-wrap'
    let values = ['normal', 'break-word']
  elseif prop == 'box-direction'
    let values = ['normal', 'reverse']
  elseif prop == 'margin-after-collapse'
    let values = ['collapse', 'separate', 'discard']
  elseif prop == 'page-break-before'
    let values = ['left', 'right', 'auto', 'always', 'avoid']
  elseif prop == 'border-image'
    let values = ['repeat', 'stretch']
  elseif prop == 'text-decoration'
    let values = ['blink', 'line-through', 'overline', 'underline']
  elseif prop == 'position'
    let values = ['absolute', 'fixed', 'relative', 'static']
  elseif prop == 'font-family'
    let values = ['serif', 'sans-serif', 'cursive', 'fantasy', 'monospace', '-webkit-body', '-webkit-pictograph']
  elseif prop == 'text-overflow-mode'
    let values = ['clip', 'ellipsis']
  elseif prop == 'border-bottom-style'
    let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
  elseif prop == 'unicode-bidi'
    let values = ['normal', 'bidi-override', 'embed', 'isolate', 'isolate-override', 'plaintext']
  elseif prop == 'clip-rule'
    let values = ['nonzero', 'evenodd']
  elseif prop == 'margin-left'
    let values = ['auto']
  elseif prop == 'margin-top'
    let values = ['auto']
  elseif prop == 'zoom'
    let values = ['normal', 'document', 'reset']
  elseif prop == 'text-overline-style'
    let values = ['none', 'dotted', 'dashed', 'solid', 'double', 'dot-dash', 'dot-dot-dash', 'wave']
  elseif prop == 'max-width'
    let values = ['none']
  elseif prop == 'caption-side'
    let values = ['top', 'bottom']
  elseif prop == 'empty-cells'
    let values = ['hide', 'show']
  elseif prop == 'pointer-events'
    let values = ['none', 'all', 'auto', 'visible', 'visiblepainted', 'visiblefill', 'visiblestroke', 'painted', 'fill', 'stroke', 'bounding-box']
  elseif prop == 'letter-spacing'
    let values = ['normal']
  elseif prop == 'background-clip'
    let values = ['border-box', 'content-box', 'padding-box']
  elseif prop == '-webkit-font-smoothing'
    let values = ['none', 'auto', 'antialiased', 'subpixel-antialiased']
  elseif prop == 'border'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
      let values = ['none', 'hidden', 'inset', 'groove', 'ridge', 'outset', 'dotted', 'dashed', 'solid', 'double']
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = s:colors
		else
			return []
		endif
  elseif prop == 'font-size'
    let values = ['xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large', '-webkit-xxx-large', 'smaller', 'larger']
  elseif prop == 'font-variant'
    let values = ['small-caps', 'normal']
  elseif prop == 'vertical-align'
    let values = ['baseline', 'middle', 'sub', 'super', 'text-top', 'text-bottom', 'top', 'bottom', '-webkit-baseline-middle']
  elseif prop == 'marquee-style'
    let values = ['none', 'scroll', 'slide', 'alternate']
  elseif prop == 'white-space'
    let values = ['normal', 'nowrap', 'pre', 'pre-line', 'pre-wrap']
  elseif prop == 'text-underline-width'
    let values = ['normal', 'medium', 'auto', 'thick', 'thin']
  elseif prop == 'box-lines'
    let values = ['single', 'multiple']
  elseif prop == 'page-break-after'
    let values = ['left', 'right', 'auto', 'always', 'avoid']
  elseif prop == 'clip-path'
    let values = ['none']
  elseif prop == 'margin'
    let values = ['auto']
  elseif prop == 'marquee-repetition'
    let values = ['infinite']
  elseif prop == 'margin-right'
    let values = ['auto']
  elseif prop == 'word-break'
    let values = ['normal', 'break-all', 'break-word']
  elseif prop == 'word-spacing'
    let values = ['normal']
  elseif prop == '-webkit-text-emphasis-style'
    let values = ['circle', 'filled', 'open', 'dot', 'double-circle', 'triangle', 'sesame']
  elseif prop == '-webkit-transform'
    let values = ['scale', 'scaleX', 'scaleY', 'scale3d', 'rotate', 'rotateX', 'rotateY', 'rotateZ', 'rotate3d', 'skew', 'skewX', 'skewY', 'translate', 'translateX', 'translateY', 'translateZ', 'translate3d', 'matrix', 'matrix3d', 'perspective']
  elseif prop == 'image-resolution'
    let values = ['from-image', 'snap']
  elseif prop == 'box-sizing'
    let values = ['content-box', 'padding-box', 'border-box']
  elseif prop == 'clip'
    let values = ['auto']
  elseif prop == 'resize'
    let values = ['none', 'both', 'horizontal', 'vertical']
  elseif prop == 'align-content'
    let values = ['flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch']
  elseif prop == 'align-items'
    let values = ['flex-start', 'flex-end', 'center', 'baseline', 'stretch']
  elseif prop == 'align-self'
    let values = ['auto', 'flex-start', 'flex-end', 'center', 'baseline', 'stretch']
  elseif prop == 'flex-direction'
    let values = ['row', 'row-reverse', 'column', 'column-reverse']
  elseif prop == 'justify-content'
    let values = ['flex-start', 'flex-end', 'center', 'space-between', 'space-around']
  elseif prop == 'flex-wrap'
    let values = ['nowrap', 'wrap', 'wrap-reverse']
  elseif prop == '-webkit-animation-timing-function'
    let values = ['ease', 'linear', 'ease-in', 'ease-out', 'ease-in-out', 'step-start', 'step-end', 'steps', 'cubic-bezier']
  elseif prop == '-webkit-animation-direction'
    let values = ['normal', 'reverse', 'alternate', 'alternate-reverse']
  elseif prop == '-webkit-animation-play-state'
    let values = ['running', 'paused']
  elseif prop == '-webkit-animation-fill-mode'
    let values = ['none', 'forwards', 'backwards', 'both']
  elseif prop == '-webkit-backface-visibility'
    let values = ['visible', 'hidden']
  elseif prop == '-webkit-box-decoration-break'
    let values = ['slice', 'clone']
  elseif prop == '-webkit-column-break-after'
    let values = ['auto', 'always', 'avoid', 'left', 'right', 'page', 'column', 'avoid-page', 'avoid-column']
  elseif prop == '-webkit-column-break-before'
    let values = ['auto', 'always', 'avoid', 'left', 'right', 'page', 'column', 'avoid-page', 'avoid-column']
  elseif prop == '-webkit-column-break-inside'
    let values = ['auto', 'avoid', 'avoid-page', 'avoid-column']
  elseif prop == '-webkit-column-span'
    let values = ['none', 'all']
  elseif prop == '-webkit-column-count'
    let values = ['auto']
  elseif prop == '-webkit-column-gap'
    let values = ['normal']
  elseif prop == '-webkit-line-break'
    let values = ['auto', 'loose', 'normal', 'strict']
  elseif prop == '-webkit-perspective'
    let values = ['none']
  elseif prop == '-webkit-perspective-origin'
    let values = ['left', 'center', 'right', 'top', 'bottom']
  elseif prop == 'text-align-last'
    let values = ['auto', 'start', 'end', 'left', 'right', 'center', 'justify']
  elseif prop == '-webkit-text-decoration-line'
    let values = ['none', 'underline', 'overline', 'line-through', 'blink']
  elseif prop == '-webkit-text-decoration-style'
    let values = ['solid', 'double', 'dotted', 'dashed', 'wavy']
  elseif prop == '-webkit-text-decoration-skip'
    let values = ['none', 'objects', 'spaces', 'ink', 'edges', 'box-decoration']
  elseif prop == '-webkit-transform-origin'
    let values = ['left', 'center', 'right', 'top', 'bottom']
  elseif prop == '-webkit-transform-style'
    let values = ['flat', 'preserve-3d']
  elseif prop == '-webkit-transition-timing-function'
    let values = ['ease', 'linear', 'ease-in', 'ease-out', 'ease-in-out', 'step-start', 'step-end', 'steps', 'cubic-bezier']
  elseif prop == '-webkit-flex'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-flex-basis'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-flex-flow'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-flex-grow'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-flex-shrink'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-animation'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-animation-delay'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-animation-duration'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-animation-iteration-count'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-animation-name'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-column-rule'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-column-rule-color'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-column-rule-style'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-column-rule-width'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-column-width'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-columns'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-order'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-text-decoration-color'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-text-emphasis-color'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-transition'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-transition-delay'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-transition-duration'
    let values = ['initial', 'inherit']
  elseif prop == '-webkit-transition-property'
    let values = ['initial', 'inherit']
  elseif prop == 'background'
		let values = ["url(", "scroll", "fixed", "transparent", "rgb(", "#", "none", "top", "center", "bottom" , "left", "right", "repeat", "repeat-x", "repeat-y", "no-repeat"] + s:colors
  elseif prop == 'background-attachment'
    let values = s:colors
  elseif prop == 'background-color'
    let values = s:colors
  elseif prop == 'background-image'
    let values = ['url(', 'none']
  elseif prop =~ 'background-position'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z]\+\)\?$'
			let values = ["top", "center", "bottom"]
		elseif vals =~ '^[a-zA-Z]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["left", "center", "right"]
		else
			return []
		endif
  elseif prop == 'background-repeat-x'
    let values = s:colors
  elseif prop == 'background-repeat-y'
    let values = s:colors
	elseif prop =~ 'border-\%(top\|right\|bottom\|left\)$'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = s:colors
		else
			return []
		endif
  elseif prop == 'bottom'
    let values = ['initial', 'inherit']
  elseif prop == 'color'
    let values = ['initial', 'inherit']
  elseif prop == 'counter-increment'
    let values = ['initial', 'inherit']
  elseif prop == 'counter-reset'
    let values = ['initial', 'inherit']
  elseif prop == 'grid-template-columns'
    let values = ['initial', 'inherit']
  elseif prop == 'grid-template-rows'
    let values = ['initial', 'inherit']
  elseif prop == 'height'
    let values = ['initial', 'inherit']
  elseif prop == 'image-orientation'
    let values = ['initial', 'inherit']
  elseif prop == 'left'
    let values = ['initial', 'inherit']
  elseif prop == 'list-style'
    let values = ['initial', 'inherit']
  elseif prop == 'min-height'
    let values = ['initial', 'inherit']
  elseif prop == 'min-width'
    let values = ['initial', 'inherit']
  elseif prop == 'opacity'
    let values = ['initial', 'inherit']
  elseif prop == 'orphans'
    let values = ['initial', 'inherit']
  elseif prop == 'outline-offset'
    let values = ['initial', 'inherit']
  elseif prop == 'padding'
    let values = ['initial', 'inherit']
  elseif prop == 'padding-bottom'
    let values = ['initial', 'inherit']
  elseif prop == 'padding-left'
    let values = ['initial', 'inherit']
  elseif prop == 'padding-right'
    let values = ['initial', 'inherit']
  elseif prop == 'padding-top'
    let values = ['initial', 'inherit']
  elseif prop == 'page'
    let values = ['initial', 'inherit']
  elseif prop == 'quotes'
    let values = ['initial', 'inherit']
  elseif prop == 'right'
    let values = ['initial', 'inherit']
  elseif prop == 'tab-size'
    let values = ['initial', 'inherit']
  elseif prop == 'text-indent'
    let values = ['initial', 'inherit']
  elseif prop == 'text-shadow'
    let values = ['initial', 'inherit']
  elseif prop == 'top'
    let values = ['initial', 'inherit']
  elseif prop == 'unicode-range'
    let values = ['initial', 'inherit']
  elseif prop == 'widows'
    let values = ['initial', 'inherit']
  elseif prop == 'width'
    let values = ['initial', 'inherit']
  elseif prop == 'z-index'
    let values = ['initial', 'inherit']
	else
		" If no property match it is possible we are outside of {} and
		" trying to complete pseudo-(class|element)
		let element = tolower(matchstr(line, '\zs[a-zA-Z1-6]*\ze:[^:[:space:]]\{-}$'))
		if stridx(',a,abbr,acronym,address,applet,area,article,aside,audio,b,base,basefont,bdi,bdo,bgsound,big,blink,blockquote,body,br,button,canvas,caption,center,cite,code,col,colgroup,content,data,datalist,dd,decorator,del,details,dfn,dialog,dir,div,dl,dt,element,em,embed,fieldset,figcaption,figure,font,footer,form,frame,frameset,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,i,iframe,img,input,ins,isindex,kbd,keygen,label,legend,li,link,listing,main,map,mark,marquee,menu,menuitem,meta,meter,nav,nobr,noframes,noscript,object,ol,optgroup,option,output,p,param,plaintext,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,shadow,small,source,spacer,span,strike,strong,style,sub,summary,sup,table,tbody,td,template,textarea,tfoot,th,thead,time,title,title,tr,track,tt,u,ul,var,video,wbr,xmp,', ','.element.',') > -1
			let values = ["first-child", "link", "visited", "hover", "active", "focus", "lang", "first-line", "first-letter", "before", "after"]
		else
			return []
		endif
	endif

	" Complete values
	let entered_value = matchstr(line, '.\{-}\zs[a-zA-Z0-9#,.(_-]*$')

	for m in values
		if m =~? '^'.entered_value
			call add(res, m)
		elseif m =~? entered_value
			call add(res2, m)
		endif
	endfor

	return res + res2

elseif borders[max(keys(borders))] == 'closebrace'

	return []

elseif borders[max(keys(borders))] == 'exclam'

	" Complete values
	let entered_imp = matchstr(line, '.\{-}!\s*\zs[a-zA-Z ]*$')

	let values = ["important"]

	for m in values
		if m =~? '^'.entered_imp
			call add(res, m)
		endif
	endfor

	return res

elseif borders[max(keys(borders))] == 'atrule'

	let afterat = matchstr(line, '.*@\zs.*')

	if afterat =~ '\s'

		let atrulename = matchstr(line, '.*@\zs[a-zA-Z-]\+\ze')

		if atrulename == 'media'
			let values = ["screen", "tty", "tv", "projection", "handheld", "print", "braille", "aural", "all"]

			let entered_atruleafter = matchstr(line, '.*@media\s\+\zs.*$')

		elseif atrulename == 'import'
			let entered_atruleafter = matchstr(line, '.*@import\s\+\zs.*$')

			if entered_atruleafter =~ "^[\"']"
				let filestart = matchstr(entered_atruleafter, '^.\zs.*')
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"\"".v:val')

			elseif entered_atruleafter =~ "^url("
				let filestart = matchstr(entered_atruleafter, "^url([\"']\\?\\zs.*")
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"url(".v:val')
				
			else
				let values = ['"', 'url(']

			endif

		else
			return []

		endif

		for m in values
			if m =~? '^'.entered_atruleafter
				call add(res, m)
			elseif m =~? entered_atruleafter
				call add(res2, m)
			endif
		endfor

		return res + res2

	endif

	let values = ["charset", "page", "media", "import", "font-face"]

	let entered_atrule = matchstr(line, '.*@\zs[a-zA-Z-]*$')

	for m in values
		if m =~? '^'.entered_atrule
			call add(res, m .' ')
		elseif m =~? entered_atrule
			call add(res2, m .' ')
		endif
	endfor

	return res + res2

endif

return []

endfunction
