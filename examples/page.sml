(* sml-markdown demo: parses a Markdown document with Markdown.parse, writes the
   real rendered HTML to assets/page.html (Markdown.toHtml), and rasterizes the
   parsed Html.node AST as a "rendered page" to assets/page.png using the
   bitmap-font renderer. *)

open Html

val md = String.concatWith "\n"
  [ "# sml-markdown"
  , ""
  , "A CommonMark subset that renders to an **sml-html** node tree."
  , ""
  , "## Features"
  , ""
  , "- ATX headings and paragraphs"
  , "- fenced code blocks and lists"
  , "- links, images, and emphasis"
  , ""
  , "## Example"
  , ""
  , "```"
  , "val html = Markdown.toHtml src"
  , "```"
  , ""
  , "> Output is escaped by default."
  , ""
  , "See the docs page for the full grammar." ]

(* ---- write the real HTML the library produces ---- *)
val () =
  let val os = TextIO.openOut "assets/page.html"
  in TextIO.output (os, Html.document (el "main" [] (Markdown.parse md)));
     TextIO.closeOut os
  end

(* ---- render the parsed AST to a page bitmap ---- *)
val width = 620
val margin = 28

val pageBg  = (250, 250, 251)
val headCol = (26, 29, 40)
val subCol  = (54, 80, 140)
val textCol = (62, 66, 78)
val codeBg  = (235, 238, 244)
val codeCol = (44, 70, 110)
val quoteBar = (150, 200, 210)
val quoteCol = (108, 114, 128)
val hrCol   = (214, 218, 226)
val bullet  = (150, 160, 176)

fun innerText (Text s) = s
  | innerText (Raw s) = s
  | innerText (Element { children, ... }) = String.concat (map innerText children)
fun nodesText ns = String.concat (map innerText ns)

(* word-wrap to a column budget *)
fun wrap (s, maxCols) =
  let
    val ws = String.tokens (fn c => c = #" ") s
    fun go ([], cur, acc) = rev (if cur = "" then acc else cur :: acc)
      | go (w :: rest, cur, acc) =
          if cur = "" then go (rest, w, acc)
          else if size cur + 1 + size w <= maxCols then go (rest, cur ^ " " ^ w, acc)
          else go (rest, w, cur :: acc)
  in
    if s = "" then [] else go (ws, "", [])
  end

fun putText NONE _ _ _ _ = ()
  | putText (SOME c) (x, y) sc col s = ignore (Font.drawText c (x, y) sc col s)
fun putRect NONE _ _ = ()
  | putRect (SOME c) (x, y, w, h) col = Canvas.fillRect c (x, y, w, h) col

fun textLines (co, y, x, sc, col, s) =
  let
    val maxCols = (width - x - margin) div (6 * sc)
    val lines = wrap (s, Int.max (1, maxCols))
    val lh = (7 * sc) + (2 * sc)
    fun draw (i, ln) = putText co (x, y + i * lh) sc col ln
    fun loop (i, ls) = case ls of [] => () | l :: r => (draw (i, l); loop (i + 1, r))
  in
    loop (0, lines);
    y + (case lines of [] => lh | _ => length lines * lh)
  end

fun heading (co, y, s, sc, col) =
  let val () = putText co (margin, y) sc col s
  in y + 7 * sc + 6 * sc end

fun codeBlock (co, y, s) =
  let
    val lines = String.fields (fn c => c = #"\n") s
    val lines = List.filter (fn l => l <> "") lines
    val lh = 7 * 2 + 6
    val boxH = length lines * lh + 12
    val () = putRect co (margin, y, width - 2 * margin, boxH) codeBg
    fun draw (i, ln) = putText co (margin + 8, y + 6 + i * lh) 2 codeCol ln
    fun loop (i, ls) = case ls of [] => () | l :: r => (draw (i, l); loop (i + 1, r))
  in
    loop (0, lines);
    y + boxH + 10
  end

fun listBlock (co, y, children) =
  let
    fun item (node, yy) =
      case node of
          Element { tag = "li", children = kids, ... } =>
            let val () = putText co (margin + 4, yy) 2 bullet "-"
            in textLines (co, yy, margin + 22, 2, textCol, nodesText kids) + 4 end
        | _ => yy
  in
    List.foldl item y children
  end

fun block (co, node, y) =
  case node of
      Element { tag, children, ... } =>
        if tag = "h1" then heading (co, y, nodesText children, 4, headCol)
        else if tag = "h2" then heading (co, y, nodesText children, 3, subCol)
        else if tag = "h3" then heading (co, y, nodesText children, 2, subCol)
        else if tag = "p" then textLines (co, y, margin, 2, textCol, nodesText children) + 10
        else if tag = "ul" orelse tag = "ol" then listBlock (co, y, children) + 8
        else if tag = "pre" then codeBlock (co, y, nodesText children)
        else if tag = "blockquote" then
          let
            val yEnd = textLines (co, y, margin + 16, 2, quoteCol, nodesText children)
            val () = putRect co (margin, y, 4, yEnd - y) quoteBar
          in yEnd + 10 end
        else if tag = "hr" then (putRect co (margin, y + 6, width - 2 * margin, 2) hrCol; y + 18)
        else textLines (co, y, margin, 2, textCol, nodesText children) + 10
    | Text s => if CharVector.all Char.isSpace s then y
                else textLines (co, y, margin, 2, textCol, s) + 10
    | Raw _ => y

val ast = Markdown.parse md

(* pass 1: measure; pass 2: draw *)
val endY = List.foldl (fn (n, y) => block (NONE, n, y)) margin ast
val canvasH = endY + margin
val canvas = Canvas.make (width, canvasH) pageBg
val _ = List.foldl (fn (n, y) => block (SOME canvas, n, y)) margin ast

val () =
  let
    val os = BinIO.openOut "assets/page.png"
  in
    BinIO.output (os, Image.encodePng (Canvas.toImage canvas));
    BinIO.closeOut os;
    print "wrote assets/page.png and assets/page.html\n"
  end
